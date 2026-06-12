-- Initialize tables

-- Customer accounts
CREATE TABLE IF NOT EXISTS customers.users (
	user_id SERIAL PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
	email VARCHAR(50) UNIQUE NOT NULL
);

-- Product categories
CREATE TABLE IF NOT EXISTS inventory.categories (
	category_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Products
CREATE TABLE IF NOT EXISTS inventory.products (
	product_id SERIAL PRIMARY KEY,
	category_id INT REFERENCES inventory.categories(category_id),
	name VARCHAR(100) NOT NULL,
	description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL
);

-- Orders
CREATE TABLE IF NOT EXISTS sales.orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES customers.users(user_id),
    status VARCHAR(20) DEFAULT 'Pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Items in Order
CREATE TABLE IF NOT EXISTS sales.order_items (
    order_items_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sales.orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES inventory.products(product_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- Payments
CREATE TABLE IF NOT EXISTS sales.payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sales.orders(order_id),
    amount_paid DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'Pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
