-- ex1: hackerank-revising-the-select-query
SELECT Name FROM City
WHERE CountryCode = 'USA' AND Population > 120000;

-- ex2: hackerank-japanese-cities-attributes
SELECT * FROM City
WHERE CountryCode = 'JPN';

-- ex3: hackerank-weather-observation-station-1
SELECT City, State FROM Station;

-- ex4: hackerank-weather-observation-station-6
SELECT DISTINCT City 
FROM Station
WHERE (City LIKE 'A%')
   OR (City LIKE 'E%')
   OR (City LIKE 'I%')
   OR (City LIKE 'O%')
   OR (City LIKE 'U%');

-- ex5: hackerank-weather-observation-station-7
SELECT DISTINCT City 
FROM Station
WHERE (City LIKE '%a') 
   OR (City LIKE '%e') 
   OR (City LIKE '%i') 
   OR (City LIKE '%o') 
   OR (City LIKE '%u');

-- ex6: hackerank-weather-observation-station-9
SELECT DISTINCT City
FROM Station
WHERE City NOT LIKE 'a%'
  AND City NOT LIKE 'e%'
  AND City NOT LIKE 'i%'
  AND City NOT LIKE 'o%'
  AND City NOT LIKE 'u%';

-- ex7: hackerank-name-of-employees
SELECT Name FROM Employee
ORDER BY Name ASC;

-- ex8: hackerank-salary-of-employees
SELECT Name FROM Employee
WHERE salary >= 2000 AND months < 10
ORDER BY employee_id ASC;

-- ex9: leetcode-recyclable-and-low-fat-products
SELECT Product_id FROM Products
WHERE Low_fats = "Y" AND Recyclable = "Y";

-- ex10: leetcode-find-customer-referee
SELECT name FROM Customer
WHERE referee_id IS NULL OR referee_id <> 2;

-- ex11: leetcode-big-countries
SELECT name, population, area FROM World
WHERE area >= 3000000 OR population >= 25000000;

-- ex12: leetcode-article-views
SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY id ASC;

-- ex13: datalemur-tesla-unfinished-part
SELECT part, assembly_step
FROM parts_assembly
WHERE finish_date IS NULL;

-- ex14: datalemur-lyft-driver-wages
SELECT * FROM lyft_drivers
WHERE yearly_salary < 30000 OR yearly_salary >= 70000;

-- ex15: datalemur-find-the-advertising-channel
SELECT advertising_channel FROM uber_advertising
WHERE money_spent > 100000 AND year = 2019;
