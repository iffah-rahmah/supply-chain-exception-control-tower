-- Supply Chain Control Tower: MySQL Database Setup

-- Create database
CREATE DATABASE IF NOT EXISTS supply_chain_control_tower;

-- Select database
USE supply_chain_control_tower;

-- Create the order-level table
CREATE TABLE IF NOT EXISTS orders_clean (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME NOT NULL,
    shipping_date DATETIME NOT NULL,
    transaction_type VARCHAR(20),
    customer_segment VARCHAR(30),
    market VARCHAR(30) NOT NULL,
    order_region VARCHAR(50) NOT NULL,
    order_country VARCHAR(100) NOT NULL,
    order_state VARCHAR(100),
    order_city VARCHAR(100),
    shipping_mode VARCHAR(30) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL,
    late_delivery_risk TINYINT NOT NULL,
    actual_shipping_days INT NOT NULL,
    scheduled_shipping_days INT NOT NULL,
    item_line_count INT NOT NULL,
    total_quantity INT NOT NULL,
    unique_product_count INT NOT NULL,
    unique_category_count INT NOT NULL,
    gross_sales DECIMAL(15, 2) NOT NULL,
    order_value DECIMAL(15, 2) NOT NULL,
    total_discount DECIMAL(15, 2) NOT NULL,
    order_profit DECIMAL(15, 2) NOT NULL,
    delay_days INT NOT NULL,
    is_delivery_exception TINYINT NOT NULL,
    exception_type VARCHAR(30) NOT NULL,
    order_year SMALLINT NOT NULL,
    order_month TINYINT NOT NULL,
    order_year_month CHAR(7) NOT NULL
);

-- Check the table structure
DESCRIBE orders_clean;
