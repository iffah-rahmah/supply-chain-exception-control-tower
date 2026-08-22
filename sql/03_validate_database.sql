-- Supply Chain Control Tower: Database Validation

USE supply_chain_control_tower;

-- 1. Check the table and columns
SHOW TABLES;
DESCRIBE orders_clean;

-- 2. Check total rows and unique orders
-- Both values should be 65,752.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM orders_clean;

-- 3. Check missing values in important columns
-- The result should be 0.
SELECT
    SUM(
        CASE
            WHEN order_id IS NULL
              OR order_date IS NULL
              OR shipping_date IS NULL
              OR delivery_status IS NULL
              OR shipping_mode IS NULL
              OR market IS NULL
              OR order_value IS NULL
            THEN 1
            ELSE 0
        END
    ) AS rows_with_missing_required_values
FROM orders_clean;

-- 4. Check delivery-status totals
SELECT
    delivery_status,
    COUNT(*) AS order_count
FROM orders_clean
GROUP BY delivery_status
ORDER BY order_count DESC;
