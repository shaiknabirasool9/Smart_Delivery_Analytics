-- ----------------------------
-- Problem 1: Delivery Delays
-- ----------------------------
-- q1. which restaurants are associated with the longest average delivery times?
select r.restaurant_id,
       r.restaurant_name,
       round(avg(timestampdiff(minute, o.order_time, o.delivered_time)), 2) as avg_delivery_time
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
where o.status = 'Delivered'
group by r.restaurant_id,
         r.restaurant_name
order by avg_delivery_time desc;

-- q2. which delivery partners have the highest average time per order?

select d.partner_id,
       d.partner_name,
       round(avg(timestampdiff(minute, o.order_time, o.delivered_time)), 2) as avg_delivery_time
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
where o.status = 'Delivered'
group by d.partner_id,
         d.partner_name
order by avg_delivery_time desc;

-- q3. which cities experience the most delivery delays?

select c.city,
       round(avg(timestampdiff(minute, o.order_time, o.delivered_time)), 2) as avg_delivery_time
from customers c
join orders o
on c.customer_id = o.customer_id
where o.status = 'Delivered'
group by c.city
order by avg_delivery_time desc;

-- q4. are delivery delays increasing or decreasing over time?

select date_format(order_time, '%Y-%m') as month,
       round(avg(timestampdiff(minute, order_time, delivered_time)), 2) as avg_delivery_time
from orders
where status = 'Delivered'
group by date_format(order_time, '%Y-%m')
order by month;
-- ------------------------------
-- Problem 2: Order Cancellations
-- ------------------------------
-- q1. which restaurants receive the highest volume of cancellations?

select r.restaurant_name,
       count(*) as cancelled_orders
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
where o.status = 'Cancelled'
group by r.restaurant_name
order by cancelled_orders desc;

-- q2. which cities have the highest cancellation rates by percentage?

select c.city,
       count(case when o.status = 'Cancelled' then 1 end) as cancelled_orders,
       count(*) as total_orders,
       round(
             count(case when o.status = 'Cancelled' then 1 end) * 100.0 /
             count(*),
             2
       ) as cancellation_rate
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.city
order by cancellation_rate desc;

-- q3. is there a correlation between delivery delays and cancellations?

select status,
       round(avg(timestampdiff(minute, order_time, delivered_time)), 2) as avg_delivery_time
from orders
where delivered_time is not null
group by status;

-- q4. on which days and at which times do cancellations peak?

select dayname(order_time) as day_name,
       hour(order_time) as order_hour,
       count(*) as cancelled_orders
from orders
where status = 'Cancelled'
group by day_name,
         order_hour
order by cancelled_orders desc;
-- -------------------------------
-- Problem 3: Revenue Optimisation
-- -------------------------------
-- q1. which restaurants generate the highest total revenue?

select r.restaurant_name,
       round(sum(o.order_amount), 2) as total_revenue
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
group by r.restaurant_name
order by total_revenue desc;

-- q2. which cities contribute the most to overall company revenue?

select c.city,
       round(sum(o.order_amount), 2) as total_revenue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.city
order by total_revenue desc;

-- q3. which payment methods are most popular and most valuable?

select p.payment_mode,
       count(*) as total_transactions,
       round(sum(p.amount), 2) as total_revenue
from payments p
group by p.payment_mode
order by total_revenue desc;

-- q4. what are the monthly revenue trends over the past year?

select date_format(order_time, '%Y-%m') as month,
       round(sum(order_amount), 2) as monthly_revenue
from orders
group by date_format(order_time, '%Y-%m')
order by month;
-- -------------------------
-- Problem 4: Customer Retention
-- -------------------------
-- q1. who are the top 10 most valuable customers by lifetime spending?

select c.customer_id,
       c.customer_name,
       round(sum(o.order_amount), 2) as lifetime_spending
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,
         c.customer_name
order by lifetime_spending desc
limit 10;

-- q2. which customers order most frequently, and what is their average order value?

select c.customer_id,
       c.customer_name,
       count(o.order_id) as total_orders,
       round(avg(o.order_amount), 2) as avg_order_value
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,
         c.customer_name
order by total_orders desc;

-- q3. which customers have gone inactive in the last 90 days?

select customer_id,
       customer_name
from customers
where customer_id in
(
    select customer_id
    from customer_behavior
    where last_order_days > 90
);

-- q4. what behavioural patterns signal that a customer is about to churn?

select customer_id,
       total_orders,
       total_spending,
       avg_order_value,
       last_order_days,
       churn_flag
from customer_behavior
order by last_order_days desc,
         total_orders;
-- -----------------------------
-- Problem 5: Delivery Partner Performance
-- -----------------------------
-- q1. who are the fastest delivery partners based on average delivery time?

select d.partner_id,
       d.partner_name,
       round(avg(timestampdiff(minute, o.order_time, o.delivered_time)), 2) as avg_delivery_time
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
where o.status = 'Delivered'
group by d.partner_id,
         d.partner_name
order by avg_delivery_time;

-- q2. which partners handle the highest volume of successful deliveries?

select d.partner_id,
       d.partner_name,
       count(*) as successful_deliveries
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
where o.status = 'Delivered'
group by d.partner_id,
         d.partner_name
order by successful_deliveries desc;

-- q3. which partners are associated with the most cancellations or delays?

select d.partner_id,
       d.partner_name,
       sum(case when o.status = 'Cancelled' then 1 else 0 end) as cancelled_orders,
       round(avg(timestampdiff(minute, o.order_time, o.delivered_time)), 2) as avg_delivery_time
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
group by d.partner_id,
         d.partner_name
order by cancelled_orders desc,
         avg_delivery_time desc;

-- q4. what is the average customer rating received per delivery partner?

select d.partner_id,
       d.partner_name,
       round(avg(r.customer_rating), 2) as avg_customer_rating
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
join ratings r
on o.order_id = r.order_id
group by d.partner_id,
         d.partner_name
order by avg_customer_rating desc;
