# MySQL — Concepts & Notes

Personal study notes. Not a tutorial — just things I want to remember.

---

## Table of Contents

- [DDL vs DML vs DQL](#ddl-vs-dml-vs-dql)
- [Constraints](#constraints)
- [WHERE vs HAVING](#where-vs-having)
- [DELETE vs TRUNCATE vs DROP](#delete-vs-truncate-vs-drop)
- [Aggregate Functions](#aggregate-functions)
- [GROUP BY](#group-by)
- [Subqueries](#subqueries)
- [Views](#views)
- [Joins — Visual Guide](#joins--visual-guide)
- [Self Join](#self-join)
- [Foreign Keys & Cascading](#foreign-keys--cascading)
- [ALTER TABLE](#alter-table)
- [Gotchas & Tips](#gotchas--tips)

---

## DDL vs DML vs DQL

| Type | Full Name | Commands |
|------|-----------|----------|
| DDL | Data Definition Language | `CREATE`, `DROP`, `ALTER`, `TRUNCATE` |
| DML | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE` |
| DQL | Data Query Language | `SELECT` |

> DDL changes the **structure**. DML changes the **data**. DQL just **reads**.

---

## Constraints

| Constraint | Meaning |
|------------|---------|
| `PRIMARY KEY` | Unique + Not Null. One per table. |
| `NOT NULL` | Column must always have a value. |
| `UNIQUE` | No duplicates allowed in the column. |
| `DEFAULT` | Used when no value is provided on insert. |
| `FOREIGN KEY` | Links to a primary key in another table. |
| `CHECK` | Validates a condition before inserting. |

---

## WHERE vs HAVING

- `WHERE` filters **rows before** grouping.
- `HAVING` filters **groups after** `GROUP BY`.

```sql
-- WHERE filters individual rows first
SELECT * FROM student WHERE marks > 80;

-- HAVING filters the result of an aggregation
SELECT city, COUNT(*) FROM student
GROUP BY city
HAVING MAX(marks) > 90;
```

> You **cannot** use aggregate functions like `MAX()` inside `WHERE`. Use `HAVING` for that.

---

## DELETE vs TRUNCATE vs DROP

| Command | What it does | Rollback? | Keeps table? |
|---------|-------------|-----------|--------------|
| `DELETE` | Removes rows (can use `WHERE`) | Yes | Yes |
| `TRUNCATE` | Removes all rows instantly | No | Yes |
| `DROP` | Deletes the entire table | No | No |

---

## Aggregate Functions

Work on a set of rows and return a single value.

| Function | Returns |
|----------|---------|
| `COUNT(col)` | Number of non-null values |
| `SUM(col)` | Total |
| `AVG(col)` | Average |
| `MAX(col)` | Highest value |
| `MIN(col)` | Lowest value |

> `COUNT(*)` counts all rows including NULLs. `COUNT(col)` skips NULLs.

---

## GROUP BY

Groups rows with the same value in a column, so you can aggregate per group.

```sql
SELECT city, COUNT(name)
FROM student
GROUP BY city;
```

Order of clauses: `WHERE` → `GROUP BY` → `HAVING` → `ORDER BY`

---

## Subqueries

A query nested inside another query.

```sql
-- Scalar subquery (returns one value)
SELECT name FROM student
WHERE marks > (SELECT AVG(marks) FROM student);

-- List subquery (returns multiple values)
SELECT name FROM student
WHERE rollno IN (SELECT rollno FROM student WHERE rollno % 2 = 0);
```

> The inner query runs first. Its result is used by the outer query.

---

## Views

A **view** is a saved SELECT query stored as a virtual table. It doesn't store data itself.

```sql
CREATE VIEW student_marks AS
    SELECT rollno, name, marks FROM student;

SELECT * FROM student_marks;
```

**Why use views?**
- Simplify complex queries
- Hide sensitive columns from certain users
- Reuse query logic without repeating code

---

## Joins — Visual Guide

Two tables used in examples:

```
student_id          course
----------          ------
101  adam           102  english
102  bob            103  science
103  casey          105  math
                    107  computer science
```

| Join Type | Returns |
|-----------|---------|
| `INNER JOIN` | Only rows that match in **both** tables |
| `LEFT JOIN` | All rows from **left** table + matches from right (NULL if no match) |
| `RIGHT JOIN` | All rows from **right** table + matches from left (NULL if no match) |
| `FULL OUTER` | All rows from **both** tables (use UNION in MySQL) |
| Left Exclusive | Rows in **left only** — `WHERE right.id IS NULL` |
| Right Exclusive | Rows in **right only** — `WHERE left.id IS NULL` |

```
INNER       LEFT        RIGHT       FULL OUTER
 [A∩B]      [A+∩B]      [A∩+B]      [A+∩+B]
```

---

## Self Join

Joining a table **to itself**. Useful for hierarchical data like org charts.

```
employee
id    name     manager_id
101   adam     103
102   bob      104
103   casey    NULL        ← top-level manager
104   donald   103
```

```sql
SELECT a.name AS employee, b.name AS manager
FROM employee a
JOIN employee b ON a.manager_id = b.id;
```

Think of it as giving the same table **two aliases** so you can treat it as two separate tables.

---

## Foreign Keys & Cascading

A foreign key enforces that a value in one table must exist in another table.

```
dept (parent)          teacher (child)
--------------         ----------------
101  english           101  Ashok  dept_id=101
102  it                102  Ankit  dept_id=102
```

```sql
FOREIGN KEY (dept_id) REFERENCES dept(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
```

| Option | What happens to child rows |
|--------|---------------------------|
| `CASCADE` | Automatically updated/deleted |
| `SET NULL` | Set to NULL |
| `RESTRICT` | Blocks the parent change |
| `NO ACTION` | Same as RESTRICT (default) |

> Without `ON DELETE CASCADE`, you'd get an error trying to delete a dept that has teachers.

---

## ALTER TABLE

Used to change a table's **structure** after it's created.

```sql
-- Add a column
ALTER TABLE student ADD COLUMN age INT NOT NULL DEFAULT 19;

-- Change the datatype
ALTER TABLE student MODIFY COLUMN age VARCHAR(2);

-- Rename a column (also lets you change type)
ALTER TABLE student CHANGE age stu_age INT;

-- Remove a column
ALTER TABLE student DROP COLUMN stu_age;
```

---

## Gotchas & Tips

- **Safe update mode** — MySQL blocks `UPDATE`/`DELETE` without a `WHERE` by default.  
  Disable with: `SET SQL_SAFE_UPDATES = 0;`

- **UNION removes duplicates**; use `UNION ALL` to keep them.

- **Aliases don't carry to WHERE** — you can't use a column alias in its own `WHERE` clause.

- **NULL comparisons** — `NULL = NULL` is false in SQL. Use `IS NULL` / `IS NOT NULL`.

- **Order of execution** in a SELECT:  
  `FROM` → `JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY` → `LIMIT`
