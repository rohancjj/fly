# 📘 MySQL Learning Notes

A personal reference covering core MySQL concepts — from basic queries to joins, aggregations, constraints, and more.

---

## Table of Contents

1. [Database & Table Setup](#1-database--table-setup)
2. [Basic Queries](#2-basic-queries)
3. [Filtering & Sorting](#3-filtering--sorting)
4. [Aggregate Functions & GROUP BY](#4-aggregate-functions--group-by)
5. [UPDATE & DELETE](#5-update--delete)
6. [ALTER TABLE](#6-alter-table)
7. [JOINS](#7-joins)
8. [Self Join](#8-self-join)
9. [Subqueries](#9-subqueries)
10. [Views](#10-views)
11. [Foreign Keys & Cascading](#11-foreign-keys--cascading)

---

## 1. Database & Table Setup

```sql
-- Create and select a database
CREATE DATABASE college;
USE college;

-- Create a student table
CREATE TABLE student (
  rollno INT PRIMARY KEY,
  name   VARCHAR(50),
  marks  INT NOT NULL,
  grade  VARCHAR(1),
  city   VARCHAR(20)
);

-- Insert records
INSERT INTO student (rollno, name, marks, grade, city) VALUES
  (101, 'anil',    78, 'C', 'Pune'),
  (102, 'bhumika', 93, 'A', 'Mumbai'),
  (103, 'chetan',  85, 'B', 'Mumbai'),
  (104, 'dhruv',   96, 'A', 'Delhi'),
  (105, 'emanuel', 12, 'F', 'Delhi'),
  (106, 'farah',   82, 'B', 'Delhi');

-- Remove all rows without dropping the table
TRUNCATE TABLE student;

-- Delete the table entirely
DROP TABLE student;
```

---

## 2. Basic Queries

```sql
-- Select all columns
SELECT * FROM student;

-- Select specific columns
SELECT rollno, name FROM student;

-- Select distinct values
SELECT DISTINCT city FROM student;
```

---

## 3. Filtering & Sorting

```sql
-- WHERE clause
SELECT * FROM student WHERE marks > 80;
SELECT * FROM student WHERE city = 'Mumbai';

-- AND / OR
SELECT * FROM student WHERE marks > 80 AND city = 'Mumbai';
SELECT * FROM student WHERE marks > 80 OR city = 'Mumbai';

-- IN
SELECT * FROM student WHERE city IN ('Mumbai', 'Delhi');

-- BETWEEN
SELECT * FROM student WHERE marks BETWEEN 80 AND 90;

-- LIMIT
SELECT * FROM student LIMIT 3;
SELECT * FROM student WHERE marks > 80 LIMIT 3;

-- ORDER BY
SELECT * FROM student ORDER BY city ASC;
SELECT * FROM student ORDER BY marks DESC LIMIT 3;
```

---

## 4. Aggregate Functions & GROUP BY

```sql
-- Aggregate functions
SELECT MAX(marks) FROM student;
SELECT MIN(marks) FROM student;
SELECT AVG(marks) FROM student;
SELECT COUNT(name) FROM student;
SELECT SUM(marks) FROM student;

-- MAX marks per city
SELECT MAX(marks) FROM student WHERE city = 'Delhi';

-- GROUP BY: count students per city
SELECT city, COUNT(name) FROM student GROUP BY city;

-- HAVING: filter grouped results
SELECT COUNT(name), city 
FROM student 
GROUP BY city 
HAVING MAX(marks) > 90;

-- Filter rows above average marks
SELECT name, marks FROM student
WHERE marks > (SELECT AVG(marks) FROM student);
```

---

## 5. UPDATE & DELETE

```sql
-- Allow updates without a key condition (disable safe mode)
SET SQL_SAFE_UPDATES = 0;

-- Update a specific row
UPDATE student SET marks = 100 WHERE rollno = 105;

-- Update grade based on marks range
UPDATE student SET grade = 'B' WHERE marks BETWEEN 80 AND 90;
UPDATE student SET grade = 'O' WHERE marks BETWEEN 91 AND 100;

-- Update all rows
UPDATE student SET marks = marks + 10;

-- Delete rows matching a condition
DELETE FROM student WHERE marks < 30;

-- Re-insert a deleted row
INSERT INTO student VALUES (105, 'Rohan', 50, 'D', 'Delhi');
```

---

## 6. ALTER TABLE

```sql
-- Add a column
ALTER TABLE student ADD COLUMN age INT NOT NULL DEFAULT 19;

-- Modify a column's datatype
ALTER TABLE student MODIFY COLUMN age VARCHAR(2);

-- Rename a column
ALTER TABLE student CHANGE age stu_age INT;

-- Drop a column
ALTER TABLE student DROP COLUMN age;
```

---

## 7. JOINS

> Uses two tables: `student(id, name)` and `course(id, course)`

```sql
CREATE TABLE student (
  id   INT PRIMARY KEY,
  name VARCHAR(50)
);

CREATE TABLE course (
  id     INT PRIMARY KEY,
  course VARCHAR(50)
);

INSERT INTO student VALUES (101, 'adam'), (102, 'bob'), (103, 'casey');
INSERT INTO course VALUES (102, 'english'), (105, 'math'), (103, 'science'), (107, 'computer science');
```

### INNER JOIN — only matching rows

```sql
SELECT * FROM student s
INNER JOIN course c ON s.id = c.id;
```

### LEFT JOIN — all students, matched courses or NULL

```sql
SELECT * FROM student s
LEFT JOIN course c ON s.id = c.id;
```

### RIGHT JOIN — all courses, matched students or NULL

```sql
SELECT * FROM student s
RIGHT JOIN course c ON s.id = c.id;
```

### FULL OUTER JOIN (via UNION)

```sql
SELECT * FROM student s LEFT  JOIN course c ON s.id = c.id
UNION
SELECT * FROM student s RIGHT JOIN course c ON s.id = c.id;
```

### LEFT EXCLUSIVE JOIN — students with no course

```sql
SELECT * FROM student s
LEFT JOIN course c ON s.id = c.id
WHERE c.id IS NULL;
```

### RIGHT EXCLUSIVE JOIN — courses with no student

```sql
SELECT * FROM student s
RIGHT JOIN course c ON s.id = c.id
WHERE s.id IS NULL;
```

---

## 8. Self Join

> A table joined with itself — useful for hierarchical data like employees and managers.

```sql
CREATE TABLE employee (
  id         INT PRIMARY KEY,
  name       VARCHAR(50),
  manager_id INT
);

INSERT INTO employee VALUES
  (103, 'casey',  NULL),
  (101, 'adam',   103),
  (102, 'bob',    104),
  (104, 'donald', 103);

-- Get each employee with their manager's name
SELECT a.name AS employee, b.name AS manager
FROM employee a
JOIN employee b ON a.manager_id = b.id;
```

---

## 9. Subqueries

```sql
-- Students with even roll numbers (using subquery)
SELECT name, rollno FROM student
WHERE rollno IN (
  SELECT rollno FROM student WHERE rollno % 2 = 0
);

-- Students scoring above average
SELECT name, marks FROM student
WHERE marks > (SELECT AVG(marks) FROM student);
```

---

## 10. Views

> A view is a saved SELECT query — like a virtual table.

```sql
-- Create a view
CREATE VIEW view1 AS
SELECT rollno, name, marks FROM student;

-- Query the view like a table
SELECT * FROM view1;
```

---

## 11. Foreign Keys & Cascading

```sql
CREATE TABLE dept (
  id   INT PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO dept VALUES (101, 'english'), (102, 'it');

CREATE TABLE teacher (
  id      INT PRIMARY KEY,
  name    VARCHAR(50),
  dept_id INT,
  FOREIGN KEY (dept_id) REFERENCES dept(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

INSERT INTO teacher VALUES (101, 'Ashok', 101), (102, 'Ankit', 102);

-- Updating dept id automatically updates teacher's dept_id (CASCADE)
UPDATE dept SET id = 103 WHERE id = 102;

-- Deleting a dept automatically deletes related teachers (CASCADE)
-- DELETE FROM dept WHERE id = 101;
```

> **ON UPDATE CASCADE** — changes to the parent key propagate to the child.  
> **ON DELETE CASCADE** — deleting the parent also deletes related child rows.

---

## Quick Reference

| Command | Purpose |
|---|---|
| `CREATE TABLE` | Define a new table |
| `INSERT INTO` | Add rows |
| `SELECT` | Query data |
| `WHERE` | Filter rows |
| `ORDER BY` | Sort results |
| `GROUP BY` | Aggregate by column |
| `HAVING` | Filter grouped results |
| `UPDATE` | Modify existing rows |
| `DELETE` | Remove rows |
| `ALTER TABLE` | Modify table structure |
| `TRUNCATE` | Remove all rows (fast) |
| `DROP TABLE` | Delete the table |
| `JOIN` | Combine rows from multiple tables |
| `VIEW` | Save a query as a virtual table |
| `FOREIGN KEY` | Enforce referential integrity |

---

*Notes compiled while learning MySQL fundamentals.*
