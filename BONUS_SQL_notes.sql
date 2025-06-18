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

-- Suppose you need to find users that have given maximum number of ratings for the movies. DON'T make this mistake:-
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

--Using conditions to update a column value in SQL
SELECT
CASE WHEN id%2=0 then id-1
WHEN id%2!=0 AND id=(SELECT max(id) FROM Seat) THEN id
WHEN id%2!=0 THEN id+1 END AS id
FROM Seat

--  Return users by the number of tweets they posted in 2022 and count the number of users in each group.
WITH tweet_buckets AS (SELECT COUNT(tweet_id) AS tweet_bucket, user_id
FROM tweets
WHERE tweet_date BETWEEN '01/01/2022' AND '12/31/2022'
GROUP BY user_id)
SELECT tweet_bucket, COUNT(user_id) AS users_num
FROM tweet_buckets
GROUP BY tweet_bucket
-- In this question you have to use a CTE to figure out count of users in each group. You cannot simply use GROUP BY user_id, tweet_id or COUNT(tweet_id), COUNT(user_id) in SELECT
-- Instead find the number of tweets grouped by user_id, then find the number of users grouped by tweet buckets (tweet count)

-- Using aggregate functions along with window functions:-
SELECT *,
MIN(post_date) OVER(PARTITION BY user_id) AS first_post,
MAX(post_date) OVER(PARTITION BY user_id) AS last_post
FROM posts
-- Find number of days between first_post and last_post by:-
EXTRACT(DAY FROM last_post - first_post) AS days_between

-- For PostgreSQL use LIMIT n instead of TOP n which is for MySQL
LIMIT 2
-- LIMIT  n is same as TOP n

-- Self joins
-- Find employees whose salary is more than that of their manager.
SELECT DISTINCT e.employee_id, e.name AS employee_name
FROM employee AS e JOIN employee AS m ON m.employee_id=e.manager_id
WHERE e.salary > m.salary AND e.manager_id IS NOT NULL;
-- Join condition should be m.employee_id=e.manager_id and not e.employee_id=m.manager_id as there should be a match between e.manager_id and m.employee_id

-- Using once CTE in another CTE
WITH cte1 AS (
    SELECT ...
    FROM dbo.sometable
),
cte2 AS (
    SELECT ...
    FROM cte1
),
cte3 AS (
    SELECT ...
   FROM cte2
)

-- Difference between ROUND, FLOOR and CEIL
-- ROUND rounds up to the nearest Integer which can be above, below or equal to the actual value
-- ROUND Rounds to the nearest integer (or specified decimal places)
-- FLOOR rounds up to the nearest Integer which can be equal to or below the actual value
-- FLOOR Rounds down to the nearest integer (towards negative infinity)
-- CEIL rounds up to the nearest Integer which can be equal to or above the actual value
-- CEIL	Rounds up to the nearest integer (towards positive infinity)
-- Example:-
SELECT ROUND(3.14159);
-- Result: 3
SELECT FLOOR(3.14159);
-- Result: 3
SELECT CEIL(3.14159);
-- Result: 4
SELECT ROUND(3.7);
-- Result: 4
SELECT FLOOR(3.7);
-- Result: 3
SELECT CEIL(3.7);
-- Result: 4
SELECT ROUND(3.5);
-- Result: 4 (rounds up for .5)
SELECT ROUND(-3.5);
-- Result: -4 (rounds up for .5, meaning towards zero for negative numbers)
SELECT ROUND(-3.5);
-- Result: -4 (rounds up for .5, meaning towards zero for negative numbers)
SELECT ROUND(3.14159, 2);
-- Result: 3.14
SELECT ROUND(123.456, -1); -- Rounds to the nearest ten
-- Result: 120
SELECT ROUND(123.456, -2); -- Rounds to the nearest hundred
-- Result: 100
--Function	                            Behavior	                        Positive Number (e.g., 3.14, 3.7)	Negative Number (e.g., -3.14, -3.7)
--ROUND	      Rounds to the nearest integer (or specified decimal places)	              3, 4	                         -3, -4
--FLOOR	      Rounds down to the nearest integer (towards negative infinity)	          3, 3	                         -4, -4
--CEIL	      Rounds up to the nearest integer (towards positive infinity)	              4, 4	                         -3, -3

--In PostgreSQL, ROUND(double precision, integer) does not exist. For this reason you have to typecast the variable as numeric before using the round function
-- This will cause the error you saw
SELECT ROUND(my_float_column, 2) FROM your_table;
-- Correct way
SELECT ROUND(CAST(my_float_column AS NUMERIC), 2) FROM your_table;

