"""Create smaller MySQL INSERT files from the cleaned order-level CSV."""

import csv
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_CSV = PROJECT_ROOT / "data" / "processed" / "dataco_orders_clean.csv"
OUTPUT_FOLDER = PROJECT_ROOT / "data" / "processed" / "mysql_import_batches"

# Each SQL file contains 5,000 orders. Each INSERT statement contains 200 orders.
ORDERS_PER_FILE = 5_000
ORDERS_PER_INSERT = 200

NUMERIC_COLUMNS = {
    "order_id",
    "customer_id",
    "late_delivery_risk",
    "actual_shipping_days",
    "scheduled_shipping_days",
    "item_line_count",
    "total_quantity",
    "unique_product_count",
    "unique_category_count",
    "gross_sales",
    "order_value",
    "total_discount",
    "order_profit",
    "delay_days",
    "is_delivery_exception",
    "order_year",
    "order_month",
}

MONEY_COLUMNS = {
    "gross_sales",
    "order_value",
    "total_discount",
    "order_profit",
}


def convert_to_sql_value(column, value):
    """Convert one CSV value into a value that MySQL can read safely."""
    if value == "":
        return "NULL"

    if column in MONEY_COLUMNS:
        return f"{float(value):.2f}"

    if column in NUMERIC_COLUMNS:
        return value

    # Hex encoding safely preserves commas, quotation marks, and accented text.
    encoded_value = value.encode("utf-8").hex()
    return f"CONVERT(0x{encoded_value} USING utf8mb4)"


def write_sql_file(file_number, columns, rows):
    """Write one batch file containing up to 5,000 orders."""
    output_path = OUTPUT_FOLDER / f"chunk_{file_number:02d}.sql"
    column_names = ", ".join(f"`{column}`" for column in columns)

    with output_path.open("w", encoding="utf-8", newline="\n") as sql_file:
        sql_file.write("USE supply_chain_control_tower;\n")
        sql_file.write("START TRANSACTION;\n\n")

        for start in range(0, len(rows), ORDERS_PER_INSERT):
            insert_rows = rows[start : start + ORDERS_PER_INSERT]
            sql_file.write(
                f"INSERT IGNORE INTO orders_clean ({column_names}) VALUES\n"
            )

            sql_rows = []
            for row in insert_rows:
                values = ", ".join(
                    convert_to_sql_value(column, row[column]) for column in columns
                )
                sql_rows.append(f"({values})")

            sql_file.write(",\n".join(sql_rows))
            sql_file.write(";\n\n")

        sql_file.write("COMMIT;\n")

    return output_path


def main():
    if not SOURCE_CSV.exists():
        raise FileNotFoundError(
            "Cleaned CSV not found. Run Notebook 2 before creating SQL batches."
        )

    OUTPUT_FOLDER.mkdir(parents=True, exist_ok=True)

    with SOURCE_CSV.open("r", encoding="utf-8", newline="") as csv_file:
        reader = csv.DictReader(csv_file)
        columns = reader.fieldnames
        current_rows = []
        file_number = 1
        output_paths = []

        for row in reader:
            current_rows.append(row)

            if len(current_rows) == ORDERS_PER_FILE:
                output_paths.append(
                    write_sql_file(file_number, columns, current_rows)
                )
                current_rows = []
                file_number += 1

        if current_rows:
            output_paths.append(write_sql_file(file_number, columns, current_rows))

    print(f"Created {len(output_paths)} SQL batch files:")
    for output_path in output_paths:
        print(f"- {output_path}")


if __name__ == "__main__":
    main()
