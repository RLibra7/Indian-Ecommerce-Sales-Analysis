/*
PROJECT: Indian E-Commerce Sales & Profitability Analysis
TOOLS: MySQL
DATABASE: indian_ecommerce_sales

Purpose:
Analysis-only SQL queries for the imported Indian e-commerce dataset.
The source tables are expected to be:
  `list of orders clean`
  `order details`

Important:
- This script does not create, delete, truncate, or modify data.
- Column/table names are wrapped in backticks because they contain spaces.
*/

USE `indian_ecommerce_sales`;

-- =========================================================
-- 1. CHECK TABLE ROW COUNTS
-- =========================================================

SELECT COUNT(*) AS total_orders_rows
FROM `list of orders clean`;

SELECT COUNT(*) AS order_details_rows
FROM `order details`;


-- =========================================================
-- 2. OVERALL BUSINESS KPIs
-- Expected validation values:
-- Sales = 431502, Profit = 23955, Quantity = 5615
-- =========================================================

SELECT
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity,
    COUNT(*) AS order_detail_records,
    COUNT(DISTINCT `Order ID`) AS distinct_order_ids
FROM `order details`;


-- =========================================================
-- 3. SALES, PROFIT AND QUANTITY BY CATEGORY
-- =========================================================

SELECT
    `Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity,
    ROUND(
        100 * SUM(`Profit`) / NULLIF(SUM(`Amount`), 0),
        2
    ) AS profit_margin_pct
FROM `order details`
GROUP BY `Category`
ORDER BY total_sales DESC;


-- =========================================================
-- 4. SALES, PROFIT AND QUANTITY BY SUB-CATEGORY
-- =========================================================

SELECT
    `Sub-Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity
FROM `order details`
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;


-- =========================================================
-- 5. TOP 10 SUB-CATEGORIES BY SALES
-- =========================================================

SELECT
    `Sub-Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity
FROM `order details`
GROUP BY `Sub-Category`
ORDER BY total_sales DESC
LIMIT 10;


-- =========================================================
-- 6. BOTTOM 10 SUB-CATEGORIES BY SALES
-- =========================================================

SELECT
    `Sub-Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity
FROM `order details`
GROUP BY `Sub-Category`
ORDER BY total_sales ASC
LIMIT 10;


-- =========================================================
-- 7. LOSS-MAKING SUB-CATEGORIES
-- =========================================================

SELECT
    `Sub-Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    SUM(`Quantity`) AS total_quantity
FROM `order details`
GROUP BY `Sub-Category`
HAVING SUM(`Profit`) < 0
ORDER BY total_profit ASC;


-- =========================================================
-- 8. STATE-WISE SALES AND PROFIT
-- Join order details to order locations through Order ID.
-- =========================================================

SELECT
    o.`State`,
    SUM(d.`Amount`) AS total_sales,
    SUM(d.`Profit`) AS total_profit,
    SUM(d.`Quantity`) AS total_quantity
FROM `list of orders clean` AS o
JOIN `order details` AS d
    ON o.`Order ID` = d.`Order ID`
GROUP BY o.`State`
ORDER BY total_sales DESC;


-- =========================================================
-- 9. TOP 10 STATES BY SALES
-- =========================================================

SELECT
    o.`State`,
    SUM(d.`Amount`) AS total_sales,
    SUM(d.`Profit`) AS total_profit
FROM `list of orders clean` AS o
JOIN `order details` AS d
    ON o.`Order ID` = d.`Order ID`
GROUP BY o.`State`
ORDER BY total_sales DESC
LIMIT 10;


-- =========================================================
-- 10. MONTHLY SALES AND PROFIT TREND
-- Assumes Order Date is stored as text in DD-MM-YYYY format.
-- If Order Date is a MySQL DATE column, replace
-- STR_TO_DATE(o.`Order Date`, '%d-%m-%Y') with
-- DATE(o.`Order Date`).
-- =========================================================

SELECT
    DATE_FORMAT(
        STR_TO_DATE(o.`Order Date`, '%d-%m-%Y'),
        '%Y-%m'
    ) AS order_month,
    SUM(d.`Amount`) AS total_sales,
    SUM(d.`Profit`) AS total_profit
FROM `list of orders clean` AS o
JOIN `order details` AS d
    ON o.`Order ID` = d.`Order ID`
GROUP BY order_month
ORDER BY order_month;


-- =========================================================
-- 11. PROFIT MARGIN BY CATEGORY
-- =========================================================

SELECT
    `Category`,
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    ROUND(
        100 * SUM(`Profit`) / NULLIF(SUM(`Amount`), 0),
        2
    ) AS profit_margin_pct
FROM `order details`
GROUP BY `Category`
ORDER BY profit_margin_pct DESC;


-- =========================================================
-- 12. OVERALL PROFIT MARGIN
-- =========================================================

SELECT
    SUM(`Amount`) AS total_sales,
    SUM(`Profit`) AS total_profit,
    ROUND(
        100 * SUM(`Profit`) / NULLIF(SUM(`Amount`), 0),
        2
    ) AS overall_profit_margin_pct
FROM `order details`;


-- =========================================================
-- 13. ORDER-LEVEL SALES SUMMARY
-- Combine line items to get total amount/profit per order.
-- =========================================================

SELECT
    `Order ID`,
    SUM(`Amount`) AS order_sales,
    SUM(`Profit`) AS order_profit,
    SUM(`Quantity`) AS order_quantity
FROM `order details`
GROUP BY `Order ID`
ORDER BY order_sales DESC;


-- =========================================================
-- 14. JOIN VALIDATION
-- Compare the joined detail rows with the detail table.
-- =========================================================

SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT d.`Order ID`) AS distinct_orders_in_join,
    SUM(d.`Amount`) AS joined_sales,
    SUM(d.`Profit`) AS joined_profit
FROM `list of orders clean` AS o
JOIN `order details` AS d
    ON o.`Order ID` = d.`Order ID`;


-- =========================================================
-- 15. KEY BUSINESS FINDINGS TO VALIDATE
-- =========================================================

-- Highest-sales category
SELECT
    `Category`,
    SUM(`Amount`) AS total_sales
FROM `order details`
GROUP BY `Category`
ORDER BY total_sales DESC
LIMIT 1;

-- Highest-profit category
SELECT
    `Category`,
    SUM(`Profit`) AS total_profit
FROM `order details`
GROUP BY `Category`
ORDER BY total_profit DESC
LIMIT 1;

-- Lowest-profit category
SELECT
    `Category`,
    SUM(`Profit`) AS total_profit
FROM `order details`
GROUP BY `Category`
ORDER BY total_profit ASC
LIMIT 1;
