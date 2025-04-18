-- ex1: datalemur-duplicate-job-listings
SELECT COUNT(*) AS duplicate_companies
FROM(SELECT company_id, description, COUNT(*)
     FROM job_listings
     GROUP BY company_id, title, description
     HAVING COUNT(*) >= 2) AS new_table;

-- ex2: datalemur-highest-grossing
SELECT 
  p1.category,
  p1.product,
  SUM(p1.spend) AS total_spend
FROM product_spend p1
WHERE EXTRACT(YEAR FROM p1.transaction_date) = 2022
GROUP BY p1.category, p1.product
HAVING (
  SELECT COUNT(DISTINCT total_spend)
  FROM (
    SELECT SUM(p2.spend) AS total_spend
    FROM product_spend p2
    WHERE EXTRACT(YEAR FROM p2.transaction_date) = 2022
      AND p2.category = p1.category
    GROUP BY p2.product
  ) AS cat_pro_table
  WHERE cat_pro_table.total_spend > SUM(p1.spend)
) < 2;

-- ex3: datalemur-frequent-callers
SELECT COUNT(*) AS policy_holder_count
FROM(SELECT policy_holder_id, COUNT(case_id)
    FROM callers
    GROUP BY policy_holder_id 
    HAVING COUNT(case_id) >= 3) AS new_table;

-- ex4: datalemur-page-with-no-likes
SELECT p.page_id
FROM pages AS p
LEFT JOIN page_likes AS pl
ON pl.page_id = p.page_id
WHERE pl.liked_date IS NULL
ORDER BY p.page_id;

-- ex5: datalemur-user-retention.
SELECT 7 AS month,
       COUNT(*) AS monthly_active_users
FROM (SELECT DISTINCT user_id
      FROM user_actions
      WHERE EXTRACT(month from event_date) = '06'
        AND EXTRACT(year from event_date) = '2022') AS june_user
JOIN (SELECT DISTINCT user_id
      FROM user_actions
      WHERE EXTRACT(month from event_date) = '07'
        AND EXTRACT(year from event_date) = '2022') AS july_user
ON june_user.user_id = july_user.user_id;

-- ex6: leetcode-monthly-transactions
SELECT TO_CHAR(trans_date, 'YYYY-MM') AS month,
        Country,
        COUNT(amount) AS trans_count,
        COUNT(CASE WHEN state = 'approved' THEN 1 END) AS approved_count,
        SUM(amount) AS trans_total_amount,
        SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM transactions
GROUP BY country, month
ORDER BY month;

-- ex7: leetcode-product-sales-analysis
SELECT s.product_id,
       s.year AS first_year,
       s.quantity,
       s.price
FROM sales AS s
WHERE Year = (SELECT MIN(year)
              FROM sales
              WHERE product_id = s.product_id);

-- ex8: leetcode-customers-who-bought-all-products
SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM product);

-- ex9: leetcode-employees-whose-manager-left-the-company
SELECT employee_id
FROM employees
WHERE manager_id NOT IN (SELECT employee_id FROM employees)
AND salary < 30000
ORDER BY employee_id;

-- ex10: leetcode-primary-department-for-each-employee
SELECT employee_id, department_id
FROM employee
WHERE primary_flag = 'Y'
UNION
SELECT employee_id, department_id
FROM employee
WHERE employee_id IN (SELECT employee_id
                    FROM employee
                    GROUP BY employee_id
                    HAVING COUNT(*) = 1)
ORDER BY employee_id;

-- ex11: leetcode-movie-rating
(SELECT u.name AS results
FROM Users AS u
JOIN (SELECT user_id, COUNT(*) AS ranking
      FROM MovieRating 
      GROUP BY user_id) AS mr 
ON mr.user_id = u.user_id
ORDER BY mr.ranking DESC, u.name
LIMIT 1)
UNION ALL
(SELECT m.title AS results
FROM Movies AS m
JOIN (SELECT movie_id, AVG(rating) AS ranking2
      FROM MovieRating
      WHERE EXTRACT(month FROM created_at) = '02'
        AND EXTRACT(year FROM created_at) = '2020'
      GROUP BY movie_id) AS mr ON mr.movie_id = m.movie_id
ORDER BY mr.ranking2 DESC, m.title
LIMIT 1);

-- ex12: leetcode-who-has-the-most-friends
WITH all_ids AS (SELECT requester_id
                FROM RequestAccepted
                UNION ALL
                SELECT accepter_id
                FROM RequestAccepted)
SELECT requester_id AS id, COUNT(*) AS num
FROM all_ids
GROUP BY requester_id
ORDER BY COUNT(*) DESC
LIMIT 1;

