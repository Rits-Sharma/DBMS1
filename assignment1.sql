-- Create Employee table
CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT,
    Salary DECIMAL(10,2),
    City VARCHAR(50),
    Country VARCHAR(50),
    Email_id VARCHAR(100)
);

-- Insert sample data
INSERT INTO Employee VALUES
(1, 'Prakash', 45, 60000, 'Varanasi', 'India', 'prakash@gmail.com'),
(2, 'Priya', 52, 48000, 'Varanasi', 'India', 'priya@yahoo.com'),
(3, 'Amit', 35, 55000, 'Mumbai', 'India', 'amit@gmail.com'),
(4, 'Suresh', 29, 30000, 'Lucknow', 'India', 'suresh@hotmail.com'),
(5, 'Pooja', 41, 70000, 'Kolkata', 'India', 'pooja@gmail.com'),
(6, 'Hans', 38, 45000, 'Berlin', 'Germany', 'hans@gmail.com'),
(7, 'Marie', 33, 52000, 'Paris', 'France', 'marie@gmail.com'),
(8, 'Kenji', 40, 62000, 'Tokyo', 'Japan', 'kenji@gmail.com'),
(9, 'Li Wei', 36, 40000, 'Beijing', 'China', 'liwei@gmail.com');

-- 1. List Employee_ID, Name, Age and Salary of all employees
SELECT Employee_ID, Name, Age, Salary FROM Employee;

-- 2. Employees in Varanasi
SELECT Name, Age, Salary FROM Employee WHERE City = 'Varanasi';

-- 3. Employees not in Kolkata
SELECT Name, Age, Salary FROM Employee WHERE City <> 'Kolkata';

-- 4. Employees in Mumbai sorted by Salary
SELECT Name, Salary FROM Employee WHERE City = 'Mumbai' ORDER BY Salary;

-- 5. Employees in Varanasi with Salary > 50000
SELECT Employee_ID, Name, Age, Salary 
FROM Employee 
WHERE City = 'Varanasi' AND Salary > 50000;

-- 6. Employees in Varanasi with Age > 50
SELECT Name, Age, Salary 
FROM Employee 
WHERE City = 'Varanasi' AND Age > 50;

-- 7. Employees in Varanasi or Lucknow
SELECT Name, Salary 
FROM Employee 
WHERE City IN ('Varanasi', 'Lucknow');

-- 8. Employees with Salary between 20000 and 50000
SELECT Name, Age, Salary 
FROM Employee 
WHERE Salary BETWEEN 20000 AND 50000;

-- 9. Employees from Germany, France, or Japan
SELECT Employee_ID, Name, Salary 
FROM Employee 
WHERE Country IN ('Germany', 'France', 'Japan');

-- 10. Employees not from China, South Korea, or North Korea
SELECT Employee_ID, Name, Salary 
FROM Employee 
WHERE Country NOT IN ('China', 'South Korea', 'North Korea');

-- 11. Employees whose name starts with P
SELECT Name, Salary 
FROM Employee 
WHERE Name LIKE 'P%';

-- 12. Employees whose name ends with a
SELECT Name, Age 
FROM Employee 
WHERE Name LIKE '%a';

-- 13. Employees whose Country’s 4th letter is 'n'
SELECT Name, Age 
FROM Employee 
WHERE SUBSTRING(Country,4,1) = 'n';

-- 14. Employees with Gmail email_id
SELECT Name, City 
FROM Employee 
WHERE Email_id LIKE '%@gmail.com';

-- 15. List distinct Countries
SELECT DISTINCT Country FROM Employee;
