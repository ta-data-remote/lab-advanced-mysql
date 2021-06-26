use publications;

-- Challenge 1 - Most Profiting Authors

-- STEP 1: Calculate the royalty of each sale for each author and the advance for each author and publication
select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100, 0) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 0) as total_royalty 
from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id;


-- STEP 2: Aggregate the total royalties for each title and author
select title_id, au_id, advance, sum(total_royalty) as total_royalty
from
(select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,0) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as total_royalty
from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id) as sub
group by au_id, title_id;

-- STEP 3: Calculate the total profits of each author
select au_id, round(sum(total_royalty + advance),0) as profits
from
(select title_id, au_id, advance, sum(total_royalty) as total_royalty
from
(select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,0) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as total_royalty
from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id) as sub
group by au_id, title_id) as sub2
group by au_id
order by profits desc
limit 3;

-- Challenge 2 - Alternative Solution with temporary tables

-- STEP 1: Royalty and advance calculated
drop temporary table if exists publications.royalty_and_advance_calc;
create temporary table if not exists publications.royalty_and_advance_calc
select t.title_id, ta.au_id, t.advance * ta.royaltyper / 100 as advance,
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as total_royalty 
from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id;

select * from publications.royalty_and_advance_calc;

-- STEP 2: Aggregate total royalty
drop temporary table if exists publications.aggr_total_royalty;
create temporary table if not exists publications.aggr_total_royalty
select title_id, au_id, round(advance,0) as advance, round(sum(total_royalty),2) as total_royalty
from
publications.royalty_and_advance_calc
group by au_id, title_id;

select * from publications.aggr_total_royalty;

-- STEP 3: total profits

drop temporary table if exists publications.total_profit;
create temporary table if not exists publications.total_profit
select au_id, round(sum(total_royalty + advance),0) as profits
from publications.aggr_total_royalty
group by au_id
order by profits desc;

select * from publications.total_profit
limit 3;

-- Challenge 3 - creating new table with most profiting authors

drop table if exists publications.most_profiting_authors;
create table if not exists publications.most_profiting_authors
select au_id, round(sum(total_royalty + advance),0) as profits
from
(select title_id, au_id, advance, sum(total_royalty) as total_royalty
from
(select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,0) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as total_royalty
from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id) as sub
group by au_id, title_id) as sub2
group by au_id
order by profits desc;

select * from publications.most_profiting_authors
limit 3;

show create table publications.most_profiting_authors;