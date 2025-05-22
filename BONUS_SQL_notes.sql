--In SQL queries, clauses are executed based on the following order:
    FROM and/or JOIN clause.
    WHERE clause.
    GROUP BY clause.
    HAVING clause.
    SELECT clause.
    DISTINCT clause.
    ORDER BY clause.
    LIMIT and/or OFFSET clause.

--Using aggregate functions with window functions in SQL
SUM(quantity) OVER(PARTITION BY id) as total

--Return month number from date
SELECT EXTRACT(month FROM timestamp '2020-11-30 09:30:20') AS month; returns answer as 11

-- Title Case In Sql
SELECT INITCAP(item) AS item_title FROM table_name; returns title case for item -> EX:- thai curry becomes Thai Curry

-- COUNT OF NULL values in SQL
COUNT(*) -> includes NULL values while COUNT(column_name) excludes NULL values

-- Using LIKE command in SQL
Return data where column name starts with p: WHERE column_name LIKE 'p%'
-- If the character(s) appears after a word then use a space after the first %. For example:-
WHERE column_name LIKE '% DIAB1%'

-- VERY IMPORTANT QUESTION IN INTERVIEWS:- Find second-largest salary of employees
--First find Maximum Salary of Employees by:-
SELECT MAX(salary)
FROM Employees
--Second find salary that is not Maximum Salary by:-
SELECT salary
FROM Employees
WHERE Salary NOT IN (SELECT MAX(salary) FROM Employees)
--Lastly, find maximum salary from the answer obtained above. We have salaries that are not maximum salaries. So, maximum of these should give us second maximum by:-
SELECT MAX(salary)
FROM Employees
WHERE Salary NOT IN (SELECT MAX(salary) FROM Employees)

--How to add multiple values of one column in the same line in SQL
-- There are two ways to solve this:-
STRING_AGG(column_name, ',') AS combined_value
-- If for some reason STRING_AGG is not available use this:-
GROUP_CONCAT(column_name, ',') AS combined_value

-- To find records between a range of dates always use between. For example, you want to find out products ordered in February 2020 then use:-
WHERE order_date BETWEEN '2020-02-01' AND '2020-02-29'

-- Not all database systems support the SELECT TOP clause. MySQL supports the LIMIT clause to select a limited number of records, while Oracle uses FETCH FIRST n ROWS ONLY and ROWNUM

-- Difference between rows between and range between in SQL
--  ROWS BETWEEN: It defines the window based on the physical position of the rows above or below relative to the current row.
-- RANGE BETWEEN: It defines the window based on the logical relationship based on the column.


-- Using aggregate functions with a condition.
-- Sometimes you need to use aggregate functions based on a certain condition. In those case you have to use case when and wrap the aggregate function over it. For example:-
SUM(CASE WHEN c.action = 'confirmed' then c.user_id else 0 end)

-- Regular expressions in SQL. Sometimes like keyword is not suitable for complex patterns then similar to Python regular expressions can be used for pattern matching. Example:-
-- Determine users with valid email ids from the table with conditions:-
-- Start with a letter
-- Can have only dot, underscore and dash characters allowed in the email
-- Must have the domain name @leetcode.com
SELECT user_id, name, mail
FROM Users
WHERE mail REGEXP '^[a-zA-Z]{1}[a-zA-Z0-9_.-]*@leetcode[.]com$'
-- ^[a-zA-Z]{1} - first character should be a letter a-z or A-Z
--[a-zA-Z0-9_.-]* - Then you can have alphanumeric characters along with _.-
-- *@leetcode[.]com$ - Ending with domain name @leetcode.com only

-- Difference between rank and dense rank window function:- Rank skips a level when there are duplicates while dense rank does not skip a level.
-- For example:-
SELECT *,
       RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) AS rnk
FROM Department
-- Will return 1,2,2,4 if there are duplicate values for salary.
SELECT *,
       DENSE_RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) AS drnk
FROM Department
-- Will return 1,2,2,3 if there are duplicate values for salary.

--To delete duplicate values from a table you can use two aliases for table. For example, you want to delete duplicate email ids you can reference them with p1 and p2.
-- Then you can use p1.email = p2.email (duplicate emails) and p1.id > p2.id (p1.id and p2.id refer different entries)
DELETE p1
FROM Person as p1, Person as p2
WHERE p1.email = p2.email and p1.id > p2.id

-- Convert characters to upper and lower case in SQL
-- Use SUBSTRING() function to locate the characters then use LOWER or UPPER to change the case.
-- For example:- You are given a task to change the first letter to upper case and the remaining letters to lower case
SELECT user_id,
CONCAT(UPPER(SUBSTRING(name, 1, 1)), LOWER(SUBSTRING(name, 2, LENGTH(name)))) AS name
FROM Users
-- SUBSTRING(name, 1, 1) - first character
-- UPPER(SUBSTRING(name, 1, 1)) - converts first character to upper case
-- SUBSTRING(name, 2, LENGTH(name) - from second character to the end of string
-- LOWER(SUBSTRING(name, 2, LENGTH(name)) - converts second character to end of string to lower
-- CONCAT(UPPER(SUBSTRING(name, 1, 1)), LOWER(SUBSTRING(name, 2, LENGTH(name))))  - concatenate the obtained results to form the new string

-- Get last n characters from a name in SQL
SUBSTRING(name, -n)

-- Difference between union and union all:-
-- Union returns unique values only while union all returns the duplicate values as well
-- While using union or union all always ensure that the number of column values are the same in both the queries
WITH all_friends as (
SELECT requester_id
FROM RequestAccepted
UNION
SELECT accepter_id
FROM RequestAccepted
)
-- Returns 1, 2, 3, 4
WITH all_friends as (
SELECT requester_id
FROM RequestAccepted
UNION ALL
SELECT accepter_id
FROM RequestAccepted
)
-- Returns 1, 1, 2, 2, 3, 3, 3, 4

-- Using multiple aliases for a table and running a subquery
-- Lets say you have to use multiple aliases for a single table and then use subqueries. To make this work always refer the alias used in outer query inside the inner query.
-- And not the other way round. Example:-
SELECT ROUND(SUM(a.tiv_2016), 2) AS tiv_2016
FROM Insurance a
WHERE a.tiv_2015 IN (SELECT b.tiv_2015 FROM insurance b WHERE a.pid <> b.pid)
AND
(a.lat, a.lon) NOT IN (SELECT c.lat, c.lon FROM Insurance c WHERE a.pid <> c.pid)
-- Notice how in the above query we are using alias a inside the two subqueries having alias b and c.

-- Suppose you need to find users that have given maximum number of ratings for the movies. DONT make this mistake:-
SELECT user_id
FROM users
GROUP BY user_id
HAVING COUNT(rating) = (SELECT MAX(COUNT(rating)) FROM users)
-- Instead do this
SELECT user_id
FROM users
GROUP BY user_id
ORDER BY COUNT(rating) DESC
LIMIT 1
-- In the first query the subquery is wrong as it does not have a group by. A simpler way to solve this without having clause is to use the aggregate function in order by clause
