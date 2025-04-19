-- ex1: datalemur-yoy-growth-rate
WITH yoy_rate_calculation AS(SELECT EXTRACT(Year FROM transaction_date) AS year,
                                    product_id,
                                    spend AS curr_year_spend,
                                    LAG(spend) OVER(PARTITION BY product_id ORDER BY EXTRACT(Year FROM transaction_date)) 
                                    AS prev_year_spend
                              FROM user_transactions
                              ORDER BY product_id, year)
SELECT year, product_id, curr_year_spend, prev_year_spend,
      ROUND(((curr_year_spend - prev_year_spend)*100/prev_year_spend),2) AS yoy_rate
FROM yoy_rate_calculation;

-- ex2: datalemur-card-launch-success
SELECT card_name, issued_amount
FROM (SELECT issue_year, issue_month, card_name, issued_amount,
              RANK() OVER(PARTITION BY card_name ORDER BY issue_year ASC, issue_month ASC) 
              AS rank
      FROM monthly_cards_issued) AS cards_launch_month_rank
WHERE rank = 1
ORDER BY issued_amount DESC;

-- ex3: datalemur-third-transaction
WITH third_trans_table AS(SELECT *,
                            LEAD(transaction_date, 2) 
                            OVER(PARTITION BY user_id ORDER BY transaction_date) AS rd_trans_date
                    FROM transactions
                    ORDER BY user_id)
SELECT b.user_id, b.spend, a.rd_trans_date
FROM third_trans AS a
INNER JOIN transactions AS b ON a.rd_trans_date = b.transaction_date;

-- ex4: datalemur-histogram-users-purchases
WITH most_recent_trans AS(SELECT user_id, count(*) AS purchase_count, transaction_date,
                                  RANK() OVER(PARTITION BY user_id 
                                  ORDER BY transaction_date DESC)
                          FROM user_transactions
                          GROUP BY user_id, transaction_date
                          ORDER BY user_id)
SELECT transaction_date, user_id, purchase_count
FROM most_recent_trans
WHERE rank = 1
ORDER BY transaction_date;

-- ex5: datalemur-rolling-average-tweets
SELECT user_id, tweet_date,
      ROUND(AVG(tweet_count) 
            OVER(PARTITION BY user_id 
            ORDER BY tweet_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
      ,2) AS rolling_avg_3rd
FROM tweets;

-- ex6: datalemur-repeated-payments
WITH ten_min_diff AS(
            WITH next_timeline AS
                  (SELECT merchant_id,
                          credit_card_id,
                          amount,
                          transaction_timestamp AS timestamp,
                          LEAD(transaction_timestamp) 
                              OVER(PARTITION BY credit_card_id 
                                    ORDER BY transaction_timestamp) AS next_timestamp,
                          LEAD(amount)
                              OVER(PARTITION BY credit_card_id 
                                    ORDER BY transaction_timestamp) AS next_amount
                  FROM transactions)
            SELECT merchant_id, credit_card_id,
                   timestamp, next_timestamp, 
                   amount, next_amount,
                   ROUND(EXTRACT(EPOCH FROM(next_timestamp - timestamp))/60) AS minute_diff
            FROM next_timeline
            WHERE ROUND(EXTRACT(EPOCH FROM(next_timestamp - timestamp))/60) <= 10
              AND amount = next_amount)
SELECT COUNT(*) AS payment_count
FROM ten_min_diff;

-- ex7: datalemur-highest-grossing
WITH total_spend_table AS(SELECT category,
                                  product,
                                  SUM(spend) AS total_spend,
                                  RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) AS rank
                          FROM product_spend
                          WHERE EXTRACT(year FROM transaction_date) = 2022
                          GROUP BY category, product)
SELECT category, product, total_spend
FROM total_spend_table
WHERE rank <= 2;

-- ex8: datalemur-top-fans-rank
WITH number_of_popular_songs AS(SELECT a.artist_name,
                               COUNT(s.song_id) AS count_of_songs,
                               DENSE_RANK() OVER(ORDER BY COUNT(s.song_id) DESC) AS artist_rank
                        FROM artists AS a
                        JOIN songs AS s ON a.artist_id = s.artist_id
                        JOIN global_song_rank AS g ON s.song_id = g.song_id
                        WHERE g.rank <= 10
                        GROUP BY a.artist_name
                        ORDER BY COUNT(s.song_id) DESC)
SELECT artist_name, artist_rank
FROM number_of_popular_songs
WHERE artist_rank <= 5;
