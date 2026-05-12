-- ============================
-- SCHEMA CREATION
-- ============================

CREATE TABLE Company (
    cmp_id INT PRIMARY KEY,
    company_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    street VARCHAR(100),
    city VARCHAR(50),
    email_id VARCHAR(100),
    cmp_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (cmp_id) REFERENCES Company(cmp_id)
);

CREATE TABLE Manages (
    emp_id INT,
    mgr_id INT,
    PRIMARY KEY (emp_id, mgr_id),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id),
    FOREIGN KEY (mgr_id) REFERENCES Employee(emp_id)
);

-- ============================
-- QUERIES
-- ============================

-- 1. Employees who work for First Bank Corporation
SELECT e.employee_name, e.city
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE c.company_name = 'First Bank Corporation';

-- 2. Employees who work for First Bank or Yes Bank
SELECT e.employee_name
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE c.company_name IN ('First Bank Corporation','Yes Bank Corporation');

-- 3. Employees with salary between 20000 and 50000
SELECT e.employee_name, c.company_name
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE e.salary BETWEEN 20000 AND 50000;

-- 4. Employees in First Bank earning >10000
SELECT e.employee_name, e.street, e.city
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE c.company_name = 'First Bank Corporation' AND e.salary > 10000;

-- 5. Employees not in First Bank
SELECT e.employee_name
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE c.company_name <> 'First Bank Corporation';

-- 6. Employees who work under manager Smith Jones
SELECT e.employee_name
FROM Employee e JOIN Manages m ON e.emp_id = m.emp_id
JOIN Employee mgr ON m.mgr_id = mgr.emp_id
WHERE mgr.employee_name = 'Smith Jones';

-- 7. Manager names who live in Varanasi
SELECT DISTINCT mgr.employee_name
FROM Employee mgr
WHERE mgr.city = 'Varanasi' AND mgr.emp_id IN (SELECT mgr_id FROM Manages);

-- 8. Managers whose name starts with P
SELECT mgr.employee_name, mgr.city, mgr.salary
FROM Employee mgr
WHERE mgr.employee_name LIKE 'P%' AND mgr.emp_id IN (SELECT mgr_id FROM Manages);

-- 9. Employee whose company name’s 3rd last character is 'i'
SELECT e.employee_name
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE SUBSTRING(c.company_name, LENGTH(c.company_name)-2, 1) = 'i';

-- 10. Employees living in same city as their company
SELECT e.employee_name
FROM Employee e JOIN Company c ON e.cmp_id = c.cmp_id
WHERE e.city = c.city;

-- 11. Employees living in same street & city as their manager
SELECT e.employee_name
FROM Employee e JOIN Manages m ON e.emp_id = m.emp_id
JOIN Employee mgr ON m.mgr_id = mgr.emp_id
WHERE e.city = mgr.city AND e.street = mgr.street;

-- 12. Employees earning more than each employee of Small Bank Corporation
SELECT e.employee_name
FROM Employee e
WHERE e.salary > ALL (
    SELECT e2.salary
    FROM Employee e2 JOIN Company c ON e2.cmp_id = c.cmp_id
    WHERE c.company_name = 'Small Bank Corporation'
);

-- 13. Employees earning more than average salary of their company
SELECT e.employee_name
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.cmp_id = e.cmp_id
);

-- 14. Company with most employees
SELECT c.company_name
FROM Company c JOIN Employee e ON c.cmp_id = e.cmp_id
GROUP BY c.company_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 15. Company with smallest payroll
SELECT c.company_name
FROM Company c JOIN Employee e ON c.cmp_id = e.cmp_id
GROUP BY c.company_name
ORDER BY SUM(e.salary) ASC
LIMIT 1;

-- 16. Companies with avg salary > avg salary of First Bank
SELECT c.company_name
FROM Company c JOIN Employee e ON c.cmp_id = e.cmp_id
GROUP BY c.company_name
HAVING AVG(e.salary) > (
    SELECT AVG(e2.salary)
    FROM Employee e2 JOIN Company c2 ON e2.cmp_id = c2.cmp_id
    WHERE c2.company_name = 'First Bank Corporation'
);

-- 17. Modify Jones’ city to New Delhi
UPDATE Employee
SET city = 'New Delhi'
WHERE employee_name = 'Jones';

-- 18. Give First Bank employees 10% raise
UPDATE Employee
SET salary = salary * 1.10
WHERE cmp_id = (SELECT cmp_id FROM Company WHERE company_name = 'First Bank Corporation');

-- 19. Handle closure of Small Bank Corporation
-- Option A: Delete employees first (if ON DELETE CASCADE not set)
DELETE FROM Employee WHERE cmp_id = (SELECT cmp_id FROM Company WHERE company_name = 'Small Bank Corporation');
-- Then delete company
DELETE FROM Company WHERE company_name = 'Small Bank Corporation';
