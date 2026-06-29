/*
E-commerce Analytical Insights
Dataset: Olist Brazilian E-commerce
Purpose:
Derive customer, revenue, logistics, product, payment,
and satisfaction insights to support business decision-making.
*/

SET search_path to ecommerce

-- A. CUSTOMER & GEOGRAPHY ANALYSIS

-- 1. States with highest number of customers
 SELECT 
  customer_state,
  count(DISTINCT customer_unique_id) AS occurrences
 FROM ecommerce.olist_customers
 GROUP BY customer_state
 ORDER BY occurrences DESC
 
-- 2. Cities generating the most orders
SELECT
      c.customer_city,
      COUNT(o.order_id) AS total_count
FROM olist_customers c
JOIN olist_orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY total_count DESC;

-- 3. Percentage of repeat customers.
WITH order_count AS (
SELECT 
     customer_unique_id, 
     count(order_id) AS order_count
FROM olist_orders o
JOIN olist_customers c
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id	
)
SELECT 
   round(count(case when order_count > 1 THEN 1 END)*100.00/count(*),2)
       AS repart_percantage
FROM order_count


SELECT * from olist_orders

-- 4. Average number of orders per customer
SELECT
      round(AVG(order_count),2) AS AVG_no_of_orders
	  FROM(
SELECT
      customer_id,
	  count(order_id) AS order_count
FROM olist_orders
GROUP by customer_id
)s;

-- 5. States contributing the highest revenues

SELECT 
  c.customer_state,
  SUM(oi.price) as total_revenues
FROM olist_customers c
      JOIN olist_orders o
      ON c.customer_id = o.customer_id
	  JOIN olist_order_items oi 
	  ON o.order_id = oi.order_id	  
GROUP BY c.customer_state
ORDER BY total_revenues DESC

-- 6. Top 10 highest spending customers (CLV)
  SELECT 
        c.customer_unique_id,
		SUM(oi.price) AS total_spending
FROM olist_customers c
JOIN olist_orders o
ON c.customer_id = o.customer_id
JOIN olist_order_items oi 
ON o.order_id = oi.order_id
GROUP BY  c.customer_unique_id
ORDER by total_spending DESC
LIMIT 10


-- B. ORDER & LOGISTICS PERFORMANCE 

-- 2. Difference between estimated and actual delivery
SELECT 
   order_id,
   order_delivered_customer_date,
   order_estimated_delivery_date,
  (order_delivered_customer_date - order_estimated_delivery_date) AS
       estimate_and_actual_diff
FROM olist_orders

-- 3. Count of late deliveries
SELECT 
   count(order_id)
from olist_orders
WHERE order_delivered_customer_date > order_estimated_delivery_date

-- 4. Days taken from purchase -> delivery 
SELECT 
  order_purchase_timestamp,
  order_delivered_customer_date,
  order_estimated_delivery_date,
  (order_delivered_customer_date - order_purchase_timestamp) as actual_delivery_days,
  (order_estimated_delivery_date - order_purchase_timestamp) as estimated_delivery_days
FROM olist_orders
WHERE order_delivered_customer_date is not null

-- 5. Sellers with best delivery performance

