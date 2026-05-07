-- ============================================================
-- Sunny Day Apiary Management System
-- seed.sql  --  Run after schema.sql to load sample data
-- ============================================================

USE apiary_db;

INSERT INTO Users (first_name, last_name, email, password, role) VALUES
    ('Alice', 'Johnson', 'alice@apiary.com', SHA2('pass123', 256), 'admin'),
    ('Bob',   'Miller',  'bob@apiary.com',   SHA2('pass456', 256), 'beekeeper'),
    ('Carol', 'Smith',   'carol@apiary.com', SHA2('pass789', 256), 'beekeeper');

INSERT INTO Hives (hive_name, location, queen_age, status, install_date) VALUES
    ('Queen Beatrice', 'North Field',  2, 'active',   '2023-03-15'),
    ('Queen Celeste',  'South Garden', 1, 'active',   '2024-04-01'),
    ('Queen Isolde',   'East Orchard', 3, 'inactive', '2022-06-10');

INSERT INTO Honey_Batches (hive_id, harvest_date, honey_type, quantity_lbs, quality_grade) VALUES
    (1, '2024-08-10', 'Wildflower',     45.5, 'A'),
    (2, '2024-09-05', 'Clover',         38.0, 'B'),
    (1, '2024-10-20', 'Orange Blossom', 22.0, 'A');

INSERT INTO Products (product_name, category, price, stock_quantity, batch_id) VALUES
    ('Wildflower Honey 16oz', 'Honey',     12.99, 100, 1),
    ('Clover Honey 8oz',      'Honey',      7.99,  60, 2),
    ('Beeswax Candle',        'Candles',    9.99,  40, NULL),
    ('Lip Balm Honey',        'Cosmetics',  4.99,  80, NULL);

INSERT INTO Customers (first_name, last_name, phone, email, address) VALUES
    ('Tom',  'Baker', '555-1234', 'tom@email.com',  '101 Main St, Orlando, FL'),
    ('Sara', 'Davis', '555-5678', 'sara@email.com', '202 Oak Ave, Tampa, FL');

INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
    (1, '2025-01-15', 32.97, 'Delivered'),
    (2, '2025-02-03', 15.98, 'Shipped');

INSERT INTO Order_Items (order_id, product_id, quantity, subtotal) VALUES
    (1, 1, 2, 25.98),
    (1, 3, 1,  9.99),
    (2, 2, 2, 15.98);

INSERT INTO Inspections (hive_id, user_id, inspection_date, health_rating, queen_seen, notes) VALUES
    (1, 2, '2025-01-10', 8, 1, 'Hive looks healthy, good brood pattern.'),
    (2, 2, '2025-01-12', 6, 0, 'Could not locate queen, will re-inspect next week.'),
    (1, 3, '2025-02-05', 9, 1, 'Excellent activity, honey stores building up.');

INSERT INTO Feeding_Schedule (hive_id, feed_date, feed_type, amount_lbs, notes) VALUES
    (1, '2025-02-10', 'Sugar Syrup', 2.50, 'Added light feeding after inspection.'),
    (2, '2025-02-12', 'Pollen Patty', 1.00, 'Support hive before re-inspection.'),
    (3, '2025-02-18', 'Sugar Syrup', 2.00, 'Maintenance feeding for inactive hive.');
