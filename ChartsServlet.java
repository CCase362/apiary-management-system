USE apiary_db;

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
