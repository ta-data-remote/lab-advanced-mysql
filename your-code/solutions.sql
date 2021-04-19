USE publications;

-- CHALLENGE 1
-- top 3 most profiting authors
-- 1 Calculate the royalty of each sale for each author and the advance for each author and publication.
-- Write a SELECT query to obtain the following output:

-- Step 1
SELECT 
	t.title_id, 
    ta.au_id, 
	round((t.advance * ta.royaltyper / 100),2) as advance,
	round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty
FROM titles AS t
INNER JOIN titleauthor AS ta
ON t.title_id = ta.title_id
INNER JOIN sales AS s
ON t.title_id = s.title_id;

-- Step 2
-- 2 Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

SELECT 
	title_id, 
	au_id, 
    sum(sales_royalty) as royalty_total,
    advance
from 
(SELECT t.title_id, ta.au_id,
round((t.advance * ta.royaltyper / 100),2) as advance,
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty
FROM titles AS t
INNER JOIN titleauthor AS ta
ON t.title_id = ta.title_id
INNER JOIN sales AS s
ON t.title_id = s.title_id) as sub
GROUP BY au_id, title_id
ORDER BY royalty_total DESC;

-- Step 3
-- 3 Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating 
-- the advances and total royalties of each title.

SELECT 
	a.au_lname, 
    a.au_fname,
	author_id, 
    sum(royalty_total + advance) as benefits_final
FROM
	(SELECT -- sub2
		title_id, 
		au_id as author_id, 
		sum(sales_royalty) as royalty_total,
		advance
	FROM 
		(SELECT -- sub1
			t.title_id, 
            ta.au_id,
			round((t.advance * ta.royaltyper / 100),2) as advance,
			round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty
		FROM titles AS t
		INNER JOIN titleauthor AS ta
		ON t.title_id = ta.title_id
		INNER JOIN sales AS s
		ON t.title_id = s.title_id) as sub	
	GROUP BY au_id, title_id
	ORDER BY royalty_total DESC) as sub2

JOIN authors as a
ON a.au_id = author_id
GROUP BY author_id
ORDER BY benefits_final DESC
LIMIT 3;

-- CHALLENGE 2

CREATE TEMPORARY TABLE Benefits_per_auth_id
SELECT 
	a.au_lname, 
    a.au_fname,
	author_id, 
    sum(royalty_total + advance) as benefits_final
FROM
	(SELECT -- sub2
		title_id, 
		au_id as author_id, 
		sum(sales_royalty) as royalty_total,
		advance
	FROM 
		(SELECT -- sub1
			t.title_id, 
            ta.au_id,
			round((t.advance * ta.royaltyper / 100),2) as advance,
			round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty
		FROM titles AS t
		INNER JOIN titleauthor AS ta
		ON t.title_id = ta.title_id
		INNER JOIN sales AS s
		ON t.title_id = s.title_id) as sub	
	GROUP BY au_id, title_id
	ORDER BY royalty_total DESC) as sub2

JOIN authors as a
ON a.au_id = author_id
GROUP BY author_id
ORDER BY benefits_final DESC
LIMIT 3;

SELECT * FROM Benefits_per_auth_id;

-- CHALLENGE 3

create table if not exists Benefits_per_auth_id
SELECT 
	a.au_lname, 
    a.au_fname,
	author_id, 
    sum(royalty_total + advance) as benefits_final
FROM
	(SELECT -- sub2
		title_id, 
		au_id as author_id, 
		sum(sales_royalty) as royalty_total,
		advance
	FROM 
		(SELECT -- sub1
			t.title_id, 
            ta.au_id,
			round((t.advance * ta.royaltyper / 100),2) as advance,
			round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty
		FROM titles AS t
		INNER JOIN titleauthor AS ta
		ON t.title_id = ta.title_id
		INNER JOIN sales AS s
		ON t.title_id = s.title_id) as sub	
	GROUP BY au_id, title_id
	ORDER BY royalty_total DESC) as sub2

JOIN authors as a
ON a.au_id = author_id
GROUP BY author_id
ORDER BY benefits_final DESC
LIMIT 3;