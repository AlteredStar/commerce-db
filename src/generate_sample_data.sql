-- Populate tables with sample data

-- Populate customer accounts
INSERT INTO customers.users (username, email)
SELECT 'user_' || i, 'user_' || i || '@example.com'
FROM generate_series(1, 10000) AS i;

-- Populate product categories
INSERT INTO inventory.categories (name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Cosmetics', 'Makeup and skincare products'),
('Health', 'Wellness items, vitamins, and supplements'),
('Clothing', 'Apparel and fashion items'),
('Footwear', 'Shoes and footwear'),
('Home', 'Furniture and home improvement items'),
('Jewelry', 'Accessories and ornaments');

-- Populate products
INSERT INTO inventory.products (category_id, name, description, price, stock)
SELECT
    c.category_id,
    'product_' || i,
    '',
    ROUND((RANDOM() * 250 + 5)::DECIMAL, 2),
    ROUND((RANDOM() * 500 + 50))
FROM generate_series(1, 5000) AS i
CROSS JOIN LATERAL (
    SELECT category_id 
    FROM inventory.categories 
    WHERE i.i IS NOT NULL
    ORDER BY RANDOM() 
    LIMIT 1
) AS c;

-- Populate orders
INSERT INTO sales.orders (user_id, status, order_date)
SELECT
    u.user_id,
    'Completed',
    '2023-01-01'::DATE + (FLOOR(RANDOM() * (365 * 3))::INT * INTERVAL '1 day')
FROM generate_series(1, 20000) AS i
CROSS JOIN LATERAL (
    SELECT user_id 
    FROM customers.users 
    WHERE i.i IS NOT NULL
    ORDER BY RANDOM() 
    LIMIT 1
) AS u;

-- Populate each order with an item
INSERT INTO sales.order_items (order_id, product_id, quantity)
SELECT 
    order_id, 
    p.product_id,
    FLOOR(RANDOM() * 4 + 1)::int AS quantity
FROM sales.orders
CROSS JOIN LATERAL (
    SELECT product_id 
    FROM inventory.products 
    WHERE order_id IS NOT NULL
    ORDER BY RANDOM() 
    LIMIT 1
) AS p;
-- Populate random orders with items
INSERT INTO sales.order_items (order_id, product_id, quantity)
SELECT
    o.order_id,
    p.product_id,
    ROUND((RANDOM() * 4 + 1))
FROM generate_series(1, 10000) AS i
CROSS JOIN LATERAL (
    SELECT order_id 
    FROM sales.orders 
    WHERE i.i IS NOT NULL
    ORDER BY RANDOM() 
    LIMIT 1
) AS o
CROSS JOIN LATERAL (
    SELECT product_id 
    FROM inventory.products 
    WHERE i.i IS NOT NULL
    ORDER BY RANDOM() 
    LIMIT 1
) AS p;

-- Populate payments
INSERT INTO sales.payments (order_id, amount_paid, status, payment_date)
SELECT
    sales.orders.order_id,
    SUM(inventory.products.price * sales.order_items.quantity),
    'Completed',
    sales.orders.order_date  + 
        (FLOOR(RANDOM() * 7)::INT * INTERVAL '1 day')
FROM sales.orders
LEFT JOIN sales.order_items ON sales.orders.order_id = sales.order_items.order_id
LEFT JOIN inventory.products ON sales.order_items.product_id = inventory.products.product_id
GROUP BY sales.orders.order_id, sales.orders.order_date;
