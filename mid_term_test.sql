-- Question 1:
/* 
Topic: DISTINCT
Tạo danh sách tất cả chi phí thay thế (replacement costs ) khác nhau của các film */
SELECT DISTINCT replacement_cost
FROM film
ORDER BY replacement_cost;

-- Question 2:
/* 
Topic: CASE + GROUP BY
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí 
thay thế trong các phạm vi chi phí sau
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau
1.	Low: 9.99 - 19.99
2.	Medium: 20.00 - 24.99
3.	High: 25.00 - 29.99
Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “Low”? */
SELECT
	CASE 
		WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'Low'
		WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'Medium'
		WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'High' END Category,
	COUNT(*) AS Quantity
FROM film
GROUP BY CASE 
			WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'Low'
			WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'Medium'
			WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'High' END
ORDER BY COUNT(*) DESC;

-- Question 3:
/*
Topic: JOIN
Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và tên danh mục (category_name) 
được sắp xếp theo độ dài giảm dần. Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.
Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?
*/
SELECT f.title AS film_title, f.length, c.name AS category_name 
FROM film AS f
INNER JOIN film_category AS fc 
		ON f.film_id = fc.film_id
INNER JOIN category AS c
		ON fc.category_id = c.category_id
WHERE c.name = 'Drama' OR c.name = 'Sports'
ORDER BY f.length DESC;

-- Question 4:
/*
Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).
Question: Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?
*/
SELECT c.name AS category_name, COUNT(*)||' titles' AS quantity
FROM film AS f
INNER JOIN film_category AS fc 
		ON f.film_id = fc.film_id
INNER JOIN category AS c
		ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY COUNT(*) DESC;

-- Question 5:
/*
Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên cũng như số lượng phim họ tham gia.
Question: Diễn viên nào đóng nhiều phim nhất?
*/
SELECT CONCAT(a.first_name,' ', a.last_name), count(*)
FROM actor AS a
INNER JOIN film_actor AS f
		ON a.actor_id = f.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY COUNT(*) DESC;

SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
INNER JOIN film_actor AS f
		ON a.actor_id = f.actor_id
WHERE a.first_name = 'SUSAN' AND a.last_name = 'DAVIS'
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY actor_id; -- This show Susan Davis has two actor_ids, 
-- which also means that there are two actors/acttresses that have the same name

-- Question 6:
/*
Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.
Question: Có bao nhiêu địa chỉ như vậy?
*/
SELECT COUNT(*) AS not_found
FROM address AS a
LEFT JOIN customer AS c
		ON a.address_id = c.address_id
WHERE c.first_name IS NULL and c.last_name is NULL;

-- Question 7:
/*
Topic: JOIN & GROUP BY
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố 
Question: Thành phố nào đạt doanh thu cao nhất?
*/
SELECT ci.city, SUM(pa.amount)
FROM city AS ci
INNER JOIN address AS ad
		ON ci.city_id = ad.city_id
INNEr JOIN customer AS cu
		ON ad.address_id = cu.address_id
INNER JOIN payment AS pa
		ON pa.customer_id = cu.customer_id
GROUP BY ci.city, cu.customer_id
ORDER BY SUM(pa.amount) DESC;

-- Question 8:
/*
Topic: JOIN & GROUP BY
Task: Tạo danh sách trả ra 2 cột dữ liệu: 
-	cột 1: thông tin thành phố và đất nước ( format: “city, country")
-	cột 2: doanh thu tương ứng với cột 1
Question: thành phố của đất nước nào đat doanh thu thấp?? nhất
*/
SELECT CONCAT(ci.city,', ',co.country), SUM(pa.amount)
FROM city AS ci
INNER JOIN country AS co
		ON ci.country_id = co.country_id
INNER JOIN address AS ad
		ON ci.city_id = ad.city_id
INNEr JOIN customer AS cu
		ON ad.address_id = cu.address_id
INNER JOIN payment AS pa
		ON pa.customer_id = cu.customer_id
GROUP BY ci.city_id, co.country, cu.customer_id
ORDER BY SUM(pa.amount);




