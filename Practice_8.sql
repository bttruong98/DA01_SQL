-- ex1: leetcode-mmediate-food-delivery
WITH im_or_sche AS 
                (WITH first_order AS (SELECT customer_id,
                                            delivery_id,
                                            order_date,
                                            FIRST_VALUE(order_date) OVER(PARTITION BY      customer_id ORDER BY order_date) AS earliest_order,
                                            customer_pref_delivery_date
                                    FROM Delivery)
                SELECT customer_id, delivery_id, order_date, customer_pref_delivery_date
                FROM first_order
                WHERE order_date = earliest_order)
SELECT ROUND(COUNT(CASE WHEN order_date = customer_pref_delivery_date
                  THEN 1 END)*100/COUNT(*),2) AS immediate_percentage
FROM im_or_sche;

-- ex2: leetcode-game-play-analysis
WITH login_time AS (SELECT player_id, device_id, event_date,
                            LEAD(event_date) OVER(PARTITION BY player_id) AS next_login,
                            LEAD(event_date) OVER(PARTITION BY player_id) - event_date AS date_diff
                    FROM Activity)
SELECT ROUND(COUNT(CASE WHEN date_diff = 1 THEN player_id END)
        /CAST(COUNT(DISTINCT player_id) AS DECIMAL), 2) AS fraction
FROM login_time;

-- ex3: leetcode-exchange-seats
With new_seat_map AS 
            (SELECT (CASE WHEN (SELECT COUNT(*) FROM Seat)/2 <> 0 AND id = (SELECT MAX(id) FROM Seat) THEN id
            WHEN id%2 = 0 THEN id - 1
            ELSE id + 1 END) AS swapped_id
            FROM seat)
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS id, b.student AS student
FROM new_seat_map AS a
JOIN seat AS b ON a.swapped_id = b.id

-- ex4: leetcode-restaurant-growth
WITH group_visit_date AS(SELECT visited_on, SUM(amount) AS amount
                        FROM customer
                        GROUP BY visited_on)
SELECT visited_on, 
        SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
        ROUND(AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS average_amount
FROM group_visit_date
ORDER BY visited_on
OFFSET 6 ROWS;

-- ex5: leetcode-investments-in-2016
SELECT sum(tiv_2016) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN (SELECT tiv_2015
                    FROM Insurance
                    GROUP BY tiv_2015
                    HAVING COUNT(tiv_2015) > 1)
AND (lat, lon) IN (SELECT lat, lon
                    FROM insurance
                    GROUP BY lat, lon, CONCAT(lat, lon)
                    HAVING count(*) = 1);
-- ex6: leetcode-department-top-three-salaries
WITH highest_salary AS (SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
                        DENSE_RANK() OVER(PARTITION BY d.name ORDER BY salary DESC) AS Rank
                        FROM Employee AS e
                        JOIN Department AS d ON e.departmentID = d.id)
SELECT Department, Employee, Salary
FROM highest_salary
WHERE rank <= 3;

-- ex7: leetcode-last-person-to-fit-in-the-bus
SELECT person_name
FROM(SELECT *, 
        RANK() OVER(ORDER BY turn) AS rank,
        SUM(weight) OVER(ORDER BY turn) AS total_weight
        FROM Queue)
WHERE total_weight <= 1000
ORDER BY rank DESC
LIMIT 1;
-- ex8: leetcode-product-price-at-a-given-date
WITH table1 AS(SELECT DISTINCT product_id,
                FIRST_VALUE(new_price) OVER(PARTITION BY product_id ORDER BY change_date DESC) AS price
                FROM Products
                WHERE change_date <= '2019-08-16'),
table2 AS (SELECT DISTINCT product_id, 10 AS price
            FROM products
            WHERE change_date > '2019-08-16'
            AND product_id NOT IN (SELECT product_id FROM table1))
SELECT product_id, price
FROM table1
UNION
SELECT product_id, price
FROM table2
