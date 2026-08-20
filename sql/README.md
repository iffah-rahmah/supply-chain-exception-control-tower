# MySQL Database Setup

MySQL and MySQL Workbench are used for the SQL analysis.

## Files

- `01_create_database.sql`: creates the database and the `orders_clean` table.
- `01_validate_database.sql`: validates the data after the CSV import.
- `data/processed/dataco_orders_clean.csv`: cleaned dataset created in Notebook 2 and excluded from GitHub.

## Step 1: Create the database and table

1. Open MySQL Workbench.
2. Open your local MySQL connection.
3. Open `sql/01_create_database.sql`.
4. Click the lightning-bolt button to run the complete script.
5. Refresh the Schemas panel.
6. Confirm that `supply_chain_control_tower` and its `orders_clean` table appear.

## Step 2: Import the cleaned CSV

1. In the Schemas panel, expand `supply_chain_control_tower`.
2. Right-click `orders_clean`.
3. Select **Table Data Import Wizard**.
4. Choose `data/processed/dataco_orders_clean.csv`.
5. Select **Use existing table** and choose `orders_clean`.
6. Confirm that the CSV columns map to columns with the same names.
7. Complete the import.

The CSV contains 65,752 order-level rows and 31 columns.

## Step 3: Validate the import

1. Open `sql/01_validate_database.sql` in MySQL Workbench.
2. Run the complete script.
3. Confirm the expected results:

```text
Total rows: 65,752
Unique orders: 65,752
Duplicate Order IDs: 0
Rows with missing required values: 0
```

Expected delivery-status counts:

```text
Late delivery: 36,048
Advance shipping: 15,127
Shipping on time: 11,722
Shipping canceled: 2,855
```

## Important

The cleaned CSV is not uploaded to GitHub. To reproduce the project, download the original DataCo dataset and run the cleaning notebook first.
