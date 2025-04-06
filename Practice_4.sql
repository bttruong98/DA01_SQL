-- ex1: datalemur-laptop-mobile-viewership.
SELECT 
  COUNT(CASE WHEN device_type = 'laptop' THEN device_type END) AS laptop_views,
  COUNT(CASE WHEN device_type IN ('tablet','phone') THEN device_type END) AS mobile_views
FROM viewership;

-- ex2: datalemur-triangle-judgement
SELECT x, y, z,
    CASE
        WHEN x + y > z AND y + z > x AND x + z > y THEN 'Yes'
        ELSE 'No'
    END AS Triangle
FROM Triangle;

-- ex3: datalemur-uncategorized-calls-percentage
SELECT
    SUM(CASE WHEN COALESCE(call_category, 'n/a') = 'n/a' THEN 1 ELSE 0 END)/COUNT(*) AS uncategorised_call_pct
FROM callers;

-- ex4: datalemur-find-customer-referee
SELECT name
FROM customer
WHERE referee_id IS NULL OR referee_id <> 2;

-- ex5: stratascratch the-number-of-survivors
SELECT survived, 
    SUM(CASE
       WHEN pclass = 1 THEN 1 ELSE 0
    END) AS first_class,
    SUM(CASE
       WHEN pclass = 2 THEN 1 ELSE 0
    END) AS second_class,
    SUM(CASE
       WHEN pclass = 3 THEN 1 ELSE 0
    END) AS third_class
FROM titanic
GROUP BY survived;
