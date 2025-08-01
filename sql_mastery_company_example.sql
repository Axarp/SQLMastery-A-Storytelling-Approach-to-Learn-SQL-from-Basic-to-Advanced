
-- Welcome to SQLMastery Corp 🚀 
-- This is the full journey of how our company grows, manages data, hires people, grants access, 
-- processes transactions, analyzes performance, and handles advanced SQL features.
-- Let's begin our story!

-- Step 1: Create the company database
CREATE DATABASE company_data;

-- Step 2: Select the company database to work with (NOTE: 'USE' works in MySQL, not in PostgreSQL)
USE company_data;

-- Step 3: Our company starts with hiring employees. Let's create an employee table to store their info.
CREATE TABLE employee (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- Step 4: We now need to know which department our employees belong to, so we add that column.
ALTER TABLE employee ADD department VARCHAR(50);

-- Step 5: Let's onboard our first batch of employees: John (Civil), Jane (IT), and Bob (HR).
INSERT INTO employee (id, name, salary, department)
VALUES
    (1, 'John Doe', 50000, 'Civil'),
    (2, 'Jane Smith', 65000, 'IT'),
    (3, 'Bob Martin', 45000, 'HR');

-- Step 6: John just got a legal name change to "Akshar" (😉) – let's update it.
UPDATE employee SET name = 'Akshar' WHERE id = 1;

-- Step 7: Let's check everyone’s salary to see if we’re paying fairly.
SELECT name, salary FROM employee;

-- Step 8: Oops! We no longer need the 'department' column (maybe moving to cross-functional teams).
ALTER TABLE employee DROP COLUMN department;

-- Step 9: Our finance team requires larger salary precision – we’ll modify the salary column.
ALTER TABLE employee MODIFY salary DECIMAL(12, 2);

-- Step 10: For internal standardization, let’s rename the table to all caps.
RENAME TABLE employee TO EMPLOYEE;

-- Step 11: Akshar has left the company. Let’s remove his record.
DELETE FROM EMPLOYEE WHERE name = 'Akshar';

-- Step 12: We’re restarting HR records — let’s truncate the table and wipe it clean.
TRUNCATE TABLE EMPLOYEE;

-- Step 13: And finally, we’ll drop the employee table to recreate it later.
DROP TABLE EMPLOYEE;

-- Step 14: Give access to new interns (users) to only view or add data.
GRANT SELECT, INSERT ON company_data.* TO 'user1'@'localhost';

-- Step 15: But one intern is misusing access — let’s revoke INSERT permissions.
REVOKE INSERT ON company_data.* FROM 'username'@'localhost';

-- Step 16: Let's recreate the employee table with all necessary columns (including department again).
CREATE TABLE EMPLOYEE (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(12,2),
    department VARCHAR(50)
);

-- Step 17: We create a VIEW to highlight employees with high salaries.
CREATE VIEW high_salary AS
SELECT name, salary FROM EMPLOYEE WHERE salary > 50000;

-- Step 18: Here’s a CTE (Common Table Expression) to filter high earners.
WITH high_earners AS (
    SELECT * FROM EMPLOYEE WHERE salary > 50000
)
SELECT * FROM high_earners;

-- Step 19: Let’s add an index to speed up searches by employee name.
CREATE INDEX idx_name ON EMPLOYEE(name);

-- Step 20: Let’s automate fetching employee data using a stored procedure.
DELIMITER //
CREATE PROCEDURE GetEmployees()
BEGIN
    SELECT * FROM EMPLOYEE;
END;
//
DELIMITER ;

-- Step 21: Let’s show department as 'Not Assigned' if NULL using IFNULL
SELECT name, IFNULL(department, 'Not Assigned') FROM EMPLOYEE;

-- Step 22: Categorize employees based on salary into High/Medium/Low
SELECT name, salary,
CASE
    WHEN salary > 60000 THEN 'High'
    WHEN salary BETWEEN 40000 AND 60000 THEN 'Medium'
    ELSE 'Low'
END AS salary_grade
FROM EMPLOYEE;

-- Step 23: Find departments with more than 1 employee
SELECT department, COUNT(*) AS emp_count
FROM EMPLOYEE
GROUP BY department
HAVING COUNT(*) > 1;

-- Step 24: What unique departments do we have?
SELECT DISTINCT department FROM EMPLOYEE;

-- Step 25: Fetch top 5 employees (e.g., for a leaderboard)
SELECT * FROM EMPLOYEE LIMIT 5;

-- Step 26: Employees earning between 40k–70k or in IT/HR
SELECT * FROM EMPLOYEE WHERE salary BETWEEN 40000 AND 70000;
SELECT * FROM EMPLOYEE WHERE department IN ('IT', 'HR');

-- Step 27: Company payroll transaction (shows START and BEGIN keywords — both valid)
START TRANSACTION; -- OR BEGIN;
INSERT INTO employee (id, name, salary, department) VALUES (2, 'Jane Doe', 60000, 'IT');
UPDATE employee SET salary = 65000 WHERE id = 2;
COMMIT;

-- Step 28: Something went wrong while hiring Bob — rollback!
START TRANSACTION;
INSERT INTO employee (id, name, salary, department) VALUES (3, 'Bob Smith', 55000, 'HR');
ROLLBACK;

-- Step 29: Revoke SELECT access from a user for security
REVOKE SELECT ON company_data.employee FROM 'someuser'@'localhost';

-- Step 30: Rank employees by salary within their departments
SELECT  
    id, name, salary, department,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employee;

-- Step 31: Give each employee a unique number within their department
SELECT  
    id, name, salary, department,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num
FROM employee;

-- Step 32: Who earns more than the average salary of their department?
WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employee
    GROUP BY department
)
SELECT e.id, e.name, e.salary, e.department
FROM employee e
JOIN dept_avg d ON e.department = d.department
WHERE e.salary > d.avg_salary;

