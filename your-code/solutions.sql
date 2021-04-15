use publications;
SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Challenge 1 - Most Profiting Authors
/*
In table sales, a title can appear several times. The royalties need to be calculated for each sale.

Despite a title can have multiple sales records, the advance must be calculated only once for each title.

In your eventual solution, you need to sum up the following profits for each individual author:

	All advances, which are calculated exactly once for each title.
	All royalties in each sale.
*/
-- 1. Calculate the royalty of each sale for each author and the advance for each author and publication.

select ta.au_id, s.title_id, (t.advance * ta.royaltyper / 100) as Advance, (t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as Sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on ta.title_id = s.title_id;

-- 2. Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

select au_id, title_id, sum(Sales_royalty) as Total_royalty, Advance from
(select ta.au_id, s.title_id, round((t.advance * ta.royaltyper / 100),2) as Advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as Sales_royalty 
from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on ta.title_id = s.title_id) as sub
group by au_id, title_id;

-- 3. Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances and total royalties of each title.

select au_id, round(sum(Total_royalty + Advance),2) as Total from
(select au_id, title_id, sum(Sales_royalty) as Total_royalty, Advance from
(select ta.au_id, s.title_id, round((t.advance * ta.royaltyper / 100),2) as Advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as Sales_royalty 
from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on ta.title_id = s.title_id) as sub
group by au_id, title_id) as sub2
group by au_id
order by Total desc
limit 3;

-- Challenge 2 - Alternative Solution
-- Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
-- Step 1
drop temporary table royalty_advance;
create temporary table royalty_advance
(select ta.au_id, s.title_id, round((t.advance * ta.royaltyper / 100),2) as Advance, round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as Sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on ta.title_id = s.title_id);

-- Step 2
drop temporary table Total_Royalty;
create temporary table Total_Royalty
(select au_id, title_id, sum(Sales_royalty) as Total_royalty, Advance
from royalty_advance
group by au_id, title_id);

-- Step 3
drop temporary table Total_Profits;
create temporary table Total_Profits
(select au_id, sum(Total_royalty + Advance) as Profits 
from Total_Royalty
group by au_id
order by Profits desc
limit 3);

select * from Total_Profits;

-- Challenge 3
/*
create a permanent table named most_profiting_authors to hold the data about the most profiting authors. 
The table should have 2 columns:
	au_id - Author ID
	profits - The profits of the author aggregating the advances and royalties
*/

drop table most_profiting_authors;
create table most_profiting_authors
select au_id, sum(Total_royalty + Advance) as Profits 
from Total_Royalty
group by au_id
order by Profits desc;

SELECT * FROM most_profiting_authors;



