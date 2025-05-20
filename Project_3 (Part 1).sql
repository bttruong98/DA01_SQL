SELECT * FROM sales_dataset_rfm_prj_clean

-- Revenue for each product line, year and deal size
SELECT productline, year_id, dealsize, SUM(sales) AS revenue
FROM sales_dataset_rfm_prj_clean
GROUP BY productline, year_id, dealsize
ORDER BY productline, year_id, dealsize DESC

-- Which month has the highest revenue for each year
WITH cte AS
(SELECT month_id, 
		year_id, 
		order_number,
		revenue,
		SUM(revenue) OVER(PARTITION BY year_id, month_id) AS cummulative_sum
FROM (SELECT month_id, year_id, ordernumber AS order_number, SUM(sales) AS revenue
		FROM sales_dataset_rfm_prj_clean
		GROUP BY month_id, year_id, ordernumber
		ORDER BY year_id, month_id)),
cte_2 AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY year_id ORDER BY year_id, cummulative_sum DESC) AS rank 
FROM cte)
SELECT month_id, year_id, revenue, order_number FROM cte_2
WHERE rank = 1

-- Which product line has the highest revenue in November
SELECT month_id, productline AS product_line,
		SUM(sales) AS revenue
FROM sales_dataset_rfm_prj_clean
WHERE month_id = 11
GROUP BY month_id, product_line
ORDER BY revenue DESC
LIMIT 1

-- Which product line has the best revenue each year
SELECT year_id, product_line, revenue
FROM (SELECT year_id, productline AS product_line,
			SUM(sales) AS revenue,
			RANK() OVER(PARTITION BY year_id ORDER BY SUM(sales) DESC)
	  FROM sales_dataset_rfm_prj_clean
	  GROUP BY year_id, product_line
	  ORDER BY year_id, revenue DESC)
WHERE rank = 1

-- RFM Analysis
WITH customer_rfm AS
(SELECT customername, 
		current_date - MAX(orderdate)	AS R,
		COUNT(DISTINCT ordernumber) AS F,
		SUM(sales) AS M
FROM sales_dataset_rfm_prj
GROUP BY customername),
rfm_score AS
(SELECT customername,
		ntile(5) OVER(ORDER BY R) AS R_score,
		ntile(5) OVER(ORDER BY F) AS F_score,
		ntile(5) OVER(ORDER BY M) AS M_score
FROM customer_rfm),
rfm_final AS
(SELECT customername,
		CAST(R_score AS varchar)||CAST(F_score AS varchar)||CAST(M_score AS varchar) AS rfm_score
FROM rfm_score)
SELECT z.segment, count(*)
FROM (SELECT x.customername, y.segment 
		FROM rfm_final x
		JOIN segment_score y ON x.rfm_score = y.scores) z
GROUP BY segment
ORDER BY count(*)
		



