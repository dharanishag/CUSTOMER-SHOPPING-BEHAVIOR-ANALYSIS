USE customer_behavior;

SHOW TABLES;

DESCRIBE customer_shopping_behavior;

SELECT *
FROM customer_shopping_behavior
LIMIT 10;

RENAME TABLE customer_shopping_behavior_cleaned
TO customer_shopping_behavior;

show tables;

SELECT`Gender`,SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Gender`;

SELECT `Customer ID`,`Item Purchased`,`Purchase Amount (USD)`,`Discount Applied`
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` > (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer_shopping_behavior
);

SELECT `Item Purchased`,ROUND(AVG(`Review Rating`), 2) AS avg_review_rating
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY avg_review_rating DESC
LIMIT 5;

SELECT DISTINCT `Shipping Type`
FROM customer_shopping_behavior;

SELECT
    `Shipping Type`,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM customer_shopping_behavior
WHERE `Shipping Type` IN ('Standard', 'Express')
GROUP BY `Shipping Type`;

SELECT
    `Subscription Status`,
    COUNT(`Customer ID`) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC, avg_spend DESC;

SELECT `Item Purchased`,COUNT(*) AS total_purchases,
    SUM(
        CASE
            WHEN `Discount Applied` = 'Yes' THEN 1
            ELSE 0
        END
    ) AS discounted_purchases,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN `Discount Applied` = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS discount_percentage
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY discount_percentage DESC
LIMIT 5;

WITH customer_type AS (
    SELECT
        `Customer ID`,
        `Previous Purchases`,
        CASE
            WHEN `Previous Purchases` = 1 THEN 'New'
            WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_shopping_behavior
)

SELECT
    customer_segment,
    COUNT(*) AS `number of customers`
FROM customer_type
GROUP BY customer_segment;

WITH product_sales AS (
    SELECT
        `Category`,
        `Item Purchased`,
        COUNT(*) AS purchase_count
    FROM customer_shopping_behavior
    GROUP BY `Category`, `Item Purchased`
),
ranked_products AS (
    SELECT
        `Category`,
        `Item Purchased`,
        purchase_count,
        DENSE_RANK() OVER (
            PARTITION BY `Category`
            ORDER BY purchase_count DESC
        ) AS product_rank
    FROM product_sales
)
SELECT
    `Category`,
    `Item Purchased`,
    purchase_count,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY `Category`, product_rank;

SELECT
    `Subscription Status`,
    COUNT(`Customer ID`) AS repeat_buyers
FROM customer_shopping_behavior
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;

SELECT
    CASE
        WHEN `Age` < 25 THEN 'Young Adult'
        WHEN `Age` BETWEEN 25 AND 34 THEN 'Adult'
        WHEN `Age` BETWEEN 35 AND 49 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS age_group,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(`Purchase Amount (USD)`) /
        (SELECT SUM(`Purchase Amount (USD)`)
         FROM customer_shopping_behavior),
        2
    ) AS revenue_percentage
FROM customer_shopping_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;