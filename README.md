# Customer Shopping Behavior Analysis

**Customer Shopping Behavior Analysis using Python, SQL, Power BI and DAX**

## Project Overview

This project analyzes customer shopping behavior and purchasing patterns using Python, Pandas, MySQL, Power BI, and DAX.

The project follows an end-to-end data analytics workflow:

**Raw CSV Dataset → Python/Pandas Data Exploration → Data Cleaning & Transformation → MySQL SQL Analysis → Power BI Dashboard → DAX Analysis**

The main objective of this project is to clean and transform customer shopping data, perform SQL-based business analysis, and present meaningful insights through an interactive Power BI dashboard.

---

## Dataset

The dataset contains **3,900 customer shopping records** and **18 columns**.

### Main Attributes

- Customer ID
- Age
- Gender
- Item Purchased
- Category
- Purchase Amount (USD)
- Location
- Size
- Color
- Season
- Review Rating
- Subscription Status
- Shipping Type
- Discount Applied
- Promo Code Used
- Previous Purchases
- Payment Method
- Frequency of Purchases

---

## Tools & Technologies

- Python
- Pandas
- MySQL
- Power BI
- DAX
- GitHub

---

# Project Workflow

## 1. Data Loading and Exploration using Python

The raw customer shopping behavior dataset was loaded into Python using Pandas.

```python
import pandas as pd

df = pd.read_csv("customer_shopping_behavior.csv")
```

The dataset was explored using the following Pandas functions.

### View the First Records

```python
df.head()
```

Used to view the first few rows of the dataset.

### Check Dataset Information

```python
df.info()
```

Used to understand:

- Number of records
- Column names
- Data types
- Non-null values

### Descriptive Statistics

```python
df.describe()
```

Used to generate statistical summaries for numerical columns.

### Descriptive Statistics for All Columns

```python
df.describe(include='all')
```

Used to review statistics for both numerical and categorical columns.

### Check Missing Values

```python
df.isnull().sum()
```

Used to identify missing values in each column.

---

# 2. Data Cleaning and Transformation using Pandas

## 2.1 Handling Missing Review Ratings

Missing values in the `Review Rating` column were handled using the median review rating within each product category.

```python
df['Review Rating'] = df.groupby('Category')['Review Rating'].transform(
    lambda x: x.fillna(x.median())
)
```

The category-wise median was used to maintain the differences between product categories.

---

## 2.2 Standardizing Column Names

The column names were converted to lowercase and spaces were replaced with underscores.

```python
df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ', '_')
```

This makes column names easier to use during Python analysis.

---

## 2.3 Renaming the Purchase Amount Column

The `purchase_amount_(usd)` column was renamed to `purchase_amount`.

```python
df = df.rename(columns={
    'purchase_amount_(usd)': 'purchase_amount'
})
```

This creates a shorter and easier column name for analysis.

---

## 2.4 Creating Age Group

A new `age_group` column was created using age quartiles.

```python
labels = ['young adult', 'adult', 'middle aged', 'senior']

df['age_group'] = pd.qcut(
    df['age'],
    q=4,
    labels=labels
)
```

The customers were grouped into:

- Young Adult
- Adult
- Middle Aged
- Senior

This feature supports age-based customer and revenue analysis.

---

## 2.5 Creating Purchase Frequency in Days

The categorical purchase frequency values were converted into numerical day values.

```python
frequency_mapping = {
    'Fortnightly': 14,
    'Weekly': 7,
    'Monthly': 30,
    'Quarterly': 90,
    'Bi-Weekly': 14,
    'Annually': 365,
    'Every 3 Months': 90
}

df['purchase_frequency_days'] = (
    df['frequency_of_purchases'].map(frequency_mapping)
)
```

### Frequency Mapping

- Weekly → 7 days
- Fortnightly → 14 days
- Bi-Weekly → 14 days
- Monthly → 30 days
- Quarterly → 90 days
- Every 3 Months → 90 days
- Annually → 365 days

This transformation converts purchase frequency from categorical values into numerical values.

---

