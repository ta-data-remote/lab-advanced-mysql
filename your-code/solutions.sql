
USE publications;
/*
Challenge 1 - Most Profiting Authors
In order to solve this problem, it is important for you to keep the following points in mind:
In table sales, a title can appear several times. The royalties need to be calculated for each sale.
Despite a title can have multiple sales records, the advance must be calculated only once for each title.
In your eventual solution, you need to sum up the following profits for each individual author:
All advances, which are calculated exactly once for each title.
All royalties in each sale.

-- tables:
-- sales : title_id
-- titles: title_id, title, royalty, advance

*/
select * from sales;
select * from titles;
select * from sales;

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

-- Calculate the royalty of each sale for each author and the advance for each author and publication.
-- table - authors: au_id
-- table - titleauthor: au_id, title_id, royaltyper
-- table - titles: title_id, advance,royalty
-- table - sales: qty, title_id

select ta.title_id,
a.au_id, 
round((t.advance * ta.royaltyper / 100))  as advance,
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100)) as sales_royalty
from authors a
join titleauthor ta
on a.au_id = ta.au_id
join titles t
on ta.title_id = t.title_id
join sales s
on t.title_id = s.title_id;

-- Step 2: Aggregate the total royalties for each title and author
/*
Using the output from Step 1, write a query, containing a subquery, to obtain the following output:
Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.
*/

select title_id, au_id, advance, sum(total_royalty) as total_royalty from
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
order by total_royalty desc;

/*
Step 3: Calculate the total profits of each author :
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:
- Author ID
- Profits of each author by aggregating the advance and total royalties of each title
- Sort the output based on a total profits from high to low, and limit the number of rows to 3.
*/

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
limit 3;

-- Challenge 2 - Alternative Solution: 
-- creating temporary tables from all step 2 and step 3:
drop table if exists publications.advance_royalty;
create temporary table if not exists publications.advance_royalty
select ta.title_id,
a.au_id, 
round((t.advance * ta.royaltyper / 100))  as advance,
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100)) as sales_royalty
from authors a
join titleauthor ta
on a.au_id = ta.au_id
join titles t
on ta.title_id = t.title_id
join sales s
on t.title_id = s.title_id;


DROP TABLE IF EXISTS publications.adv_total_royalty;
create temporary table if not exists publications.adv_total_royalty
select title_id, au_id, advance, sum(total_royalty) as total_royalty from
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
order by total_royalty desc;

drop table if exists publications.profits;
create temporary table if not exists publications.profits
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
limit 3;

select * from publications.advance_royalty;
select * from publications.adv_total_royalty;
select * from publications.profits;


/*
Challenge 3
-- creating permanent table - most_profiting_authors for most profiting authors
*/

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
limit 3
);

-- check output after creating a permanent table : most_profiting_authors
select * from most_profiting_authors;


