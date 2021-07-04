-- Challenge 1 - Most Profiting Authors 										https://github.com/Desikim/lab-advanced-mysql
-- Who are the top 3 most profiting authors in the publications database?

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

SELECT ta.au_id, ta.title_id, ta.royaltyper, t.advance, t.royalty, s.qty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id;

-- Same result but using a subquery
SELECT  title_id,au_id, round((advance * royaltyper / 100),0) AS advance, round((price * qty * royalty / 100 * royaltyper / 100),0) AS sales_royalty  FROM
(SELECT ta.title_id, ta.au_id, ta.royaltyper, t.advance, t.royalty, s.qty,t.price FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id) as sub
ORDER BY au_id DESC;

-- Without subquery but same result (?)
SELECT ta.title_id, ta.au_id, round((t.advance * ta.royaltyper / 100),0) AS advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC;

-- Step 2: Aggregate the total royalties for each title and author

SELECT title_id, au_id, sum(advance) AS total_advance, sum(sales_royalty) AS total_roalty FROM
(SELECT ta.title_id, ta.au_id, round((t.advance * ta.royaltyper / 100),0) AS advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC) AS sub
GROUP BY title_id, au_id;

-- Step 3: Calculate the total profits of each author

-- advance * total_royalty per author

SELECT au_id, (total_roalty + total_advance) AS total_profits
FROM
(SELECT title_id, au_id, sum(advance) AS total_advance, sum(sales_royalty) AS total_roalty FROM
(SELECT ta.title_id, ta.au_id, round((t.advance * ta.royaltyper / 100),0) AS advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC) AS sub
GROUP BY title_id, au_id) AS sub2
GROUP BY au_id
ORDER BY total_profits DESC;

-- Challenge 2 - Alternative Solution

-- We'd like you to try the other way:
-- Creating MySQL temporary tables and query the temporary tables in the subsequent steps

CREATE TEMPORARY TABLE sub_1
SELECT ta.title_id, ta.au_id, round((t.advance * ta.royaltyper / 100),0) AS advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC;

CREATE TEMPORARY TABLE sub_2
SELECT title_id, au_id, sum(advance) AS total_advance, sum(sales_royalty) AS total_roalty 
FROM sub_1
GROUP BY title_id, au_id;

CREATE TEMPORARY TABLE sub_3
SELECT au_id, (total_roalty + total_advance) AS total_profits
FROM sub_2
GROUP BY au_id
ORDER BY total_profits DESC;

SELECT * FROM sub_3
LIMIT 3;

-- Challenge 3

-- Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. 
-- The table should have 2 columns:
-- au_id - Author ID
-- profits - The profits of the author aggregating the advances and royalties

CREATE TABLE most_profiting_authors
SELECT * FROM sub_3; 

SELECT * FROM most_profiting_authors
LIMIT 3;