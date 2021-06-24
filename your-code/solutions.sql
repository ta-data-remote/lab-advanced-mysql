USE publications;

SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';



-- Step 1
CREATE TEMPORARY TABLE sub1
SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty 
FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id
ORDER BY ta.au_id

-- Step2 
CREATE TEMPORARY TABLE sub2
SELECT au_id, title_id, advance, sum(total_royalty) as total_roalties
FROM(
SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty 
FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id
ORDER BY ta.au_id) as sub1
GROUP BY ta.au_id, ta.title_id
ORDER BY ta.au_id, ta.title_id;

-- Step 3 

SELECT au_id, (total_royalties + advance) AS total_profits 
FROM
(SELECT au_id, title_id, advance, sum(total_royalty) AS total_royalties 
FROM
(SELECT ta.title_id, ta.au_id,
round((ti.advance * ta.royaltyper / 100))  AS advance, -- FORMULAS GIVEN TO US
round((ti.price * s.qty * ti.royalty / 100 * ta.royaltyper / 100)) AS total_royalty FROM titleauthor as ta 
INNER JOIN sales as s
ON ta.title_id = s.title_id
LEFT JOIN titles as ti
ON s.title_id = ti.title_id) AS sub
GROUP BY ta.au_id, ta.title_id
ORDER BY ta.au_id, ta.title_id) AS sub2
GROUP BY au_id
ORDER BY total_profits DESC;

-- CHALLENGE 2 do the same with with sub tables.

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

DROP TABLE sub_table2;
CREATE TEMPORARY TABLE sub_table2
SELECT au_id, title_id, advance, sum(total_royalty) as total_roalties
FROM sub_table1
GROUP BY title_id, au_id;

CREATE TEMPORARY TABLE sub_tabel3
SELECT au_id, (total_roalties + advance) AS total_profits 
FROM sub_table2
GROUP BY au_id
ORDER BY total_profits DESC;

-- Only display the top3
SELECT * 
FROM sub_tabel3
LIMIT 3;


-- Challenge 3 Create permanent Table from temporary table

CREATE TABLE most_profiting_authors
SELECT * FROM sub_tabel3;
