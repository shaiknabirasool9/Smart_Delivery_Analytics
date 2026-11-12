
-- Subqueries
-- 61. orders having amount greater than average order amount
select *
from orders
where order_amount >
(
    select avg(order_amount)
    from orders
);

-- 62. customers who spent more than average customer spending
select customer_id,
       sum(order_amount) as total_spending
from orders
group by customer_id
having sum(order_amount) >
(
    select avg(total_spending)
    from
    (
        select sum(order_amount) as total_spending
        from orders
        group by customer_id
    ) as t
);

-- 63. restaurant having maximum revenue
select restaurant_id,
       sum(order_amount) as revenue
from orders
group by restaurant_id
having sum(order_amount) =
(
    select max(revenue)
    from
    (
        select sum(order_amount) as revenue
        from orders
        group by restaurant_id
    ) as t
);

-- 64. customer who placed the highest number of orders
select customer_id,
       count(*) as total_orders
from orders
group by customer_id
having count(*) =
(
    select max(total_orders)
    from
    (
        select count(*) as total_orders
        from orders
        group by customer_id
    ) as t
);

-- 65. restaurants having more orders than average restaurant orders
select restaurant_id,
       count(*) as total_orders
from orders
group by restaurant_id
having count(*) >
(
    select avg(total_orders)
    from
    (
        select count(*) as total_orders
        from orders
        group by restaurant_id
    ) as t
);

-- 66. customers who never placed an order using not exists
select *
from customers c
where not exists
(
    select 1
    from orders o
    where o.customer_id = c.customer_id
);

-- 67. customers who placed at least one order using exists
select *
from customers c
where exists
(
    select 1
    from orders o
    where o.customer_id = c.customer_id
);

-- 68. restaurants that received at least one rating
select *
from restaurants r
where exists
(
    select 1
    from orders o
    join ratings rt
    on o.order_id = rt.order_id
    where o.restaurant_id = r.restaurant_id
);

-- 69. orders having maximum order amount
select *
from orders
where order_amount =
(
    select max(order_amount)
    from orders
);

-- 70. customers whose spending is greater than customer_behavior total_spending
select c.customer_id,
       c.customer_name
from customers c
join customer_behavior cb
on c.customer_id = cb.customer_id
where cb.total_spending >
(
    select avg(total_spending)
    from customer_behavior
);
-- Common Table Expressions (cte)
-- 71. customer spending using cte
with customer_sales as
(
    select customer_id,
           sum(order_amount) as total_spending
    from orders
    group by customer_id
)
select *
from customer_sales
order by total_spending desc;

-- 72. top 10 customers
with customer_sales as
(
    select customer_id,
           sum(order_amount) as total_spending
    from orders
    group by customer_id
)
select *
from customer_sales
order by total_spending desc
limit 10;

-- 73. restaurant revenue
with restaurant_sales as
(
    select restaurant_id,
           sum(order_amount) as revenue
    from orders
    group by restaurant_id
)
select *
from restaurant_sales
order by revenue desc;

-- 74. delivered orders
with delivered_orders as
(
    select *
    from orders
    where status = 'Delivered'
)
select *
from delivered_orders;

-- 75. average revenue by restaurant
with restaurant_sales as
(
    select restaurant_id,
           sum(order_amount) as revenue
    from orders
    group by restaurant_id
)
select avg(revenue)
from restaurant_sales;
-- Window Functions
-- 76. row number by highest order amount
select order_id,
       customer_id,
       order_amount,
       row_number() over(order by order_amount desc) as row_num
from orders;

-- 77. rank customers by spending
select customer_id,
       sum(order_amount) as total_spending,
       rank() over(order by sum(order_amount) desc) as ranking
from orders
group by customer_id;

-- 78. dense rank customers by spending
select customer_id,
       sum(order_amount) as total_spending,
       dense_rank() over(order by sum(order_amount) desc) as ranking
from orders
group by customer_id;

-- 79. previous order amount of each customer
select customer_id,
       order_id,
       order_amount,
       lag(order_amount) over(partition by customer_id order by order_time) as previous_order
from orders;

-- 80. next order amount of each customer
select customer_id,
       order_id,
       order_amount,
       lead(order_amount) over(partition by customer_id order by order_time) as next_order
from orders;

-- 81. running revenue
select order_id,
       order_time,
       order_amount,
       sum(order_amount) over(order by order_time) as running_revenue
from orders;

-- 82. cumulative orders by customer
select customer_id,
       order_id,
       count(*) over(partition by customer_id order by order_time) as cumulative_orders
from orders;

-- 83. highest order for each customer
select *
from
(
    select *,
           row_number() over(partition by customer_id order by order_amount desc) as rn
    from orders
) as t
where rn = 1;

-- 84. second highest order for each customer
select *
from
(
    select *,
           dense_rank() over(partition by customer_id order by order_amount desc) as dr
    from orders
) as t
where dr = 2;