-- If you want to handle NULL values in a column use COALESCE function in SQL. Example:-
SELECT
    employee_id,
    COALESCE(employee_name, 'Unknown') AS employee_name,
    COALESCE(employee_salary, 0) AS employee_salary
FROM
    employees;

-- Regular expressions in SQL using REGEXP keyword
-- ^ beginning
-- $ end
-- | logical or
-- [abcd] any of a,b,c,d
-- [a-f] range a to f

-- When there are two tables (Students and Grades) having columns Marks in Students and Min_Mark and Max_Mark in Grades then you can join on the condition:-
SELECT CASE WHEN g.Grade < 8 THEN NULL ELSE s.Name END AS Name, g.Grade, s.Marks
FROM Students AS s JOIN Grades AS g ON s.Marks BETWEEN g.Min_Mark AND g.Max_Mark
ORDER BY g.Grade DESC, s.Name

-- Using CTEs in join operations:-
WITH CTE as (...)
SELECT table_a AS a JOIN CTE AS c ON a.id = c.id

-- Creating a new group as a column in one CTE and using it in another CTE:-
WITH project_groups AS (
SELECT *,
    DATEADD(DAY, -ROW_NUMBER() OVER(ORDER BY Start_Date), End_Date) AS grp
    FROM Projects
), GroupedProjects AS (
SELECT MIN(Start_Date) AS project_start,
    MAX(End_Date) AS project_end,
    DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) AS project_days
    FROM project_groups
    GROUP BY grp
)
SELECT project_start, project_end
FROM GroupedProjects
ORDER BY project_days, project_start;
-- The above code creates a group column called grp where it groups all the start dates for a project into a single group called grp by using DATEADD() function.
-- Also, it uses ROW_NUMBER() function so that consecutive end and start dates can be combined into a single project group. Once that is done, a new project group
-- with new project start and end dates are created so that the number of project days can be calculated for each project grouping by grp that was created.

-- Whenever you are using 2 CTEs and referencing one CTE in another CTE be careful if the two CTEs have same column names and you are using * operator
WITH CTE1 AS (...), CTE2 AS (SELECT *
    FROM CTE1 JOIN CTE2) -- If CTE1 and CTE2 have same column names this will throw an error saying duplicate column name error. Instead do this:-
WITH CTE1 AS (...), CTE2 AS (
    SELECT c1.*, c2.*
    FROM CTE1 AS c1 JOIN CTE2 AS c2... -- This will select all columns from CTE1 and will work even if the same column names are present because
    -- SELECT * represents all columns from both CTEs which will result in an error due to duplicate column names, while c1.*, c2.* clearly differentiates the columns
    )

-- Multiple joins in SQL
SELECT a.*
FROM table1 AS a
JOIN table2 AS b ON a.id = b.id
JOIN table3 AS c ON a.class = c.class


-- Don't mix standard aggregate functions with window functions in the same query
-- The standard aggregate function MAX(count_challenges) attempts to collapse all rows from count_of_challenges into a single row to find the single maximum value.
-- However, the * and the COUNT(*) OVER(...) window function operate on each individual row. This conflict causes a syntax error in most SQL databases (including MySQL with the default ONLY_FULL_GROUP_BY setting).:-
WITH max_count_challenges AS (
    SELECT *,
    MAX(count_challenges) AS max_challenges, -- This is a standard aggregate function
    COUNT(*) OVER(PARTITION BY count_challenges) AS count_same_total -- This is a window function
    FROM count_of_challenges
)
-- Instead use use MAX() as a window function instead of an aggregate function. This allows you to calculate the overall maximum and append it to every row without collapsing the result set.
-- This allows you to calculate the overall maximum and append it to every row without collapsing the result set:-
WITH max_count_challenges AS (
    SELECT
        hacker_id,
        name,
        count_challenges,
        MAX(count_challenges) OVER () AS max_challenges, -- MAX() used as a window function
        COUNT(*) OVER (PARTITION BY count_challenges) AS count_same_total
    FROM count_of_challenges
)
-- Advantages of using CTE and subquery:-
-- CTE
-- Break Down Complex Queries:- Breaking down the query into smaller, more manageable components fosters effortless code maintenance and enhances comprehension.
-- Reusing Subquery Results:- When you need to use the same subquery result multiple times within a larger query, CTEs can be used to prevent redundant calculations.
-- Recursive Queries:- When you need to perform recursive queries, such as traversing hierarchical data like organizational structures or threaded discussions, CTEs are the ideal choice.
-- Subquery
-- Single-Value Comparison in WHERE Clauses:- When you need to compare a single value to a result from another query, utilize the subquery in the WHERE clause to enable dynamic data filtering.
-- Column Creation and Aggregation:- Utilize subqueries to create new columns for real-time computations and to calculate intermediate values for aggregation functions within larger queries.
-- Correlated Subqueries:- Utilize correlated subqueries to retrieve values from the outer query.

