-- Supply Chain Control Tower: Business Analysis

USE supply_chain_control_tower;


-- 1. Overall delivery KPIs
-- Shows the size of the order and exception workload.
SELECT
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS total_exceptions,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Late delivery' THEN 1
            ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late delivery' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Shipping canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Shipping canceled' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM orders_clean;


-- 2. Delivery-status distribution
-- Shows which delivery outcomes occur most frequently.
SELECT
    delivery_status,
    COUNT(*) AS order_count,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage_of_orders
FROM orders_clean
GROUP BY delivery_status
ORDER BY order_count DESC;


-- 3. Late-delivery severity
-- Canceled shipments are excluded because delay days do not represent
-- a completed delivery outcome for those orders.
SELECT
    delay_days,
    COUNT(*) AS late_order_count,
    ROUND(
        100.0 * COUNT(*) / (
            SELECT COUNT(*)
            FROM orders_clean
            WHERE delivery_status = 'Late delivery'
        ),
        2
    ) AS percentage_of_late_orders
FROM orders_clean
WHERE delivery_status = 'Late delivery'
GROUP BY delay_days
ORDER BY delay_days;


-- 4. Delivery performance by shipping mode
-- Counts show workload, while rates allow a fairer comparison.
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS exception_orders,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Late delivery' THEN 1
            ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late delivery' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Shipping canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Shipping canceled' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM orders_clean
GROUP BY shipping_mode
ORDER BY exception_rate_pct DESC;


-- 5. Delivery performance by market
-- Compares broad destination markets of different sizes.
SELECT
    market,
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS exception_orders,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Late delivery' THEN 1
            ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'Late delivery' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_rate_pct,
    SUM(
        CASE
            WHEN delivery_status = 'Shipping canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders
FROM orders_clean
GROUP BY market
ORDER BY exception_rate_pct DESC;


-- 6. Regions with the highest exception rates
-- The order count is included so the rate is not viewed without context.
SELECT
    order_region,
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS exception_orders,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct
FROM orders_clean
GROUP BY order_region
ORDER BY exception_rate_pct DESC, total_orders DESC;


-- 7. Monthly delivery-exception trend
SELECT
    order_year_month,
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS exception_orders,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct
FROM orders_clean
GROUP BY order_year_month
ORDER BY order_year_month;


-- 8. Relationship between order status and delivery exceptions
-- This helps identify upstream order issues linked to canceled shipments.
SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(is_delivery_exception) AS exception_orders,
    SUM(
        CASE
            WHEN delivery_status = 'Late delivery' THEN 1
            ELSE 0
        END
    ) AS late_orders,
    SUM(
        CASE
            WHEN delivery_status = 'Shipping canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders,
    ROUND(
        100.0 * SUM(is_delivery_exception) / COUNT(*),
        2
    ) AS exception_rate_pct
FROM orders_clean
GROUP BY order_status
ORDER BY exception_rate_pct DESC, total_orders DESC;


-- 9. Priority summary
-- Priority rules:
-- High: canceled or at least 3 days late
-- Medium: 2 days late
-- Low: 1 day late
-- No Exception: on time or advance shipping
SELECT
    priority_level,
    COUNT(*) AS order_count,
    ROUND(SUM(order_value), 2) AS total_order_value
FROM (
    SELECT
        order_id,
        order_value,
        CASE
            WHEN delivery_status = 'Shipping canceled' THEN 'High'
            WHEN delivery_status = 'Late delivery'
                 AND delay_days >= 3 THEN 'High'
            WHEN delivery_status = 'Late delivery'
                 AND delay_days = 2 THEN 'Medium'
            WHEN delivery_status = 'Late delivery'
                 AND delay_days = 1 THEN 'Low'
            ELSE 'No Exception'
        END AS priority_level
    FROM orders_clean
) AS priority_data
GROUP BY priority_level
ORDER BY
    CASE priority_level
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
        ELSE 4
    END;


-- 10. High-priority exception queue
-- Canceled shipments are listed first, followed by the longest delays
-- and highest-value orders.
SELECT
    order_id,
    order_date,
    market,
    order_region,
    order_country,
    shipping_mode,
    delivery_status,
    order_status,
    delay_days,
    order_value,
    order_profit,
    'High' AS priority_level
FROM orders_clean
WHERE delivery_status = 'Shipping canceled'
   OR (
        delivery_status = 'Late delivery'
        AND delay_days >= 3
   )
ORDER BY
    CASE
        WHEN delivery_status = 'Shipping canceled' THEN 1
        ELSE 2
    END,
    CASE
        WHEN delivery_status = 'Late delivery' THEN delay_days
        ELSE NULL
    END DESC,
    order_value DESC
LIMIT 50;
