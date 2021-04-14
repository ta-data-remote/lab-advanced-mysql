-- Challenge 1 - Most Profiting Authors

USE publications;

-- Who are the top 3 most profiting authors in the publications database?

-- STEP 1

SELECT t.title_id, a.au_id, 
round((t.advance * a.royaltyper / 100), 2) as advance,
round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100), 2) as sales_royalty
FROM titles t
JOIN titleauthor a
ON t.title_id = a.title_id
JOIN sales s
ON t.title_id = s.title_id
ORDER BY sales_royalty DESC
LIMIT 3;
 
 -- STEP 2
 
 SELECT title_id, au_id, SUM(sales_royalty) as agg_royalty FROM
 (SELECT t.title_id, a.au_id, 
round((t.advance * a.royaltyper / 100), 2) as advance,
round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100), 2) as sales_royalty
FROM titles t
JOIN titleauthor a
ON t.title_id = a.title_id
JOIN sales s
ON t.title_id = s.title_id
ORDER BY sales_royalty DESC) as sub
GROUP BY au_id, title_id;
 
 -- STEP 3
 
SELECT au_id, SUM(agg_royalty) as agg_royalty, SUM(agg_advance) as agg_advance
FROM
	(SELECT title_id, au_id, SUM(sales_royalty) as agg_royalty, SUM(advance) as agg_advance
	FROM
		(SELECT t.title_id, a.au_id, 
		round((t.advance * a.royaltyper / 100), 2) as advance,
		round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100), 2) as sales_royalty
		FROM titles t
		JOIN titleauthor a
		ON t.title_id = a.title_id
		JOIN sales s
		ON t.title_id = s.title_id
		ORDER BY sales_royalty DESC) as sub
	GROUP BY au_id, title_id) as sub2
    GROUP BY au_id
    ORDER BY agg_advance DESC
    LIMIT 3;
 
-- Challenge 2

DROP TEMPORARY TABLE agg_royalty_advance;
CREATE TEMPORARY TABLE agg_royalty_advance(
SELECT title_id, au_id, SUM(sales_royalty) as agg_royalty, SUM(advance) as agg_advance
	FROM
		(SELECT t.title_id, a.au_id, 
		round((t.advance * a.royaltyper / 100), 2) as advance,
		round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100), 2) as sales_royalty
		FROM titles t
		JOIN titleauthor a
		ON t.title_id = a.title_id
		JOIN sales s
		ON t.title_id = s.title_id
		ORDER BY sales_royalty DESC) as sub
	GROUP BY au_id, title_id);
    
SELECT * FROM agg_royalty_advance;
    
SELECT au_id, SUM(agg_royalty) as agg_royalty, SUM(agg_advance) as agg_advance
FROM agg_royalty_advance
GROUP BY au_id
ORDER BY agg_advance DESC
LIMIT 3;
    
-- Challenge 3

CREATE TEMPORARY TABLE final(
SELECT au_id, SUM(agg_royalty) as agg_royalty, SUM(agg_advance) as agg_advance
FROM agg_royalty_advance
GROUP BY au_id
ORDER BY agg_advance DESC);

DROP TABLE most_profiting_authors;
CREATE TABLE most_profiting_authors
SELECT * FROM final
ORDER BY agg_royalty DESC;

SELECT * FROM most_profiting_authors