-- 85. latest order of every customer
select *
from
(
    select *,
           row_number() over(partition by customer_id order by order_time desc) as rn
    from orders
) as t
where rn = 1;
-- Views
-- 86. customer order summary
create view vw_customer_orders as
select c.customer_id,
       c.customer_name,
       count(o.order_id) as total_orders,
       sum(o.order_amount) as total_spending
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id,
         c.customer_name;

select *
from vw_customer_orders;

-- 87. restaurant revenue summary
create view vw_restaurant_revenue as
select r.restaurant_id,
       r.restaurant_name,
       sum(o.order_amount) as total_revenue
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
group by r.restaurant_id,
         r.restaurant_name;

select *
from vw_restaurant_revenue;

-- 88. delivery partner performance
create view vw_delivery_performance as
select d.partner_id,
       d.partner_name,
       count(o.order_id) as completed_orders
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
where o.status = 'Delivered'
group by d.partner_id,
         d.partner_name;

select *
from vw_delivery_performance;
-- Stored Procedures
-- 89. get all orders for a customer
delimiter $$

create procedure get_customer_orders(in p_customer_id int)
begin
    select *
    from orders
    where customer_id = p_customer_id;
end $$

delimiter ;

call get_customer_orders(101);

-- 90. revenue of a restaurant
delimiter $$

create procedure get_restaurant_revenue(in p_restaurant_id int)
begin
    select restaurant_id,
           sum(order_amount) as total_revenue
    from orders
    where restaurant_id = p_restaurant_id
    group by restaurant_id;
end $$

delimiter ;

call get_restaurant_revenue(5);
-- Indexes
-- create indexes
create index idx_orders_customer
on orders(customer_id);

create index idx_orders_restaurant
on orders(restaurant_id);

create index idx_orders_status
on orders(status);

create index idx_payments_order
on payments(order_id);

create index idx_ratings_order
on ratings(order_id);

-- view execution plan
explain
select *
from orders
where customer_id = 101;
-- Advanced Business Case Studies
-- 91. monthly revenue
select date_format(order_time, '%Y-%m') as month,
       sum(order_amount) as revenue
from orders
group by date_format(order_time, '%Y-%m')
order by month;

-- 92. average delivery time by restaurant
select r.restaurant_name,
       avg(timestampdiff(minute, o.order_time, o.delivered_time)) as avg_delivery_time
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
where o.status = 'Delivered'
group by r.restaurant_name
order by avg_delivery_time;

-- 93. top 5 cities by revenue
select c.city,
       sum(o.order_amount) as revenue
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.city
order by revenue desc
limit 5;

-- 94. payment mode usage
select payment_mode,
       count(*) as total_transactions
from payments
group by payment_mode
order by total_transactions desc;

-- 95. churned customers
select c.customer_name,
       cb.total_spending,
       cb.last_order_days
from customers c
join customer_behavior cb
on c.customer_id = cb.customer_id
where cb.churn_flag = '1';

-- 96. top rated restaurants
select r.restaurant_name,
       round(avg(rt.customer_rating), 2) as avg_rating
from restaurants r
join orders o
on r.restaurant_id = o.restaurant_id
join ratings rt
on o.order_id = rt.order_id
group by r.restaurant_name
order by avg_rating desc
limit 10;

-- 97. customers with increasing order values
select customer_id,
       order_id,
       order_amount,
       lag(order_amount) over(partition by customer_id order by order_time) as previous_order
from orders;

-- 98. busiest delivery partners
select d.partner_name,
       count(*) as deliveries
from delivery_partners d
join orders o
on d.partner_id = o.partner_id
group by d.partner_name
order by deliveries desc
limit 10;

-- 99. cancelled order percentage
select round(
           100 * sum(case when status = 'Cancelled' then 1 else 0 end) / count(*),
           2
       ) as cancelled_percentage
from orders;

-- 100. average order value by city
select c.city,
       round(avg(o.order_amount), 2) as avg_order_value
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.city
order by avg_order_value desc;




-- CTE
WITH customer_sales AS
(
SELECT
customer_id,
SUM(order_amount) total_spending
FROM orders
GROUP BY customer_id
)
SELECT *
FROM customer_sales;


-- Window Function

SELECT
customer_id,
SUM(order_amount) total_spending,RANK() OVER(
ORDER BY SUM(order_amount) DESC
) AS customer_rank
FROM orders
GROUP BY customer_id;


-- Row Number

SELECT
order_id,
customer_id,
order_amount,
ROW_NUMBER() OVER(
ORDER BY order_amount DESC
) AS row_num
FROM orders;

-- View

CREATE VIEW vw_customer_orders AS
SELECT
c.customer_id,
c.customer_name,
COUNT(o.order_id) total_orders,
SUM(o.order_amount) total_spending
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id,
c.customer_name;
select * from vw_customer_orders;
-- Procedure
DELIMITER $$
CREATE PROCEDURE get_customer_orders
(
IN p_customer_id INT
)
BEGIN
SELECT *
FROM orders
WHERE customer_id=p_customer_id;
END $$
DELIMITER ;

CALL get_customer_orders(101);
 -- Index

CREATE INDEX idx_orders_customer
ON orders(customer_id);
CREATE INDEX idx_orders_status
ON orders(status);

