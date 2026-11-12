CREATE DATABASE IF NOT EXISTS food_delivery_db;

USE food_delivery_db;
show tables;
-- Customers

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    city VARCHAR(100),
    signup_date DATE
);

-- Restaurants

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(150) NOT NULL,
    cuisine_type VARCHAR(100),
    city VARCHAR(100),
    rating DECIMAL(2,1)
);

-- Delivery Partners

CREATE TABLE delivery_partners (
    partner_id INT PRIMARY KEY,
    partner_name VARCHAR(100),
    vehicle_type VARCHAR(50),
    joining_date DATE
);

-- Orders

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    partner_id INT,
    order_time DATETIME,
    delivered_time DATETIME,
    order_amount DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    status VARCHAR(30),

    FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id),

    FOREIGN KEY(restaurant_id)
    REFERENCES restaurants(restaurant_id),

    FOREIGN KEY(partner_id)
    REFERENCES delivery_partners(partner_id)
);

-- Payments

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_mode VARCHAR(50),
    amount DECIMAL(10,2),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id)
);

-- Ratings

CREATE TABLE ratings (
    rating_id INT PRIMARY KEY,
    order_id INT,
    customer_rating INT,
    feedback VARCHAR(500),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id)
);

-- Customer Behavior

CREATE TABLE customer_behavior (
    customer_id INT PRIMARY KEY,
    total_orders INT,
    total_spending DECIMAL(10,2),
    avg_order_value DECIMAL(10,2),
    last_order_days INT,
    churn_flag VARCHAR(10),

    FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id)
);