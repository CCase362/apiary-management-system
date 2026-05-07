-- ============================================================
-- Sunny Day Apiary Management System
-- schema.sql  --  Run this first to create all tables
-- ============================================================

CREATE DATABASE IF NOT EXISTS apiary_db;
USE apiary_db;

-- Users table
CREATE TABLE Users (
    user_id    INT          AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       ENUM('admin','beekeeper') NOT NULL DEFAULT 'beekeeper'
);

-- Hives table
CREATE TABLE Hives (
    hive_id      INT         AUTO_INCREMENT PRIMARY KEY,
    hive_name    VARCHAR(50) NOT NULL,
    location     VARCHAR(100),
    queen_age    INT,
    status       ENUM('active','inactive','queenless') DEFAULT 'active',
    install_date DATE
);

-- Inspections table
CREATE TABLE Inspections (
    inspection_id   INT  AUTO_INCREMENT PRIMARY KEY,
    hive_id         INT  NOT NULL,
    user_id         INT  NOT NULL,
    inspection_date DATE NOT NULL,
    health_rating   INT  CHECK (health_rating BETWEEN 1 AND 10),
    queen_seen      TINYINT(1) NOT NULL DEFAULT 0,
    notes           TEXT,
    FOREIGN KEY (hive_id) REFERENCES Hives(hive_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Honey_Batches table
CREATE TABLE Honey_Batches (
    batch_id      INT           AUTO_INCREMENT PRIMARY KEY,
    hive_id       INT           NOT NULL,
    harvest_date  DATE          NOT NULL,
    honey_type    VARCHAR(50),
    quantity_lbs  DECIMAL(8,2)  CHECK (quantity_lbs >= 0),
    quality_grade CHAR(1),
    FOREIGN KEY (hive_id) REFERENCES Hives(hive_id)
);

-- Products table
CREATE TABLE Products (
    product_id     INT           AUTO_INCREMENT PRIMARY KEY,
    product_name   VARCHAR(100)  NOT NULL,
    category       VARCHAR(50),
    price          DECIMAL(10,2) CHECK (price > 0),
    stock_quantity INT           CHECK (stock_quantity >= 0),
    batch_id       INT,
    FOREIGN KEY (batch_id) REFERENCES Honey_Batches(batch_id)
);

-- Customers table
CREATE TABLE Customers (
    customer_id INT          AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    phone       VARCHAR(20),
    email       VARCHAR(100),
    address     TEXT
);

-- Orders table
CREATE TABLE Orders (
    order_id     INT           AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT           NOT NULL,
    order_date   DATE          NOT NULL,
    total_amount DECIMAL(10,2),
    order_status ENUM('Pending','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_Items table
CREATE TABLE Order_Items (
    order_item_id INT           AUTO_INCREMENT PRIMARY KEY,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    quantity      INT           NOT NULL,
    subtotal      DECIMAL(10,2),
    FOREIGN KEY (order_id)   REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Feeding_Schedule table
CREATE TABLE IF NOT EXISTS Feeding_Schedule (
    schedule_id  INT AUTO_INCREMENT PRIMARY KEY,
    hive_id      INT NOT NULL,
    feed_date    DATE NOT NULL,
    feed_type    VARCHAR(50) NOT NULL,
    amount_lbs   DECIMAL(8,2),
    notes        TEXT,
    FOREIGN KEY (hive_id) REFERENCES Hives(hive_id)
);

CREATE OR REPLACE VIEW ActiveHiveInspections AS
SELECT h.hive_id, h.hive_name, h.location, h.status,
       i.inspection_id, i.inspection_date, i.health_rating, i.queen_seen, i.notes
FROM Hives h
JOIN Inspections i ON h.hive_id = i.hive_id
WHERE h.status = 'active';

DROP PROCEDURE IF EXISTS LogInspectionAndUpdateStatus;
DELIMITER //
CREATE PROCEDURE LogInspectionAndUpdateStatus(
    IN p_hive_id INT,
    IN p_user_id INT,
    IN p_inspection_date DATE,
    IN p_health_rating INT,
    IN p_queen_seen TINYINT,
    IN p_notes TEXT
)
BEGIN
    INSERT INTO Inspections (hive_id, user_id, inspection_date, health_rating, queen_seen, notes)
    VALUES (p_hive_id, p_user_id, p_inspection_date, p_health_rating, p_queen_seen, p_notes);

    IF p_queen_seen = 0 THEN
        UPDATE Hives SET status = 'queenless' WHERE hive_id = p_hive_id;
    ELSEIF p_health_rating >= 5 THEN
        UPDATE Hives SET status = 'active' WHERE hive_id = p_hive_id;
    END IF;
END //
DELIMITER ;