--Creating a temporary table in SQL:-
CREATE TEMP TABLE artists_clean AS
       SELECT *
       FROM artists
       WHERE birth_date IS NOT NULL;

-- If you have a timestamp column and you need only the date portion use the DATE keyword. For example:-
DATE(column_name)

-- If you need to check if a column name starts with a vowel or not use:-
LEFT(name, 1) IN ('a', 'e', 'i', 'o', 'u')

-- To format date column in SQL use TO_CHAR() function
TO_CHAR(date_column, 'Mon-YYYY') -- will return date column as May-2023

--The MAKE_DATE() function allows you to construct a date value from the specified year, month, and day values.
--Here’s the syntax of the MAKE_DATE() function:
-- MAKE_DATE( year int, month int, day int ) → date
SELECT MAKE_DATE(2023,3, 25); --returns 2023-03-25

-- Find transactions that are made within 10minutes having same merchant_id, amount, credit_card_id. Don't use:-
EXTRACT(MINUTE FROM b.timestamp) - EXTRACT(MINUTE FROM a.timestamp) <= 10
-- If the transactions are made on a different day but the minute is same that does not mean a 10minute difference. Instead use LAG() window function
-- and find out the previous timestamp. Then use INTERVAL keyword for PostgreSQL
LAG(transaction_timestamp, 1) OVER(PARTITION BY merchant_id, credit_card_id, amount) AS previous_timestamp -- Then use INTERVAL in where clause
WHERE (transaction_timestamp - previous_timestamp) <= INTERVAL '10 minutes'

--  For PostgreSQL, you can use filter keyword to get sum of specific values in column. Example:-
SUM(a.time_spent) FILTER(WHERE a.activity_type = 'send')
SUM(a.time_spent) FILTER(WHERE a.activity_type = 'open')

-- Finding rolling average in SQL syntax:-
AVG(tweet_count) OVER(PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
-- In this line rows between 2 preceding and current row gives the 3-day rolling average

-- Casting a column as a integer
COUNT(email_id) :: DECIMAL
-- This is particularly important when you have a division and it returns zero. In such cases use typecasting for numerator as mentioned above.

--Find customers who have brought at least 1 product from every product category:-
SELECT DISTINCT c.customer_id
FROM customer_contracts AS c JOIN products AS p ON c.product_id=p.product_id
WHERE p.product_category IN ('Analytics', 'Containers', 'Compute')
GROUP BY c.customer_id
HAVING COUNT(c.customer_id) = 3;
-- This is wrong as there could be customers who may have brought 2 products from 1 category and one from the other category with 0 products from last category
-- So, to correct this find individual count of each product_category by:-
WITH count_products AS (
SELECT c.customer_id,
COUNT(CASE WHEN p.product_category = 'Analytics' THEN p.product_id END) AS count_analytic,
COUNT(CASE WHEN p.product_category = 'Containers' THEN p.product_id END) AS count_containers,
COUNT(CASE WHEN p.product_category = 'Compute' THEN p.product_id END) AS count_compute
FROM customer_contracts AS c JOIN products AS p ON c.product_id = p.product_id
GROUP BY c.customer_id
)
SELECT customer_id
FROM count_products
WHERE count_analytic >= 1 AND count_containers >= 1 AND count_compute >= 1
;
-- A better solution would be to have the distinct count of product categories for each customer and comparing that with distinct product categories in product table:-
WITH super_cloud AS (
SELECT c.customer_id,
COUNT(DISTINCT p.product_category) AS product_count
FROM customer_contracts AS c JOIN products AS p ON c.product_id = p.product_id
GROUP BY c.customer_id
)
SELECT customer_id
FROM super_cloud
WHERE product_count = (SELECT COUNT(DISTINCT product_category) FROM products)
;

--Find users who shop on more than 3 consecutive days or more
SELECT DISTINCT t1.user_id
FROM transactions AS t1 JOIN transactions AS t2
ON DATE(t2.transaction_date) = DATE(t1.transaction_date) + 1
JOIN transactions AS t3
ON DATE(t3.transaction_date) = DATE(t2.transaction_date) + 1
ORDER BY t1.user_id
;
