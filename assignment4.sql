-- ============================
-- SCHEMA CREATION
-- ============================

CREATE TABLE Aircraft (
    aid INT PRIMARY KEY,
    aname VARCHAR(100),
    cruising_range INT
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(100),
    salary DECIMAL(10,2)
);

CREATE TABLE Certified (
    emp_id INT,
    aid INT,
    PRIMARY KEY (emp_id, aid),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    FOREIGN KEY (aid) REFERENCES Aircraft(aid)
);

CREATE TABLE Flights (
    flno INT PRIMARY KEY,
    aid INT,
    from_city VARCHAR(50),
    to_city VARCHAR(50),
    distance INT,
    departs_time TIME,
    arrival_time TIME,
    price DECIMAL(10,2),
    FOREIGN KEY (aid) REFERENCES Aircraft(aid)
);

-- ============================
-- QUERIES
-- ============================

-- a. Aircraft such that all pilots certified earn > 80000
SELECT a.aname
FROM Aircraft a
WHERE NOT EXISTS (
    SELECT 1
    FROM Certified c JOIN Employees e ON c.emp_id = e.emp_id
    WHERE c.aid = a.aid AND e.salary <= 80000
);

-- b. Pilots certified for >3 aircraft, emp_id and max cruising range
SELECT c.emp_id, MAX(a.cruising_range) AS MaxRange
FROM Certified c JOIN Aircraft a ON c.aid = a.aid
GROUP BY c.emp_id
HAVING COUNT(c.aid) > 3;

-- c. Pilots whose salary < cheapest LA→Honolulu route
SELECT e.ename
FROM Employees e
WHERE e.salary < (
    SELECT MIN(price)
    FROM Flights
    WHERE from_city = 'Los Angeles' AND to_city = 'Honolulu'
);

-- d. Aircraft with range >1000, avg salary of certified pilots
SELECT a.aname, AVG(e.salary) AS AvgSalary
FROM Aircraft a JOIN Certified c ON a.aid = c.aid
JOIN Employees e ON c.emp_id = e.emp_id
WHERE a.cruising_range > 1000
GROUP BY a.aname;

-- e. Pilots certified for some Boeing aircraft
SELECT DISTINCT e.ename
FROM Employees e JOIN Certified c ON e.emp_id = c.emp_id
JOIN Aircraft a ON c.aid = a.aid
WHERE a.aname LIKE 'Boeing%';

-- f. Aids of aircraft usable on LA→Chicago routes
SELECT DISTINCT f.aid
FROM Flights f
WHERE f.from_city = 'Los Angeles' AND f.to_city = 'Chicago';

-- g. Routes piloted by every pilot earning >100000
SELECT f.flno, f.from_city, f.to_city
FROM Flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.salary > 100000
    AND NOT EXISTS (
        SELECT 1
        FROM Certified c
        WHERE c.emp_id = e.emp_id AND c.aid = f.aid
    )
);

-- h. Pilots certified for planes >3000 range but not any Boeing
SELECT DISTINCT e.ename
FROM Employees e
WHERE EXISTS (
    SELECT 1
    FROM Certified c JOIN Aircraft a ON c.aid = a.aid
    WHERE c.emp_id = e.emp_id AND a.cruising_range > 3000
)
AND NOT EXISTS (
    SELECT 1
    FROM Certified c JOIN Aircraft a ON c.aid = a.aid
    WHERE c.emp_id = e.emp_id AND a.aname LIKE 'Boeing%'
);

-- i. Madison→New York with ≤1 change, arrive by 6pm
SELECT DISTINCT f1.departs_time
FROM Flights f1 JOIN Flights f2 ON f1.to_city = f2.from_city
WHERE f1.from_city = 'Madison' AND f2.to_city = 'New York'
AND f2.arrival_time <= '18:00';

-- j. Difference between avg pilot salary and avg employee salary
SELECT (
    (SELECT AVG(e.salary)
     FROM Employees e
     WHERE e.emp_id IN (SELECT DISTINCT emp_id FROM Certified))
    -
    (SELECT AVG(salary) FROM Employees)
) AS SalaryDifference;

-- k. Nonpilots with salary > avg pilot salary
SELECT e.ename, e.salary
FROM Employees e
WHERE e.emp_id NOT IN (SELECT DISTINCT emp_id FROM Certified)
AND e.salary > (
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.emp_id IN (SELECT DISTINCT emp_id FROM Certified)
);
