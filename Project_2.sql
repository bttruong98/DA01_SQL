-- So luong don hang va so luong khach hang moi thang
SELECT FORMAT_DATE('%Y-%m', DATE(created_at)) AS month_year,
       COUNT(DISTINCT user_id) AS total_user, 
       COUNT(DISTINCT order_id) AS total_order
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE FORMAT_DATE('%Y-%m', DATE(created_at)) <= '2022-04'
AND status = 'Complete'
GROUP BY FORMAT_DATE('%Y-%m', DATE(created_at))
ORDER BY month_year;

-- Gia tri don hang trung binh va so luong kh moi thang
SELECT FORMAT_DATE('%Y-%m', DATE(a.created_at)) AS month_year,
        COUNT(DISTINCT a.user_id) AS distinct_user,
        ROUND(SUM(b.sale_price)/COUNT(a.order_id),2) AS average_order_value
FROM bigquery-public-data.thelook_ecommerce.orders AS a
INNER JOIN bigquery-public-data.thelook_ecommerce.order_items AS b
ON a.order_id = b.order_id
WHERE FORMAT_DATE('%Y-%m', DATE(a.created_at)) <= '2022-04'
GROUP BY FORMAT_DATE('%Y-%m', DATE(a.created_at))
ORDER BY month_year;

-- Nhom kh theo do tuoi
WITH age_extremes AS (SELECT MIN(age) AS min_age, MAX(age) AS max_age 
                      FROM bigquery-public-data.thelook_ecommerce.users)
SELECT first_name, last_name, gender, age, tag
FROM (SELECT b.first_name, b.last_name, b.gender, b.age, FORMAT_DATE('%Y-%m', DATE(b.created_at)) AS month_year,
            (CASE WHEN age = a.min_age THEN 'youngest'
                  WHEN age = a.max_age THEN 'oldest'
                  ELSE ''
            END) AS tag
      FROM bigquery-public-data.thelook_ecommerce.users b
      CROSS JOIN age_extremes a
      WHERE FORMAT_DATE('%Y-%m', DATE(b.created_at)) <= '2022-04')
WHERE tag = 'youngest' OR tag= 'oldest';

-- Dem so luong kh tre nhat va so luong kh lon tuoi nhat bang cach dung bang tam thoi
BEGIN
        CREATE TEMP TABLE temp_user AS 
        (
        WITH age_extremes AS (SELECT MIN(age) AS min_age, MAX(age) AS max_age 
                              FROM bigquery-public-data.thelook_ecommerce.users)
        SELECT first_name, last_name, gender, age, tag
        FROM (SELECT b.first_name, b.last_name, b.gender, b.age, FORMAT_DATE('%Y-%m', DATE(b.created_at)) AS month_year,
                    (CASE WHEN age = a.min_age THEN 'youngest'
                          WHEN age = a.max_age THEN 'oldest'
                          ELSE ''
                    END) AS tag
              FROM bigquery-public-data.thelook_ecommerce.users b
              CROSS JOIN age_extremes a
              WHERE FORMAT_DATE('%Y-%m', DATE(b.created_at)) <= '2022-04')
        WHERE tag = 'youngest' OR tag= 'oldest'
        );
        SELECT tag, COUNT(*)
        FROM temp_user
        GROUP BY tag;
END;

-- Top 5 san pham moi thang
WITH profit_items AS
(SELECT FORMAT_DATE('%Y-%m', DATE(a.created_at)) AS month_year,
        a.product_id,
        b.name AS product_name,
        ROUND(a.sale_price,2) AS sales,
        ROUND(b.cost,2) AS cost,
        ROUND((a.sale_price - b.cost),2) AS profits,
        DENSE_RANK () OVER (PARTITION BY FORMAT_DATE('%Y-%m', DATE(a.created_at)) 
                            ORDER BY ROUND((a.sale_price - b.cost),2) DESC, FORMAT_DATE('%Y-%m', DATE(a.created_at))) 
                            AS rank_per_month
FROM bigquery-public-data.thelook_ecommerce.order_items a
JOIN bigquery-public-data.thelook_ecommerce.products b
ON a.product_id = b.id
WHERE FORMAT_DATE('%Y-%m', DATE(created_at)) <= '2022-04')
SELECT month_year, product_id, product_name, sales, cost, profits, rank_per_month
FROM profit_items
WHERE rank_per_month <= 5;