-- Step 33: Get a count of total employees using a stored procedure
DELIMITER //
CREATE PROCEDURE GetEmployeeCount()
BEGIN
    SELECT COUNT(*) AS total_employees FROM employee;
END;
//
DELIMITER ;

-- Call the procedure
CALL GetEmployeeCount();

-- Step 34: Drop the salary change trigger if it exists
DROP TRIGGER IF EXISTS trg_salary_update;

-- Step 35: Create a recursive CTE to generate numbers from 1 to 10
WITH RECURSIVE numbers_cte AS (
    SELECT 1 AS num
    UNION ALL
    SELECT num + 1 FROM numbers_cte
    WHERE num < 10
)
SELECT * FROM numbers_cte;

-- Step 36: JSON time! Store product data in JSON and extract name/price
CREATE TABLE product_info (
    id INT,
    data JSON
);

INSERT INTO product_info (id, data)
VALUES
    (1, '{"name": "Laptop", "price": 1200, "stock": 25}'),
    (2, '{"name": "Phone", "price": 800, "stock": 100}');

SELECT
    id,
    JSON_EXTRACT(data, '$.name') AS product_name,
    JSON_EXTRACT(data, '$.price') AS product_price
FROM product_info;

-- Step 37: Full-Text Search (e.g., to search help articles)
CREATE TABLE articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title TEXT,
    content TEXT,
    FULLTEXT (title, content)
);

INSERT INTO articles (title, content)
VALUES  
    ('SQL Tutorial', 'Learn SQL from beginner to advanced.'),
    ('MySQL Indexing', 'Using FULLTEXT indexes to speed up search.');

-- Let’s search for anything with “SQL”
SELECT * FROM articles
WHERE MATCH(title, content)
AGAINST('SQL');

-- Step 38: Ranking sales team by region and amount
CREATE TABLE sales (
    id INT,
    employee VARCHAR(100),
    region VARCHAR(50),
    amount DECIMAL(10, 2)
);

INSERT INTO sales (id, employee, region, amount) VALUES
    (1, 'Alice', 'East', 1000),
    (2, 'Bob', 'East', 1500),
    (3, 'Charlie', 'West', 1200),
    (4, 'David', 'West', 1100);

SELECT
    employee,
    region,
    amount,
    RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS region_rank
FROM sales;

-- Step 39: Partition sales data by year of order
CREATE TABLE order_data (
    order_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);

-- Step 40: End of SQL Mastery Journey 🎉
SELECT 'SQL Learning Shell Completed Successfully!' AS message;
