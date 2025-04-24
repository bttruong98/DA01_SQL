-- Change the datatype of all the columns
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER Column ordernumber TYPE BIGINT USING ordernumber::BIGINT,
ALTER Column quantityordered TYPE INT USING quantityordered::INT,
ALTER Column priceeach TYPE DECIMAL(10,2) USING priceeach::DECIMAL,
ALTER Column orderlinenumber TYPE INT USING orderlinenumber::INT,
ALTER Column sales TYPE DECIMAL(20,2) USING sales::DECIMAL,
ALTER Column orderdate TYPE DATE USING orderdate::DATE,
ALTER Column status TYPE VARCHAR(20),
ALTER Column productline TYPE VARCHAR(50),
ALTER Column msrp TYPE INT USING msrp::INT,
ALTER Column productcode TYPE VARCHAR(15),
ALTER Column customername TYPE VARCHAR(100),
ALTER Column phone TYPE VARCHAR(20),
ALTER Column addressline1 TYPE VARCHAR(100),
ALTER Column addressline2 TYPE VARCHAR(100),
ALTER Column city TYPE VARCHAR(50),
ALTER Column state TYPE VARCHAR(50),
ALTER Column postalcode TYPE VARCHAR(15),
ALTER Column country TYPE VARCHAR(50),
ALTER Column territory TYPE VARCHAR(50),
ALTER Column contactfullname TYPE VARCHAR(100),
ALTER Column dealsize TYPE VARCHAR(20)

-- Check if ordernumber, quantityordered, priceeach, orderlinenumber, sales, orderdate IS NULL
SELECT * 
FROM SALES_DATASET_RFM_PRJ
WHERE ordernumber IS NULL
OR quantityordered IS NULL
OR priceeach IS NULL
OR orderlinenumber IS NULL
OR sales IS NULL
OR orderdate IS NULL

-- Add column contactlastname, contactfirstname, which are split from contactfullname
-- Capitalize first name and last name
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD column contactfirstname VARCHAR(50),
ADD column contactlastname VARCHAR(50)

UPDATE SALES_DATASET_RFM_PRJ
SET contactfirstname = CONCAT
			(
			UPPER(LEFT(contactfullname,1)),RIGHT(LEFT(contactfullname, POSITION('-' IN contactfullname)-1),
			LENGTH(LEFT(contactfullname, POSITION('-' IN contactfullname)-1))-1)
			),
    contactlastname =  CONCAT
			(
			UPPER(LEFT(RIGHT(contactfullname, 1 - (POSITION('-' IN contactfullname)+1)),1)),
			SUBSTRING(contactfullname FROM POSITION('-' IN contactfullname)+2)
			);

SELECT * FROM SALES_DATASET_RFM_PRJ

--  Add column Qtr_ID, Month_ID, Year_ID
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD column Qtr_ID SMALLINT,
ADD	column Month_ID SMALLINT,
ADD column Year_ID SMALLINT;

UPDATE SALES_DATASET_RFM_PRJ
SET qtr_id = EXTRACT(Quarter FROM orderdate),
	month_id = EXTRACT(Month FROM orderdate),
	year_id = EXTRACT(Year FROM orderdate)

SELECT * FROM SALES_DATASET_RFM_PRJ

-- Find outliers for the column quantityordered
SELECT 
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quantityordered) AS median,
  AVG(quantityordered) AS mean
FROM SALES_DATASET_RFM_PRJ;

/* WITH cte AS (SELECT *,
                     (SELECT AVG(quantityordered) FROM SALES_DATASET_RFM_PRJ) AS avg,
                     (SELECT STDDEV(quantityordered) FROM SALES_DATASET_RFM_PRJ) AS stddev
                FROM SALES_DATASET_RFM_PRJ),
twt_outlier AS (
		SELECT *, (quantityordered-avg)/stddev AS z_score
		FROM cte
		WHERE abs((quantityordered-avg)/stddev) > 3
		) */
			
WITH bounds AS
(SELECT Q1,
	Q3,
	IQR,
	Q1 - 1.5*IQR AS min_value,
    	Q3 + 1.5*IQR AS max_value
FROM (SELECT		
	  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS Q1,
	  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) AS Q3,
	  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantityordered) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
	FROM SALES_DATASET_RFM_PRJ))
SELECT * FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered < (SELECT min_value FROM bounds)
OR quantityordered > (SELECT max_value FROM bounds)

-- Replace outliers with average order quantity (Not run yet)
UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = (SELECT AVG(quantityordered)
			FROM SALES_DATASET_RFM_PRJ)
WHERE quantityordered IN (SELECT quantityordered FROM twt_outlier)

SELECT * FROM SALES_DATASET_RFM_PRJ;

-- Save into a new table
SELECT * INTO sales_dataset_rfm_prj_clean
FROM SALES_DATASET_RFM_PRJ;