-- Doanh thu tinh den thoi diem hien tai tren moi danh muc
SELECT DATE(a.created_at) AS dates, b.category AS product_category, ROUND(SUM(a.sale_price),2) AS revenue
FROM bigquery-public-data.thelook_ecommerce.order_items a
LEFT JOIN bigquery-public-data.thelook_ecommerce.products b
ON a.product_id = b.id
WHERE DATE(a.created_at) BETWEEN DATE_SUB('2022-04-15', INTERVAL 3 MONTH) AND DATE('2022-04-15')
GROUP BY product_category, dates
ORDER BY dates DESC, revenue DESC;

-- Tao dataset de dung dashboard
CREATE OR REPLACE VIEW `bigquery-public-data.thelook_ecommerce.vw_ecommerce_analyst` AS
WITH key_elements AS
(SELECT FORMAT_DATE('%Y-%m', DATE(oi.created_at)) AS month, 
        EXTRACT(year FROM oi.created_at) AS year, 
        p.category AS product_category, 
        ROUND(SUM(oi.sale_price),2) AS TPV,
        COUNT(*) AS TPO,
        ROUND(SUM(p.cost),2) AS total_cost,
        ROUND(SUM(oi.sale_price - p.cost),2) AS total_profit,
        ROUND(SUM(oi.sale_price - p.cost)/SUM(p.cost),2) AS profit_to_cost_ratio
FROM bigquery-public-data.thelook_ecommerce.order_items oi
JOIN bigquery-public-data.thelook_ecommerce.orders o
ON oi.order_id = o.order_id
JOIN bigquery-public-data.thelook_ecommerce.products p
ON oi.product_id = p.id
GROUP BY FORMAT_DATE('%Y-%m', DATE(oi.created_at)), 
         EXTRACT(year FROM oi.created_at), 
         p.category
ORDER BY month, year, TPV DESC)
SELECT month,
        year,
        product_category,
        TPV, TPO,
        ROUND((TPV - LAG(TPV) OVER(PARTITION BY product_category ORDER BY month))*100
              /NULLIF(LAG(TPV) OVER(PARTITION BY product_category ORDER BY month),0),2)||'%' AS revenue_growth,
        ROUND((TPO - LAG(TPO) OVER(PARTITION BY product_category ORDER BY month))*100
              /NULLIF(LAG(TPO) OVER(PARTITION BY product_category ORDER BY month),0),2)||'%' AS order_growth,
        total_cost,
        total_profit,
        profit_to_cost_ratio
FROM key_elements
ORDER BY month;

-- Cohort Analysis
WITH ecommerce_main AS(SELECT *
                       FROM (SELECT id, user_id, order_id, product_id, created_at AS purchase_dates, 
                                    ROUND(sale_price,2) AS amount,
                                    ROW_NUMBER() OVER(PARTITION BY id, user_id, order_id, product_id
                                                ORDER BY created_at) AS dub_flag
                             FROM bigquery-public-data.thelook_ecommerce.order_items)
                       WHERE dub_flag = 1
                       ORDER BY purchase_dates),
ecommerce_index AS (SELECT user_id, 
                            amount,
                            FORMAT_DATE('%Y-%m-01', DATE(first_purchase_dates)) AS cohort_date,
                            purchase_dates,
                            (EXTRACT(year FROM purchase_dates) - EXTRACT(year FROM first_purchase_dates))*12 
                            + (EXTRACT(month FROM purchase_dates) - EXTRACT(month FROM first_purchase_dates)) AS index
                    FROM (SELECT user_id,
                                  amount,
                                  MIN(purchase_dates) OVER(PARTITION BY user_id) AS first_purchase_dates,
                                  purchase_dates
                          FROM ecommerce_main
                          ORDER BY purchase_dates))
SELECT cohort_date,
        index,
        COUNT(DISTINCT user_id) AS user_cnt,
        ROUND(SUM(amount),2) AS revenue
FROM ecommerce_index
WHERE index <= 3 
GROUP BY cohort_date, index
ORDER BY cohort_date;
