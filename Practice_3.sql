-- ex1: hackerrank-more-than-75-marks
SELECT Name
FROM Students
WHERE Marks > 75
ORDER BY RIGHT(name, 3), ID ASC;

-- ex2: leetcode-fix-names-in-a-table
SELECT user_id,
       CONCAT(LEFT(UPPER(name),1),LOWER(SUBSTRING(name,2))) AS name
FROM users
ORDER BY user_id;

-- ex3: datalemur-total-drugs-sales
SELECT manufacturer, '$'||ROUND(SUM(total_sales)/1000000)||' million' AS sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer ASC;

-- ex4: avg-review-ratings
SELECT EXTRACT(month FROM submit_date) AS mth,
       product_id AS product,
       ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY EXTRACT(month FROM submit_date), product_id
ORDER BY EXTRACT(month FROM submit_date), product_id;

-- ex5: teams-power-users
SELECT sender_id, 
        COUNT(message_id) AS message_count
FROM messages
WHERE EXTRACT(Year FROM sent_date) = '2022' 
  AND EXTRACT(Month FROM sent_date) = '08'
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
LIMIT 2;

-- ex6: invalid-tweets
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;

-- ex7: user-activity-for-the-past-30-days
SELECT activity_date AS day,
        COUNT(DISTINCT user_id) AS active_users
FROM activity
WHERE activity_date BETWEEN DATE '2019-07-27' - INTERVAL '29 days' AND '2019-07-28'
GROUP BY activity_date;

-- ex8: number-of-hires-during-specific-time-period
SELECT count(id)
FROM employees
WHERE EXTRACT(MONTH FROM joining_date) BETWEEN '01' AND '07'
  AND EXTRACT(YEAR FROM joining_date) = 2022;

-- ex9: positions-of-letter-a
SELECT POSITION('a' in 'Amika')
FROM worker
LIMIT 1;

-- ex10: macedonian-vintages
SELECT title,
        SUBSTRING(title,length(winery)+2, 4)::NUMERIC
FROM winemag_p2
WHERE country = 'Macedonia';
