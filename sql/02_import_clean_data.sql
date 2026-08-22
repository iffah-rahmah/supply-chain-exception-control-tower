-- Supply Chain Control Tower: Import Cleaned Orders

USE supply_chain_control_tower;

-- Replace the file path below with the full path to the cleaned CSV.
-- Run this import only after creating the empty orders_clean table.
LOAD DATA LOCAL INFILE '/full/path/to/dataco_orders_clean.csv'
INTO TABLE orders_clean
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_date,
    shipping_date,
    transaction_type,
    customer_segment,
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    shipping_mode,
    order_status,
    delivery_status,
    late_delivery_risk,
    actual_shipping_days,
    scheduled_shipping_days,
    item_line_count,
    total_quantity,
    unique_product_count,
    unique_category_count,
    gross_sales,
    order_value,
    total_discount,
    order_profit,
    delay_days,
    is_delivery_exception,
    exception_type,
    order_year,
    order_month,
    order_year_month
);

-- Confirm that the CSV rows were imported.
SELECT COUNT(*) AS imported_orders
FROM orders_clean;
