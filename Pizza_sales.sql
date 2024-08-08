create database pizzahut;
 
 CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
 
 CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- The total number of order place.

SELECT
    COUNT(order_id) AS total_orders 
FROM orders;

-- The total revenue generated from pizza sales

SELECT 
    ROUND(SUM(pizzas.price * orders_details.quantity),
            2) AS total_revenue
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id;
    
-- The highest-priced pizaa
 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- The most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- The top 5 most ordered pizza types along their quantities.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC
LIMIT 5;

-- The quantity of each pizza categories ordered
SELECT 
    pizza_types.category,
    SUM(quantity) AS 'Total quantity ordered'
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- The distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) as hour, COUNT(order_id) as order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- The category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- The average number of pizzas orders per day

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- The top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * orders_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- The percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(pizzas.price * orders_details.quantity),
                                2) AS total_sales
                FROM
                    pizzas
                        JOIN
                    orders_details ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- The cumulative revenue generated over time.

select order_date,sum(revenue) over(order by order_date) 
as cum_revenue from
          (select orders.order_date,sum(orders_details.quantity * pizzas.price) 
          as revenue from orders_details
	      join pizzas on orders_details.pizza_id=pizzas.pizza_id
          join orders on orders.order_id=orders_details.order_id 
group by orders.order_date) 
as sales;

-- The top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue from 
(select category,name,revenue,rank() 
over(partition by category order by revenue desc)
as rn from (select pizzas_types.name,pizza_types.category,
sum(orders_details.quantity*pizzas.price) as Revenue 
from pizza_types 
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id=pizzas.pizza_id 
group by category, name) as a) as b
where rn<=3;

    

    