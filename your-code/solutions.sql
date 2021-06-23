
-- Challenge 1 - Most Profiting Authors

/*
In this challenge you'll find out who are the top 3 most profiting authors in the publications database? Step-by-step guidances to train your problem-solving thinking will help you get through this lab.

In order to solve this problem, it is important for you to keep the following points in mind:

In table sales, a title can appear several times. The royalties need to be calculated for each sale.

Despite a title can have multiple sales records, the advance must be calculated only once for each title.

In your eventual solution, you need to sum up the following profits for each individual author:

All advances, which are calculated exactly once for each title.
All royalties in each sale.
Therefore, you will not be able to achieve the goal with a single SELECT query, you will need to use subqueries. Instead, you will need to follow several steps in order to achieve the solution. There is an overview of the steps below:

Calculate the royalty of each sale for each author and the advance for each author and publication.

Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances and total royalties of each title.

Below we'll guide you through each step. In your solutions.sql, please include the SELECT queries of each step so that your TA can review your problem-solving process.
*/
USE publications;
-- Check the tables authors,titleauthor, titles, sales

SELECT * FROM authors;
SELECT * FROM titleauthor;
SELECT * FROM titles;
SELECT * FROM sales;

-- We don't really need authors as we have authors id as a primary key in the titleauthors, and we don't need info form that table

SELECT ta.title_id, ta.au_id, ta.royaltyper, t.advance, t.royalty, s.qty,t.price FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id;


-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
/*
Write a SELECT query to obtain the following output:

Title ID
Author ID
Advance of each title and author
The formula is:
advance = titles.advance * titleauthor.royaltyper / 100
Royalty of each sale
The formula is:
sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100
Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers instead of floats.
In the output of this step, each title may appear more than once for each author. This is because a title can have more than one sale.
*/
-- sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100
/* WITH A SUBQUERY
SELECT  title_id,au_id, round((advance * royaltyper / 100),0) AS advance, round((price * qty * royalty / 100 * royaltyper / 100),0) AS sales_royalty  FROM
(SELECT ta.title_id, ta.au_id, ta.royaltyper, t.advance, t.royalty, s.qty,t.price FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id) as sub
ORDER BY au_id DESC;
*/


/* WITH MORE COLUMNS
SELECT ta.title_id, ta.au_id, ta.royaltyper, t.advance, t.royalty, s.qty, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id;
*/

SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC;

-- Step 2: Aggregate the total royalties for each title and author

/*
Using the output from Step 1, write a query, containing a subquery, to obtain the following output:

Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.
*/
-- the advance is the same 

SELECT au_id, title_id, advance AS advance_x_a_x_t, round(sum(sales_royalty),2) AS royalty_x_a_x_t FROM
(SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC) AS sub
GROUP BY au_id, title_id;

-- if we just group by au_id then we will not see the duplicates

-- the same author can have different titles



-- Step 3: Calculate the total profits of each author

SELECT au_id, sum(advance_x_a_x_t + royalty_x_a_x_t) AS profit FROM
(SELECT au_id, title_id, advance AS advance_x_a_x_t, round(sum(sales_royalty),2) AS royalty_x_a_x_t FROM
(SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC) AS sub
GROUP BY au_id, title_id) AS sub1
GROUP BY au_id
ORDER BY profit DESC;


/*
Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain the eventual output. Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:

Author ID
Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.
*/

-- Challenge 2 - Alternative Solution

/*

In the previous challenge, you have developed your solution the following way:

Derived tables (subqueries).(see reference)
We'd like you to try the other way:

Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
*/
-- step 1
CREATE TEMPORARY TABLE publications.royalty_advance
SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC;

-- step 2
-- DROP TEMPORARY TABLE publications.royalty_advance_x_a_x_t;

CREATE TEMPORARY TABLE publications.royalty_advance_x_a_x_t
SELECT au_id, title_id, advance AS advance_x_a_x_t, 
round(sum(sales_royalty),2) AS royalty_x_a_x_t FROM publications.royalty_advance
GROUP BY au_id, title_id;




-- step 3
SELECT au_id, sum(advance_x_a_x_t + royalty_x_a_x_t) AS profit FROM publications.royalty_advance_x_a_x_t
GROUP BY au_id
ORDER BY profit DESC;

-- Challenge 3

/*

Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. The table should have 2 columns:

au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
*/
CREATE TABLE publications.most_profiting_authors
SELECT au_id, sum(advance_x_a_x_t + royalty_x_a_x_t) AS profit FROM publications.royalty_advance_x_a_x_t
GROUP BY au_id
ORDER BY profit DESC;

