

DROP DATABASE IF EXISTS AttendanceDB;
CREATE DATABASE AttendanceDB;
USE AttendanceDB;

-- =============================================
-- Tables
-- =============================================

CREATE TABLE Department (
    Department_ID INT PRIMARY KEY AUTO_INCREMENT,
    Department_Name VARCHAR(100) NOT NULL UNIQUE,
    Location VARCHAR(100)
);

CREATE TABLE Shift (
    Shift_ID INT PRIMARY KEY AUTO_INCREMENT,
    Shift_Name VARCHAR(50) NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL
);

CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Department_ID INT,
    Shift_ID INT,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (Shift_ID) REFERENCES Shift(Shift_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Attendance (
    Attendance_ID INT PRIMARY KEY AUTO_INCREMENT,
    Employee_ID INT NOT NULL,
    Attendance_Date DATE NOT NULL,
    Status ENUM('Present', 'Absent', 'Leave') NOT NULL,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (Employee_ID, Attendance_Date)
);

CREATE TABLE Leave_Record (
    Leave_ID INT PRIMARY KEY AUTO_INCREMENT,
    Employee_ID INT NOT NULL,
    Leave_Type VARCHAR(50) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Reason VARCHAR(255),
    Status ENUM('Approved', 'Pending', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (End_Date >= Start_Date)
);

-- =============================================
-- Sample Data
-- =============================================

INSERT INTO Department VALUES
(1, 'Human Resources', 'Floor 1, Block A'),
(2, 'Information Technology', 'Floor 2, Block B'),
(3, 'Finance', 'Floor 3, Block A'),
(4, 'Marketing', 'Floor 2, Block C');

INSERT INTO Shift VALUES
(1, 'Morning', '08:00:00', '16:00:00'),
(2, 'Evening', '16:00:00', '00:00:00'),
(3, 'Night', '00:00:00', '08:00:00'),
(4, 'General', '09:00:00', '17:00:00');

INSERT INTO Employee VALUES
(1, 'Ahmed Khan', 'ahmed@company.com', '0300-1111111', 2, 1),
(2, 'Sara Ali', 'sara@company.com', '0300-2222222', 1, 4),
(3, 'Usman Tariq', 'usman@company.com', '0300-3333333', 2, 2),
(4, 'Ayesha Noor', 'ayesha@company.com', '0300-4444444', 3, 4),
(5, 'Bilal Hassan', 'bilal@company.com', '0300-5555555', 4, 1),
(6, 'Fatima Zahra', 'fatima@company.com', '0300-6666666', 1, 4);

INSERT INTO Attendance VALUES
(1, 1, '2026-05-04', 'Present'),
(2, 1, '2026-05-05', 'Present'),
(3, 2, '2026-05-04', 'Present'),
(4, 2, '2026-05-05', 'Absent'),
(5, 3, '2026-05-04', 'Present'),
(6, 3, '2026-05-05', 'Leave'),
(7, 4, '2026-05-04', 'Present'),
(8, 4, '2026-05-05', 'Present'),
(9, 5, '2026-05-04', 'Present'),
(10, 5, '2026-05-05', 'Present'),
(11, 6, '2026-05-04', 'Absent'),
(12, 6, '2026-05-05', 'Present');

INSERT INTO Leave_Record VALUES
(1, 3, 'Sick Leave', '2026-05-05', '2026-05-05', 'Fever', 'Approved'),
(2, 6, 'Casual Leave', '2026-05-04', '2026-05-04', 'Personal', 'Approved'),
(3, 2, 'Annual Leave', '2026-05-10', '2026-05-15', 'Vacation', 'Pending');

-- =============================================
-- Queries
-- =============================================

-- 1. Employee Attendance with Department
SELECT e.Name, d.Department_Name, a.Attendance_Date, a.Status
FROM Attendance a
JOIN Employee e ON a.Employee_ID = e.Employee_ID
JOIN Department d ON e.Department_ID = d.Department_ID;

-- 2. Daily Report
SELECT Status, COUNT(*) AS Count
FROM Attendance
WHERE Attendance_Date = '2026-05-05'
GROUP BY Status;

-- 3. Monthly Summary per Employee (FIXED)
SELECT e.Name,
    SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
    SUM(CASE WHEN a.Status = 'Absent' THEN 1 ELSE 0 END) AS Absent,
    SUM(CASE WHEN a.Status = 'Leave' THEN 1 ELSE 0 END) AS Leaves
FROM Employee e
LEFT JOIN Attendance a ON e.Employee_ID = a.Employee_ID
GROUP BY e.Employee_ID, e.Name;

-- 4. Employee with Most Absences
SELECT e.Name, COUNT(*) AS Absences
FROM Employee e
JOIN Attendance a ON e.Employee_ID = a.Employee_ID
WHERE a.Status = 'Absent'
GROUP BY e.Employee_ID, e.Name
ORDER BY Absences DESC
LIMIT 1;

-- 5. Leave Report
SELECT e.Name, lr.Leave_Type, lr.Start_Date, lr.End_Date, lr.Status
FROM Leave_Record lr
JOIN Employee e ON lr.Employee_ID = e.Employee_ID;

-- 6. Employee Details with Shift
SELECT e.Name, d.Department_Name, s.Shift_Name
FROM Employee e
JOIN Department d ON e.Department_ID = d.Department_ID
JOIN Shift s ON e.Shift_ID = s.Shift_ID;

-- =============================================
-- Verify
-- =============================================

SELECT * FROM Employee;
SELECT * FROM Attendance;
SELECT * FROM Leave_Record;