## 2.6 Checking Discount and Promo Code Columns

The `discount_applied` and `promo_code_used` columns were reviewed before finalizing the analysis dataset.

```python
df[['discount_applied', 'promo_code_used']].head(10)
```

A validation check was also performed:

```python
(df[['discount_applied', 'promo_code_used']]).all()
```

---

## 2.7 Removing the Promo Code Column

The `promo_code_used` column was removed from the analysis dataset.

```python
df = df.drop('promo_code_used', axis=1)
```

---

## 2.8 Exporting the Dataset

After the Python data preparation steps, the dataset was exported as a CSV file.

```python
df.to_csv(
    "customer_shopping_behavior_cleaned.csv",
    index=False
)
```

The exported dataset was used as part of the SQL and Power BI analysis workflow.

---

# 3. SQL Analysis using MySQL

The customer shopping data was imported into MySQL for further analysis.

The database and table structure were checked using:

```sql
USE customer_behavior;

SHOW TABLES;

DESCRIBE customer_shopping_behavior;

SELECT *
FROM customer_shopping_behavior
LIMIT 10;
```

The analysis table was maintained as:

```sql
RENAME TABLE customer_shopping_behavior_cleaned
TO customer_shopping_behavior;
```

The available tables were then verified:

```sql
SHOW TABLES;
```

---

# 4. SQL Concepts Used

The SQL analysis used the following concepts:

- SELECT
- DISTINCT
- WHERE
- GROUP BY
- ORDER BY
- Aggregate Functions
- CASE Statements
- Conditional Aggregation
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- DENSE_RANK()
- Filtering
- Sorting

---

# 5. SQL Business Analysis

## 5.1 Revenue by Gender

Calculated the total revenue generated by each gender.

```sql
SELECT
    `Gender`,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Gender`;
```

---

## 5.2 Discounted Purchases Above Average Purchase Amount

Identified customers who applied a discount and had a purchase amount greater than the overall average purchase amount.

```sql
SELECT
    `Customer ID`,
    `Item Purchased`,
    `Purchase Amount (USD)`,
    `Discount Applied`
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` > (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer_shopping_behavior
);
```

This query demonstrates the use of a subquery.

---

## 5.3 Top 5 Items by Average Review Rating

Calculated the average review rating for each purchased item and identified the top 5 items.

```sql
SELECT
    `Item Purchased`,
    ROUND(AVG(`Review Rating`), 2) AS avg_review_rating
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY avg_review_rating DESC
LIMIT 5;
```

---

## 5.4 Shipping Type Analysis

Retrieved the available shipping types.

```sql
SELECT DISTINCT
    `Shipping Type`
FROM customer_shopping_behavior;
```

Compared the average purchase amount for Standard and Express shipping.

```sql
SELECT
    `Shipping Type`,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS average_purchase_amount
FROM customer_shopping_behavior
WHERE `Shipping Type` IN ('Standard', 'Express')
GROUP BY `Shipping Type`;
```

---

## 5.5 Subscription Status Analysis

Analyzed customer count, average spending, and total revenue based on subscription status.

```sql
SELECT
    `Subscription Status`,
    COUNT(`Customer ID`) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC, avg_spend DESC;
```

---

## 5.6 Discount Percentage by Item

Calculated total purchases, discounted purchases, and discount percentage for each item.

```sql
SELECT
    `Item Purchased`,
    COUNT(*) AS total_purchases,
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
```

This analysis uses conditional aggregation and CASE statements.

---

# 6. Customer Segmentation using CTE

Customers were segmented based on the number of previous purchases.

```sql
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
```

### Customer Segments

- **New** – 1 previous purchase
- **Returning** – 2 to 10 previous purchases
- **Loyal** – More than 10 previous purchases

This analysis demonstrates the use of a CTE and CASE statement.

---

# 7. Top 3 Products by Category using Window Functions

The top products within each category were identified using `DENSE_RANK()`.

```sql
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
```

This query demonstrates:

- CTEs
- Window Functions
- DENSE_RANK()
- PARTITION BY