select 
    oi.seller_id,
    date_trunc('second',
    AVG(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days;

-- 6. Sellers with worst delivery delays
select 
    oi.seller_id,
    date_trunc('second',
    AVG(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days desc;

-- 7. States with slowest delivery times
select 
    c.customer_state, 
    date_trunc('second', avg(o.order_delivered_customer_date - o.order_purchase_timestamp)) 
        as avg_delivery_days
from olist_customers c
left join olist_orders o
    on o.customer_id = c.customer_id
where o.order_delivered_customer_date is not null
group by c.customer_state
order by avg_delivery_days desc;

-- 8. Delivery time distribution per category
select 
    p.product_category_name,
    date_trunc('second', avg(o.order_delivered_customer_date - o.order_purchase_timestamp))
        as avg_delivery_duration
from olist_orders o
join olist_order_items oi 
    on o.order_id = oi.order_id
join olist_products p
    on p.product_id = oi.product_id
where o.order_delivered_customer_date is not null
group by p.product_category_name
order by avg_delivery_duration;

-- C. PRODUCT & CATEGORY ANALYTICS

-- 1. Units sold per category
SELECT 
   p.product_category_name,
   pct.product_category_name_english,
   COUNT(*) AS units_sold
 FROM olist_order_items oi
 JOIN olist_products p
 ON oi.product_id = p.product_id
 LEFT JOIN product_category_name_translation pct
 ON p.product_category_name = pct.product_category_name
 GROUP BY p.product_category_name,pct.product_category_name_english
 ORDER BY units_sold DESC;
   
-- 2. Revenue by category
SELECT 
     p.product_category_name,
	 pct.product_category_name_english,
	 SUM(oi.price) AS total_Revenue_category
FROM olist_order_items oi
JOIN olist_products p
     ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY p.product_category_name , pct.product_category_name_english
ORDER BY total_Revenue_category desc
LIMIT 10;

-- 3. Average price by category
SELECT 
     p.product_category_name,
	 pct.product_category_name_english,
	 round(AVG(oi.price),2) AS total_avg_category
FROM olist_order_items oi
JOIN olist_products p
     ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY p.product_category_name , pct.product_category_name_english
ORDER BY total_avg_category desc
LIMIT 10;

-- 4. Average freight cost by category
SELECT 
     p.product_category_name,
	 pct.product_category_name_english,
	 round(AVG(oi.freight_value),2) AS freight_avg_category
FROM olist_order_items oi
JOIN olist_products p
     ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY p.product_category_name , pct.product_category_name_english
ORDER BY freight_avg_category desc
LIMIT 10;

-- 5. a. Correlation between weight and price

SELECT 
      corr(p.product_weight_g , oi.price) AS weight_price_Correlation
	 FROM olist_products p 
	 join olist_order_items oi
  ON p.product_id = oi.product_id
  WHERE p.product_weight_g is not null
   AND oi.price is not null;
	
-- 5. b. Weight bucket price analysis
select
    case 
        when p.product_weight_g < 500  then '0–500g'
        when p.product_weight_g < 1000 then '500–1000g'
        when p.product_weight_g < 2000 then '1000–2000g'
        when p.product_weight_g < 5000 then '2000–5000g'
        else '5000g+'
    end as weight_bucket,
    round(avg(oi.price),2) as avg_price
from olist_products p
join olist_order_items oi
    on p.product_id = oi.product_id
where p.product_weight_g is not null
group by weight_bucket
order by avg_price;

-- 6. Late delivery percentage per category
select 
    p.product_category_name, 
    pct.product_category_name_english,
    round(count(case when o.order_delivered_customer_date > o.order_estimated_delivery_date 
        then 1 end) * 100.0 / count(*),2) as late_delivery_percentage
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
join olist_products p
    on p.product_id = oi.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
where o.order_delivered_customer_date is not null
group by p.product_category_name, pct.product_category_name_english
order by late_delivery_percentage;

-- 7. Top 10 most profitable categories

SELECT 
     p.product_category_name,
	 pct.product_category_name_english,
	 SUM(oi.price - oi.freight_value) AS profit
FROM olist_products p
JOIN olist_order_items oi 
ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pct
ON p.product_category_name = pct.product_category_name
GROUP BY  p.product_category_name, pct.product_category_name_english
ORDER BY profit DESC
LIMIT 10

-- D. PAYMENT ANALYSIS

-- 1. Most common payment types
SELECT
      payment_type,
      Count(payment_type) AS count_payment_type
FROM olist_order_payments
GROUP BY payment_type
ORDER BY count_payment_type DESC

SELECT * FROM olist_order_payments

-- 2. Installment ranges usage
SELECT
     case 
	     WHEN payment_installments = 1 then '1 installments'
		 WHEN payment_installments BETWEEN 2 and 3 THEN '2-3 installments '
         WHEN payment_installments BETWEEN 4 and 6 THEN '4-6 installments '
		 WHEN payment_installments BETWEEN 7 and 12 THEN '7-12 installments '
		 ELSE '13+installments'
        END as  installment_range,
     	COUNT(*) as installment_count
FROM olist_order_payments
GROUP BY installment_range
ORDER BY installment_count DESC;

-- 3. Percentage of multiple-installment payments
select 
    round(count(case when payment_installments > 1 then 1 end) * 100.0 / count(*),2) 
        as multiple_installment_percent
from olist_order_payments;


-- 4. Revenue by payment type
SELECT 
     op.payment_type,
	 SUM(oi.price) AS revenue
FROM olist_order_payments op
JOIN olist_order_items oi
ON op.order_id = oi.order_id
GROUP by op.payment_type
ORDER by revenue DESC

-- 5. Average order value by payment type
WITH order_total as(
SELECT 
      order_id , SUM(price) as order_value
	  FROM olist_order_items
GROUP BY order_id
)
SELECT
      payment_type,
	  round(AVG(order_value),2) as avg_order_value
	 FROM order_total o
	JOIN olist_order_payments op
	 on o.order_id = op.order_id
  GROUP BY payment_type
  ORDER By avg_order_value DESC
  
-- E. REVIEW & CUSTOMER SATISFACTION
SELECT * FROM olist_order_reviews
-- 1. Average review score
SELECT 
    AVG(review_score)
FROM olist_order_reviews

-- 2. Late delivery impact on reviews
select
    case 
        when o.order_delivered_customer_date > o.order_estimated_delivery_date then 'Late Delivery'
        else 'On-Time Delivery'
    end as delivery_status,
    round(avg(r.review_score), 2) as avg_review_score
from olist_orders o
join olist_order_reviews r
    on o.order_id = r.order_id
where o.order_delivered_customer_date is not null
group by delivery_status;

-- 3. Distribution of review scores
select 
    review_score, 
    count(*) as count_review
from olist_order_reviews
group by review_score
order by review_score;

-- 4. Lowest-rated categories
select 
    p.product_category_name, 
    pct.product_category_name_english, 
    round(avg(review_score),2) as avg_review_score 
from olist_order_items oi
join olist_products p 
    on oi.product_id = p.product_id
join olist_order_reviews r
    on r.order_id = oi.order_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by avg_review_score;

-- 5. a. Best-rated sellers
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating desc;

-- 5. b. Worst-rated sellers
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating asc;


-- 6. Average time to respond to reviews
select 
    date_trunc('second', avg(review_answer_timestamp - review_creation_date))  
        as avg_time_to_respond
from olist_order_reviews
where review_answer_timestamp is not null 
  and review_creation_date is not null;


 
