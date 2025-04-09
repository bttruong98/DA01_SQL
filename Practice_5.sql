-- ex1: hackerrank-average-population-of-each-continent
SELECT COUNTRY.Continent, FLOOR(AVG(CITY.Population))
FROM Country
INNER JOIN City
ON CITY.CountryCode = COUNTRY.Code
GROUP BY COUNTRY.Continent;

-- ex2: datalemur-signup-confirmation-rate
SELECT 
ROUND(SUM(CASE WHEN t.signup_action = 'Confirmed' THEN 1 ELSE 0 END)/CAST(COUNT(*) AS DECIMAL),2) AS signup_action
FROM emails AS e
INNER JOIN texts AS t
ON e.email_id = t.email_id
LIMIT 5;

-- ex3: datalemur-time-spent-snaps
SELECT age_bucket,
       ROUND(SUM(CASE WHEN act.activity_type = 'send' THEN time_spent ELSE 0 END)*100/
       (SUM(CASE WHEN act.activity_type = 'send' THEN time_spent ELSE 0 END)
       +SUM(CASE WHEN act.activity_type = 'open' THEN time_spent ELSE 0 END)),2) AS send_perc,
       ROUND(SUM(CASE WHEN act.activity_type = 'open' THEN time_spent ELSE 0 END)*100
       (SUM(CASE WHEN act.activity_type = 'send' THEN time_spent ELSE 0 END)/
       +SUM(CASE WHEN act.activity_type = 'open' THEN time_spent ELSE 0 END)),2) AS open_perc
FROM activities AS act
LEFT JOIN age_breakdown AS age
ON act.user_id = age.user_id
GROUP BY age_bucket
ORDER BY age_bucket;

-- ex4: datalemur-supercloud-customer
SELECT c.customer_id
FROM customer_contracts as c
LEFT JOIN products as p
ON c.product_id = p.product_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT p.product_category) = 3;

-- ex5: leetcode-the-number-of-employees-which-report-to-each-employee
SELECT emp.employee_id,
       emp.name,
       COUNT(mng.employee_id) AS reports_count,
       ROUND(AVG(mng.age)) AS average_age
FROM Employees AS emp
JOIN Employees AS mng
ON emp.employee_id = mng.reports_to
GROUP BY emp.employee_id, emp.name
ORDER BY employee_id;

-- ex6: leetcode-list-the-products-ordered-in-a-period
SELECT p.product_name, sum(o.unit) AS unit
FROM Orders AS o
LEFT JOIN Products AS p
ON o.product_id = p.product_id
WHERE EXTRACT(Month FROM o.order_date) = '02'
    AND EXTRACT(Year FROM o.order_date) = '2020'
GROUP BY p.product_name
HAVING sum(o.unit) >= 100;

-- ex7: leetcode-sql-page-with-no-likes
SELECT p.page_id
FROM pages AS p
LEFT JOIN page_likes AS pl
ON pl.page_id = p.page_id
WHERE pl.liked_date IS NULL
ORDER BY p.page_id;