---

# 8. Repeat Buyer Analysis

Customers with more than 5 previous purchases were analyzed based on subscription status.

```sql
SELECT
    `Subscription Status`,
    COUNT(`Customer ID`) AS repeat_buyers
FROM customer_shopping_behavior
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;
```

---

# 9. Revenue by Age Group

Revenue was analyzed across different age groups.

```sql
SELECT
    CASE
        WHEN `Age` < 25 THEN 'Young Adult'
        WHEN `Age` BETWEEN 25 AND 34 THEN 'Adult'
        WHEN `Age` BETWEEN 35 AND 49 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS age_group,

    ROUND(
        SUM(`Purchase Amount (USD)`),
        2
    ) AS total_revenue,

    ROUND(
        100.0 * SUM(`Purchase Amount (USD)`) /
        (
            SELECT SUM(`Purchase Amount (USD)`)
            FROM customer_shopping_behavior
        ),
        2
    ) AS revenue_percentage

FROM customer_shopping_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;
```

This analysis calculates:

- Total revenue by age group
- Revenue percentage contribution by age group

---

# 10. Power BI Dashboard

After completing the Python data preparation and SQL analysis, the data was used to create an interactive Power BI dashboard.

The dashboard provides a visual overview of customer purchasing behavior and business performance.

## Dashboard KPI Cards

- Total Customers
- Average Purchase Amount
- Average Review Rating

## Dashboard Slicers

- Subscription Status
- Gender
- Category
- Shipping Type

## Dashboard Visualizations

- Customer Subscription Status
- Revenue by Category
- Sales by Category
- Revenue by Age Group
- Sales by Age Group
- Customer Purchasing Behavior

## Dashboard Preview

![Customer Shopping Behavior Dashboard](customer_shopping_behavior_dashboard.png)
# 11. DAX

DAX (Data Analysis Expressions) was used in Power BI to create measures and calculate key metrics for the dashboard.

DAX was used for:

- Customer count
- Average purchase amount
- Average review rating
- Revenue calculations
- Sales calculations
- Category-level analysis
- Age-group analysis

The DAX measures were used to support KPI cards and Power BI visualizations.

---

# 12. Business Analysis Areas

This project focuses on analyzing:

- Customer purchasing behavior
- Revenue by gender
- Revenue by category
- Sales by category
- Subscription behavior
- Customer segmentation
- Repeat purchasing behavior
- Purchase frequency
- Age-group purchasing patterns
- Product ratings
- Discount usage
- Shipping type
- Product performance

---

# 13. Project Outcome

This project demonstrates an end-to-end data analytics workflow:

**Raw Data → Python/Pandas → Data Cleaning → Data Transformation → MySQL → SQL Analysis → DAX → Power BI Dashboard**

The project demonstrates practical skills in:

- Python
- Pandas
- Data Cleaning
- Data Transformation
- MySQL
- SQL
- Aggregate Functions
- CASE Statements
- Subqueries
- CTEs
- Window Functions
- DENSE_RANK()
- DAX
- Power BI
- Data Visualization
- Dashboard Development
- Business Analysis

---

# 14. Project Files

- `customer_shopping_behavior.csv` – Original dataset
- `customer_shopping_behavior_cleaned.csv` – Processed dataset used in the project
- `customer_behavior_cleaning.py` – Python/Pandas data preparation script
- `Data_analytics_project.sql` – SQL analysis queries
- `README.md` – Project documentation
- Power BI dashboard screenshot – Dashboard preview
- Power BI `.pbix` file – Dashboard project file

---

# 15. Conclusion

This project demonstrates how customer shopping data can be transformed into useful business information through Python-based data preparation, SQL analysis, DAX calculations, and Power BI visualization.

The project covers the complete data analytics pipeline:

**Data Exploration → Data Cleaning → Data Transformation → SQL Analysis → DAX Calculations → Power BI Dashboard Development**

It provides practical hands-on experience in Python, Pandas, MySQL, SQL, DAX, Power BI, data visualization, and business analysis.
