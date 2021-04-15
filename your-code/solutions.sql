use publications;

-- ----------- --
-- Challenge 1:
-- ----------- --

-- Step 1.
select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,2) as advance_calc, round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as sales_royalty_calc from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id;

-- Step 2.
select title_id, au_id, advance_calc, sum(sales_royalty_calc) from
(select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,2) as advance_calc, round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as sales_royalty_calc from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id) as sub
group by au_id, title_id;


-- Step 3.
select au_id, sum(profits+advance_calc) as profits_sum from
(select title_id, au_id, advance_calc, sum(sales_royalty_calc) profits from
(select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,2) as advance_calc, round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100,2) as sales_royalty_calc from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id) as sub1
group by au_id, title_id) as sub2
group by au_id
order by profits_sum desc
limit 3;


-- ----------- --
-- Challenge 2:
-- ----------- --

drop temporary table if exists publications.calculations_title_author;
create temporary table if not exists publications.calculations_title_author
select t.title_id, ta.au_id, round(t.advance * ta.royaltyper / 100,2) as advance_calc, round(sum(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),2) as sales_royalty_calc from titles as t
join titleauthor as ta
on t.title_id = ta.title_id
join sales as s
on t.title_id = s.title_id
group by ta.au_id, t.title_id;

drop temporary table if exists publications.calculation_sum;
create temporary table if not exists publications.calculation_sum
select au_id, sum(sales_royalty_calc+advance_calc) as SR from calculations_title_author
group by au_id
order by SR desc;


-- ----------- --
-- Challenge 3:
-- ----------- --
drop table if exists publications.most_profiting_authors;
create table if not exists publications.most_profiting_authors
select au_id, sum(sales_royalty_calc+advance_calc) as SR from calculations_title_author
group by au_id
order by SR desc;

