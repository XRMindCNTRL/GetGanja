-- Cannabis Delivery Platform Database Setup
-- Run this script after creating your PostgreSQL database

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_role AS ENUM ('customer', 'vendor', 'driver', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'in_transit', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role user_role NOT NULL DEFAULT 'customer',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Vendors table
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_address TEXT,
    business_phone VARCHAR(20),
    license_number VARCHAR(100),
    tax_id VARCHAR(50),
    is_approved BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_orders INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Drivers table
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) NOT NULL,
    vehicle_type VARCHAR(50),
    vehicle_plate VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE,
    current_location JSONB,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(500),
    thc_content DECIMAL(5,2),
    cbd_content DECIMAL(5,2),
    strain_type VARCHAR(50),
    quantity_available INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id),
    driver_id UUID REFERENCES drivers(id),
    status order_status DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0.00,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_instructions TEXT,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    actual_delivery TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    stripe_payment_id VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status payment_status DEFAULT 'pending',
    payment_method VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES users(id),
    vendor_id UUID REFERENCES vendors(id),
    driver_id UUID REFERENCES drivers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_vendors_user_id ON vendors(user_id);
CREATE INDEX idx_drivers_user_id ON drivers(user_id);
CREATE INDEX idx_products_vendor_id ON products(vendor_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_vendor_id ON orders(vendor_id);
CREATE INDEX idx_orders_driver_id ON orders(driver_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO categories (name, description) VALUES
('Flower', 'Premium cannabis flower products'),
('Edibles', 'Cannabis-infused edibles and gummies'),
('Vapes', 'Vaporizer cartridges and accessories'),
('Concentrates', 'High-potency cannabis concentrates'),
('Topicals', 'Cannabis-infused topical products');

-- Create admin user (password: admin123)
INSERT INTO users (email, password_hash, name, role, is_verified, is_active) VALUES
('admin@cannabisdelivery.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPjYLC3Q8JQO', 'Platform Admin', 'admin', true, true);

-- Create sample customer
INSERT INTO users (email, password_hash, name, role, is_verified, is_active) VALUES
('customer@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPjYLC3Q8JQO', 'John Customer', 'customer', true, true);

-- Create sample vendor
INSERT INTO users (email, password_hash, name, role, is_verified, is_active) VALUES
('vendor@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPjYLC3Q8JQO', 'Jane Vendor', 'vendor', true, true);

INSERT INTO vendors (user_id, business_name, business_address, business_phone, license_number, is_approved) VALUES
((SELECT id FROM users WHERE email = 'vendor@example.com'), 'Green Leaf Dispensary', '123 Cannabis St, Weed City, WC 12345', '+1-555-0123', 'LIC-123456', true);

-- Create sample driver
INSERT INTO users (email, password_hash, name, role, is_verified, is_active) VALUES
('driver@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPjYLC3Q8JQO', 'Bob Driver', 'driver', true, true);

INSERT INTO drivers (user_id, license_number, vehicle_type, vehicle_plate, is_available) VALUES
((SELECT id FROM users WHERE email = 'driver@example.com'), 'DL-789012', 'Sedan', 'ABC-123', true);

-- Insert sample products
INSERT INTO products (vendor_id, category_id, name, description, price, thc_content, cbd_content, strain_type, quantity_available, is_available) VALUES
((SELECT id FROM vendors LIMIT 1), (SELECT id FROM categories WHERE name = 'Flower'), 'Blue Dream Flower', 'Premium Blue Dream strain with balanced effects', 45.99, 18.50, 0.10, 'Hybrid', 50, true),
((SELECT id FROM vendors LIMIT 1), (SELECT id FROM categories WHERE name = 'Flower'), 'OG Kush Flower', 'Classic OG Kush with powerful effects', 42.99, 22.00, 0.05, 'Indica', 30, true),
((SELECT id FROM vendors LIMIT 1), (SELECT id FROM categories WHERE name = 'Edibles'), 'Calm CBD Gummies', 'Relaxing CBD gummies for wellness', 29.99, 0.00, 25.00, 'CBD', 100, true),
((SELECT id FROM vendors LIMIT 1), (SELECT id FROM categories WHERE name = 'Vapes'), 'Sour Diesel Vape Cartridge', 'Energizing Sour Diesel in vape form', 24.99, 70.00, 0.00, 'Sativa', 25, true);

-- Create sample order
INSERT INTO orders (customer_id, vendor_id, status, subtotal, tax, delivery_fee, total, delivery_address) VALUES
((SELECT id FROM users WHERE email = 'customer@example.com'), (SELECT id FROM vendors LIMIT 1), 'delivered', 75.98, 6.08, 5.00, 87.06, '456 Oak Street, Springfield, IL 62701');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
((SELECT id FROM orders LIMIT 1), (SELECT id FROM products WHERE name = 'Blue Dream Flower'), 1, 45.99),
((SELECT id FROM products WHERE name = 'OG Kush Flower'), 1, 42.99);

-- Insert sample payment
INSERT INTO payments (order_id, stripe_payment_id, amount, status, payment_method) VALUES
((SELECT id FROM orders LIMIT 1), 'pi_test_123456789', 87.06, 'completed', 'card');

-- Insert sample review
INSERT INTO reviews (order_id, customer_id, vendor_id, rating, comment) VALUES
((SELECT id FROM orders LIMIT 1), (SELECT id FROM users WHERE email = 'customer@example.com'), (SELECT id FROM vendors LIMIT 1), 5, 'Great service and quality products!');

-- Insert sample notifications
INSERT INTO notifications (user_id, title, message, type) VALUES
((SELECT id FROM users WHERE email = 'customer@example.com'), 'Order Delivered', 'Your order has been successfully delivered!', 'success'),
((SELECT id FROM users WHERE email = 'vendor@example.com'), 'New Order', 'You have received a new order request', 'info');

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_app_user;
