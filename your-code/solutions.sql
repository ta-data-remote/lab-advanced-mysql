USE publications;

-- CHALLENGE 1 - Most Profiting Authors
-- STEP 1: Calculate the royalty of each sale for each author and the advance for each author and publication
/*
· Title ID
· Author ID
· Advance of each title and author

		The formula is:
		advance = titles.advance * titleauthor.royaltyper / 100

· Royalty of each sale

		The formula is:
		sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100
        
Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers 
instead of floats.
In the output of this step, each title may appear more than once for each author. 
This is because a title can have more than one sale.
*/

SELECT ta.au_id, ta.title_id, ta.royaltyper FROM titleauthor as ta
INNER JOIN sales as s
ON ta.title_id = s.title_id;

SELECT * FROM titleauthor; -- from here we get the titleauthor.royaltyper (2 times, one for each formula)

SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id
ORDER BY ta.title_id, ta.au_id;


-- STEP 2 - Aggregate the total royalties for each title and author

SELECT au_id, title_id, advance, sum(total_royalty) AS total_royalties FROM
(SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id) as sub
GROUP BY ta.au_id, ta.title_id
ORDER BY ta.au_id, ta.title_id;

-- Step 3: Calculate the total profits of each author
/*
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:

· Author ID
· Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.
*/

(SELECT au_id, title_id, advance, sum(total_royalty) AS total_royalties FROM
(SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id) AS sub
GROUP BY ta.au_id, ta.title_id
ORDER BY ta.au_id, ta.title_id) AS sub2;



-- CHALLENGE 2 - ALTERNATIVE SOLUTION with temp tables.

CREATE TEMPORARY TABLE sub_table1
SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty 
FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id
ORDER BY ta.au_id;

DROP TABLE IF EXISTS sub_table2;
CREATE TEMPORARY TABLE sub_table2
SELECT au_id, title_id, advance, sum(total_royalty) as total_roalties
FROM sub_table1
GROUP BY title_id, au_id;

DROP TABLE IF EXISTS sub_table3;
CREATE TEMPORARY TABLE sub_table3
SELECT au_id, (total_roalties + advance) AS total_profits 
FROM sub_table2
GROUP BY au_id
ORDER BY total_profits DESC;

-- Show Top3
SELECT * 
FROM sub_tabel3
LIMIT 3;


-- CHALLENGE 3 - Show Top3 using perma table from temp table

CREATE TABLE most_profiting_authors
SELECT au_id, total_profits FROM sub_table3;
