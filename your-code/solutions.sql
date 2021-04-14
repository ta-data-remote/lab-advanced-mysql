use publications;

-- Challenge 1 - Most Profiting Authors

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

SELECT ta.title_id as `Title ID`, a.au_id as `Author ID`, s.qty as `QUANTITY`, 
round(t.advance * ta.royaltyper / 100, 1) as `ADVANCE`,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as `SALES ROYALTY`
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ;

-- Step 2: Aggregate the total royalties for each title and author

SELECT `Author ID`,`Title ID`, sum(`SALES ROYALTY`) as `SUM SALES ROYALTY`, `ADVANCE` FROM (
SELECT ta.title_id as `Title ID`, a.au_id as `Author ID`, s.qty as `QUANTITY`, 
round(t.advance * ta.royaltyper / 100, 1) as `ADVANCE`,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as `SALES ROYALTY`
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ) as sub
group by `Author ID`,`Title ID`;

-- Step 3: Calculate the total profits of each author

SELECT `Author ID`, SUM(`SUM SALES ROYALTY` + `ADVANCE`) as `PROFIT`
FROM (
SELECT `Author ID`,`Title ID`, sum(`SALES ROYALTY`) as `SUM SALES ROYALTY`, `ADVANCE` FROM (
SELECT ta.title_id as `Title ID`, a.au_id as `Author ID`, s.qty as `QUANTITY`, 
round(t.advance * ta.royaltyper / 100, 1) as `ADVANCE`,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as `SALES ROYALTY`
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ) as sub
group by `Author ID`,`Title ID`) as sub2
group by `Author ID`
order by `PROFIT` desc
limit 3;


-- Challenge 2 - Alternative Solution, temporary table

CREATE TEMPORARY TABLE IF NOT EXISTS Tempo
SELECT ta.title_id as `Title ID`, a.au_id as `Author ID`, s.qty as `QUANTITY`, 
round(t.advance * ta.royaltyper / 100, 1) as `ADVANCE`,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as `SALES ROYALTY`
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id;

SELECT * FROM Tempo;

-- Step 2

CREATE TEMPORARY TABLE IF NOT EXISTS Tempo2
SELECT `Author ID`,`Title ID`, sum(`SALES ROYALTY`) as `SUM SALES ROYALTY`, `ADVANCE` FROM Tempo
group by `Author ID`,`Title ID`;

-- Step 3

SELECT `Author ID`, SUM(`SUM SALES ROYALTY` + `ADVANCE`) as `PROFIT` FROM Tempo2
group by `Author ID`
order by `PROFIT` desc
limit 3;

-- Challenge 3 - Create a permanent table

create table if not exists publications.most_profiting_authors
SELECT `Author ID`, SUM(`SUM SALES ROYALTY` + `ADVANCE`) as `PROFIT`
FROM (
SELECT `Author ID`,`Title ID`, sum(`SALES ROYALTY`) as `SUM SALES ROYALTY`, `ADVANCE` FROM (
SELECT ta.title_id as `Title ID`, a.au_id as `Author ID`, s.qty as `QUANTITY`, 
round(t.advance * ta.royaltyper / 100, 1) as `ADVANCE`,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as `SALES ROYALTY`
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ) as sub
group by `Author ID`,`Title ID`) as sub2
group by `Author ID`
order by `PROFIT` desc
limit 3;





