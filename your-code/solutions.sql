-- INTRODUCTION

USE publications;

-- CHALLENGE 1 - Most Profiting Authors

SELECT * FROM titles;

SELECT * FROM titleauthor;

SELECT tit.title_id AS Title, titau.au_id AS Author, ROUND(tit.advance*titau.royaltyper/100,2)
AS Advance, ROUND(tit.price*sa.qty*tit.royalty/100*titau.royaltyper/100,2) AS Royalty
FROM titleauthor AS titau
JOIN titles AS tit
ON titau.title_id=tit.title_id
JOIN sales AS sa
ON tit.title_id=sa.title_id;

SELECT Title, Author, SUM(Royalty) AS Total_Royalties, Advance
FROM (
	SELECT tit.title_id AS Title, titau.au_id AS Author, ROUND(tit.advance*titau.royaltyper/100,2)
    AS Advance, ROUND(tit.price*sa.qty*tit.royalty/100*titau.royaltyper/100,2) AS Royalty
	FROM titleauthor AS titau
	JOIN titles AS tit
	ON titau.title_id=tit.title_id
	JOIN sales AS sa
	ON tit.title_id=sa.title_id
) AS sub1
GROUP BY Author, Title;

SELECT Author, SUM(Total_Royalties+Advance) AS Profit
FROM (
	SELECT Title, Author, SUM(Royalty) AS Total_Royalties, Advance
	FROM (
		SELECT tit.title_id AS Title, titau.au_id AS Author, ROUND(tit.advance*titau.royaltyper/100,2)
		AS Advance, ROUND(tit.price*sa.qty*tit.royalty/100*titau.royaltyper/100,2) AS Royalty
		FROM titleauthor AS titau
		JOIN titles AS tit
		ON titau.title_id=tit.title_id
		JOIN sales AS sa
		ON tit.title_id=sa.title_id
	) AS sub1
	GROUP BY Author, Title
) AS sub2
GROUP BY Author
ORDER BY Profit DESC
LIMIT 3;

-- CHALLENGE 2 - Alternative Solution

CREATE TEMPORARY TABLE IF NOT EXISTS step1
SELECT tit.title_id AS Title, titau.au_id AS Author, ROUND(tit.advance*titau.royaltyper/100,2)
AS Advance, ROUND(tit.price*sa.qty*tit.royalty/100*titau.royaltyper/100,2) AS Royalty
FROM titleauthor AS titau
JOIN titles AS tit
ON titau.title_id=tit.title_id
JOIN sales AS sa
ON tit.title_id=sa.title_id;

SELECT * FROM step1;

CREATE TEMPORARY TABLE IF NOT EXISTS step2
SELECT Title, Author, SUM(Royalty) AS Total_Royalties, Advance
FROM step1
GROUP BY Author, Title, Advance;

SELECT * FROM step2;

CREATE TEMPORARY TABLE IF NOT EXISTS step3
SELECT Author, SUM(Total_Royalties+Advance) AS Profit
FROM step2
GROUP BY Author
ORDER BY Profit DESC
LIMIT 3;

SELECT * FROM step3;

-- CHALLENGE 3 - Permanent storage

CREATE TABLE IF NOT EXISTS most_profiting_authors
SELECT Author, SUM(Total_Royalties+Advance) AS Profit
FROM step2
GROUP BY Author
ORDER BY Profit DESC;

SELECT * FROM most_profiting_authors;
