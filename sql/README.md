# MySQL Database Setup

MySQL and MySQL Workbench are used for the SQL analysis.

## Files

- `01_create_database.sql`: creates the database and the `orders_clean` table.
- `02_import_clean_data.sql`: loads the cleaned order-level CSV into MySQL.
- `03_validate_database.sql`: validates the data after the CSV import.
- `04_business_analysis.sql`: answers the main operational business questions.
- `data/processed/dataco_orders_clean.csv`: cleaned dataset created in Notebook 2 and excluded from GitHub.

## Step 1: Create the database and table

1. Open MySQL Workbench.
2. Open your local MySQL connection.
3. Open `sql/01_create_database.sql`.
4. Click the lightning-bolt button to run the complete script.
5. Refresh the Schemas panel.
6. Confirm that `supply_chain_control_tower` and its `orders_clean` table appear.

## Step 2: Import the cleaned CSV

1. Open `sql/02_import_clean_data.sql` in MySQL Workbench.
2. Replace `/full/path/to/dataco_orders_clean.csv` with the full path to the cleaned CSV on your computer.
3. Run the script after confirming that `orders_clean` is empty.
4. Confirm that `imported_orders` returns `65,752`.

The CSV contains 65,752 order-level rows and 31 columns.

`LOAD DATA LOCAL INFILE` must be enabled for the MySQL client and server. If MySQL returns Error 3948 because local file loading is disabled, use MySQL Workbench's **Table Data Import Wizard**:

1. In the Schemas panel, expand `supply_chain_control_tower`.
2. Right-click `orders_clean` and select **Table Data Import Wizard**.
3. Choose `data/processed/dataco_orders_clean.csv`.
4. Select **Use existing table** and choose `orders_clean`.
5. Confirm that the CSV columns map to columns with the same names.
6. Complete the import.

### Batch-import fallback used in this project

During development, local file loading was disabled in the project environment. The cleaned CSV was therefore loaded into the same table in smaller `INSERT` batches.

The batch-generation code is saved in `scripts/create_mysql_import_batches.py`. It provides a reproducible record of how the fallback import was created without uploading 51 MB of generated SQL files to GitHub.

1. Run `python3 scripts/create_mysql_import_batches.py` from the project folder.
2. The script creates 14 files inside `data/processed/mysql_import_batches`.
3. Open and run `chunk_01.sql` through `chunk_14.sql` in numerical order in MySQL Workbench.
4. Each file adds up to 5,000 orders to the same `orders_clean` table.
5. Run `03_validate_database.sql` after the final batch.

The generated batch files are excluded from GitHub because they repeat the cleaned CSV data. The generator remains in the repository so the method can be inspected and reproduced. Final validation confirmed that all 65,752 orders were present with no duplicate Order IDs.

## Step 3: Validate the import

1. Open `sql/03_validate_database.sql` in MySQL Workbench.
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

## Step 4: Run the business analysis

After the import validation is complete, open `sql/04_business_analysis.sql` in MySQL Workbench and run the queries one section at a time.

The file covers overall KPIs, delivery status, delay severity, shipping mode, market, region, monthly trends, order status, and exception priority.
