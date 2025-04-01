-- ex1: hackerrank-weather-observation-station-3
SELECT DISTINCT City
FROM Station
WHERE ID % 2 = 0
ORDER BY City;

-- ex2: hackerrank-weather-observation-station-4
SELECT COUNT(*) - COUNT(DISTINCT City) AS Difference
FROM Station;

-- ex3: hackerrank-the-blunder
SELECT CEILING(AVG(Salary) - AVG(Replace(Salary,'0','')*1)) AS Error
FROM Employees;

-- ex4: datalemur-alibaba-compressed-mean
SELECT ROUND(sum(item_count*order_occurrences)::NUMERIC/sum(order_occurrences), 1) AS Mean
FROM items_per_order;

-- ex5: datalemur-matching-skills
SELECT candidate_id
FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(DISTINCT skill) = 3;

-- ex6: datalemur-verage-post-hiatus-1
SELECT user_id,
       MAX(DATE(post_date)) - MIN(DATE(post_date)) AS days_between
FROM posts
WHERE DATE(post_date) BETWEEN '01/01/2021' AND '12/31/2021'
GROUP BY user_id
HAVING COUNT(user_id) >= 2
ORDER BY user_id;

-- ex7: datalemur-cards-issued-difference
SELECT card_name, 
       MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY card_name DESC;

-- ex8: datalemur-non-profitable-drugs
SELECT manufacturer, COUNT(product_id) AS drug_count,
       SUM(cogs) - SUM(total_sales) AS total_losses
FROM pharmacy_sales
WHERE total_sales - cogs < 0
GROUP BY manufacturer
ORDER BY SUM(cogs) - SUM(total_sales) DESC;

-- ex9: leetcode-not-boring-movies
SELECT * FROM Cinema
WHERE ID % 2 <> 0 AND description <> 'boring'
ORDER BY rating DESC;

-- ex10: leetcode-number-of-unique-subject
SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;

-- ex11: leetcode-find-followers-count
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id;

-- ex12:leetcode-classes-more-than-5-students
SELECT Class
FROM Courses
GROUP BY Class
HAVING COUNT(student) >= 5;
