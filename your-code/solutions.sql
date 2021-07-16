use publications

-- CHALLENGE 1
-- STEP 1
-- Write a SELECT query to obtain the following output:
-- Title ID, Author ID
-- Advance of each title and author. The formula is: advance = titles.advance * titleauthor.royaltyper / 100
-- Royalty of each sale. The formula is: sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100

select ta.title_id, a.au_id, ta.royaltyper, 
round((t.advance * ta.royaltyper / 100)) as advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100)) as total_royalty
from authors as a
join titleauthor as ta
on a.au_id = ta.au_id
join titles as t
on ta.title_id = t.title_id
join sales as s
on t.title_id = s.title_id;

-- STEP 2: Aggregate the total royalties for each title and author
select title_id, au_id, advance, sum(total_royalty) as total_royalty from
(select ta.title_id, a.au_id,
round((t.advance * ta.royaltyper / 100)) as advance,
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as total_royalty
from authors a
join titleauthor ta
on a.au_id = ta.au_id
join titles t
on ta.title_id = t.title_id
join sales s
on t.title_id = s.title_id) as sub
group by au_id, title_id
order by total_royalty desc;


-- STEP 3: Calculate the total profits of each author
SELECT au_id, SUM(advance+total_royalty) AS profits
FROM (SELECT  title_id, au_id, advance ,  SUM(royalty) AS total_royalty 
FROM (SELECT ta.au_id , ta.title_id , 
	   ROUND(t.advance * ta.royaltyper / 100) AS advance , 
       t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS royalty
FROM titleauthor AS ta

INNER JOIN titles AS t
ON ta.title_id = t.title_id

INNER JOIN sales AS s
ON ta.title_id = s.title_id) AS first_query 

GROUP BY au_id, title_id
ORDER BY total_royalty DESC) AS second_query

GROUP BY au_id
ORDER BY profits DESC
LIMIT 3;

-- CHALLENGE 2: Alternative solution.
DROP TABLE ro_adv;
CREATE TEMPORARY TABLE ro_adv
SELECT  title_id, au_id, advance ,  SUM(royalty) AS total_royalty 
FROM (SELECT ta.au_id , ta.title_id , 
	   ROUND(t.advance * ta.royaltyper / 100) AS advance , 
       t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS royalty
FROM titleauthor AS ta

INNER JOIN titles AS t
ON ta.title_id = t.title_id

INNER JOIN sales AS s
ON ta.title_id = s.title_id) AS first_query 

GROUP BY au_id, title_id
ORDER BY total_royalty DESC;

-- From temp table, same total profits for each author:
SELECT au_id, SUM(advance+total_royalty) AS profits
FROM ro_adv
GROUP BY au_id
ORDER BY profits DESC
LIMIT 3;


-- CHALLENGE 3:
drop table if exists most_profiting_authors;
create table if not exists most_profiting_authors(
select au_id, sum(advance+total_royalty) as profits from
(select title_id, au_id, advance, sum(total_royalty) as total_royalty from
(select ta.title_id,
a.au_id, 
round((t.advance * ta.royaltyper / 100))  as advance,
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as total_royalty
from authors a
join titleauthor ta
on a.au_id = ta.au_id
join titles t
on ta.title_id = t.title_id
join sales s
on t.title_id = s.title_id) as sub
group by au_id, title_id
order by total_royalty desc) as sub
group by au_id
order by profits desc
limit 3);

select * from most_profiting_authors;