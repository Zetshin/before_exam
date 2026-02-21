-- สร้างฐานข้อมูล
CREATE DATABASE IF NOT EXISTS election_db;
USE election_db;

-- ตาราง polling_station
CREATE TABLE IF NOT EXISTS polling_station (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    station_name TEXT NOT NULL,
    zone TEXT NOT NULL,
    province TEXT NOT NULL
);

-- ตาราง violation_type
CREATE TABLE IF NOT EXISTS violation_type (
    type_id INT PRIMARY KEY,
    type_name TEXT NOT NULL,
    severity TEXT NOT NULL
);

-- ตาราง incident_report
CREATE TABLE IF NOT EXISTS incident_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    type_id INT NOT NULL,
    reporter_name TEXT NOT NULL,
    description TEXT,
    evidence_photo TEXT,
    timestamp TEXT NOT NULL,
    ai_result TEXT,
    ai_confidence REAL DEFAULT 0.0,
    FOREIGN KEY (station_id) REFERENCES polling_station(station_id),
    FOREIGN KEY (type_id) REFERENCES violation_type(type_id)
);

-- ข้อมูลตัวอย่าง polling_station
INSERT INTO polling_station (station_id, station_name, zone, province) VALUES
(101, 'โรงเรียนวัดพระมหาธาตุ', 'เขต 1', 'นครศรีธรรมราช'),
(102, 'เต็นท์หน้าลาดตระเวน', 'เขต 1', 'นครศรีธรรมราช'),
(103, 'ศาลากลางหมู่บ้านสี่วัง', 'เขต 2', 'นครศรีธรรมราช'),
(104, 'ทอปประชุมอำเภอทุ่งสง', 'เขต 3', 'นครศรีธรรมราช');

-- ข้อมูลตัวอย่าง violation_type
INSERT INTO violation_type (type_id, type_name, severity) VALUES
(1, 'ซื้อสิทธิ์ขายเสียง (Buying Votes)', 'High'),
(2, 'ขนคนไปลงคะแนน (Transportation)', 'High'),
(3, 'หาเสียงเกินเวลา (Overtime Campaign)', 'Medium'),
(4, 'ทำลายป้ายหาเสียง (Vandalism)', 'Low'),
(5, 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)', 'High');

-- ข้อมูลตัวอย่าง incident_report
INSERT INTO incident_report (report_id, station_id, type_id, reporter_name, description, evidence_photo, timestamp, ai_result, ai_confidence) VALUES
(1, 101, 1, 'พลเมืองดี 01', 'พบเห็นการแจกเงินหน้าคูหา', NULL, '2026-02-08 09:30:00', 'Money', 0.95),
(2, 102, 3, 'สมชาย', 'ไวทลิ เห็นการหาเสียงเกิดเวลาก่อสร้าง', NULL, '2026-02-08 10:15:00', 'Crowd', 0.75),
(3, 103, 5, 'Anonymous', 'เจ้าหน้าที่ดูละชี้นำผู้ลงคะแนน', NULL, '2026-02-08 11:00:00', NULL, 0.0);
