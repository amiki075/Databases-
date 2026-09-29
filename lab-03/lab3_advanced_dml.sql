--Part A: Database and Table Setup
--1.Create database
CREATE DATABASE advanced_lab;
--Switch the connection to advanced_lab before running the rest of the file
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50) NOT NULL,
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

--Sample
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Arman',  'Bekov',    'IT',    85000, '2018-05-10', 'Active'),
    ('Dana',   'Kim',      'IT',    62000, '2019-11-01', 'Active'),
    ('Timur',  'Ospanov',  'Sales', 55000, '2021-02-15', 'Active'),
    ('Madina', 'Aliyeva',  'Sales', 45000, '2022-07-20', 'Inactive'),
    ('Yerlan', 'Zhakupov', 'HR',    38000, '2023-06-01', 'Terminated'),
    ('Aliya',  'Serikova', NULL,    35000, '2023-09-10', 'Active');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES
    ('CRM System',       1, '2021-01-10', '2022-06-30', 120000),
    ('Website Redesign', 2, '2023-03-01', '2024-01-15',  40000),
    ('Mobile App',       1, '2024-02-01', '2025-05-01',  90000);

--Part B:Advanced INSERT Operations
--2.INSERT with column specification
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (100, 'Aigerim', 'Nurlanova', 'IT');

--3.INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Dias', 'Omarov', 'Sales', DEFAULT, '2021-03-15', DEFAULT);

--4.INSERT multiple rows in single statement
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT',    150000, 1),
    ('Sales',  90000, 3),
    ('HR',     60000, 5);

--5.INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Taubai', 'Erasyl', 'IT', 50000 * 1.1, CURRENT_DATE);

--6.INSERT from SELECT (subquery)
CREATE TEMP TABLE temp_employees (LIKE employees);

INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';

--Part C:Complex UPDATE Operations
--7.UPDATE with arithmetic expressions
UPDATE employees SET salary = salary * 1.1;

SELECT emp_id, first_name, salary FROM employees ORDER BY emp_id;

--8.UPDATE with WHERE clause and multiple conditions
UPDATE employees SET status = 'Senior' WHERE salary > 6000 AND hire_date < '2020-01-01';

SELECT emp_id,first_name,salary,hire_date,status FROM employees ORDER BY emp_id;

--9.UPDATE using CASE expression
BEGIN;

UPDATE employees
SET department = CASE
    WHEN salary > 80000                 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

SELECT emp_id, first_name, salary, department FROM employees ORDER BY emp_id;

ROLLBACK;

--10.UPDATE with DEFAULT
UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';
SELECT emp_id,first_name,department,status FROM employees WHERE status = 'Inactive';

--11.UPDATE with subquery
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
);

--12.UPDATE multiple columns
UPDATE employees SET salary = salary * 1.15,status = 'Promoted' WHERE department = 'Sales';

--Part D:advanced delete operations
--13.DELETE with simple WHERE condiotion
DELETE FROM employees
WHERE status = 'Terminated';

--14.DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

--15.DELETE with subquery
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

--16.DELETE with RETURNING clause
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--Part E.Operation with NULL Values
--17.INSERT with NULL Values
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bekzat', 'Tulegenov', NULL, NULL, '2024-01-15');

--18.UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--19.DELETE with NUll conditions
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

--Part F:RETURNING clause Operations
--20.INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Saule', 'Ermekova', 'IT', 70000, '2025-03-01')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

--21.UPDATE with RETURNING
--RETURNING shows the new salary, so the old one is salary - 5000
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

--22.DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--Part G.Advanced DML patterns
--23.Conditional INSERT
-- The row is inserted only if no employee with the same name exists
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Nurlan', 'Abenov', 'IT', 60000, DATE '2024-05-01'
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Nurlan'
      AND last_name = 'Abenov'
);

--24.UPDATE with JOIN logic using subqueries
-- The subquery finds the budget of the employee's department
UPDATE employees e
SET salary = salary * CASE
    WHEN (SELECT d.budget
          FROM departments d
          WHERE d.dept_name = e.department) > 100000 THEN 1.10
    ELSE 1.05
END;

--25.Bulk Operations
-- The same hire_date lets the UPDATE target exactly these five employees
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Asel',   'Mukanova',  'IT',    50000, '2026-09-01'),
    ('Erlan',  'Dosov',     'IT',    52000, '2026-09-01'),
    ('Kamila', 'Rakhimova', 'IT',    54000, '2026-09-01'),
    ('Ruslan', 'Iskakov',   'Sales', 56000, '2026-09-01'),
    ('Zarina', 'Baitova',   'Sales', 58000, '2026-09-01');

UPDATE employees
SET salary = salary * 1.10
WHERE hire_date = '2026-09-01';

--26.Data migration simulation
CREATE TABLE employee_archive (LIKE employees);
--Transaction: copy and delete must succeed togethe
BEGIN;

INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

COMMIT;

--27.Complex business logic
--Inner subquery: department name by dept_id; outer: number of its employees
UPDATE projects p
SET end_date = end_date + 30
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;



