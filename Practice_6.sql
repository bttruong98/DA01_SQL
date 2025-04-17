-- ex1: datalemur-duplicate-job-listings
SELECT COUNT(*) AS duplicate_companies
FROM(SELECT company_id, description, COUNT(*)
     FROM job_listings
     GROUP BY company_id, title, description
     HAVING COUNT(*) >= 2) AS new_table;

-- ex2: datalemur-highest-grossing

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
