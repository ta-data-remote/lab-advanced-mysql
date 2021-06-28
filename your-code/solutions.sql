-- Challenge 1 - Most Profiting Authors

/* Keep in mind
In order to solve this problem, it is important for you to keep the following points in mind:

	In table sales, a title can appear several times. The royalties need to be calculated for each sale.

	Despite a title can have multiple sales records, the advance must be calculated only once for each title.

	In your eventual solution, you need to sum up the following profits for each individual author:

		* All advances, which are calculated exactly once for each title.
		* All royalties in each sale.
*/

/* Steps
Therefore, you will not be able to achieve the goal with a single SELECT query, you will need to use subqueries. Instead, you will need to follow several steps in order to achieve the solution. There is an overview of the steps below:

	1. Calculate the royalty of each sale for each author and the advance for each author and publication.

	2. Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

	3. Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances and total royalties of each title.
*/

-- Solution: 
-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication 
/* What to do
Write a SELECT query to obtain the following output:

	Title ID
	Author ID
	Advance of each title and author
		The formula is:
			advance = titles.advance * titleauthor.royaltyper / 100

	Royalty of each sale
		The formula is:
			sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100

		Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers instead of floats.

In the output of this step, each title may appear more than once for each author. This is because a title can have more than one sale.

*/

-- titleauthor: 
-- title_id, au_id, royaltyper
-- titles:
-- advance, royalty, title_id
-- sales:
-- qty, title_id
-- advance = titles.advance * titleauthor.royaltyper / 100
-- sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100


select 
ta.title_id, 
ta.au_id, 
t.advance * ta.royaltyper / 100 as advance, 
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as royalty_each_sale 
from titleauthor as ta
inner join titles as t
on t.title_id = ta.title_id
inner join sales as s
on s.title_id = ta.title_id
order by ta.title_id;



-- Step 2: Aggregate the total royalties for each title and author
/*What to do

Using the output from Step 1, write a query, containing a subquery, to obtain the following output:

	Title ID
	Author ID
	Aggregated royalties of each title for each author
		Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.

*/

select au_id, title_id, 
advance as new_advance, 
sum(royalty_each_sale) as sum_royalty from

(select 
ta.title_id, 
ta.au_id, 
t.advance * ta.royaltyper / 100 as advance, 
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as royalty_each_sale 
from titleauthor as ta
inner join titles as t
on t.title_id = ta.title_id
inner join sales as s
on s.title_id = ta.title_id
order by ta.title_id) as subquery

group by au_id, title_id;


-- Step 3: Calculate the total profits of each author
/* What to do

Now that each title has exactly one row for each author where the advance and royalties are available, 
we are ready to obtain the eventual output. 
Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:

	Author ID
	Profits of each author by aggregating the advance and total royalties of each title

Sort the output based on a total profits from high to low, and limit the number of rows to 3.

*/

select 
au_id, 
sum(new_advance + sum_royalty) as profit 
from
(select au_id, title_id, 
advance as new_advance, 
sum(royalty_each_sale) as sum_royalty from

(select 
ta.title_id, 
ta.au_id, 
t.advance * ta.royaltyper / 100 as advance, 
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as royalty_each_sale 
from titleauthor as ta
inner join titles as t
on t.title_id = ta.title_id
inner join sales as s
on s.title_id = ta.title_id
order by ta.title_id) as subquery

group by au_id, title_id) as subquery2
group by au_id
order by profit desc;

-- Challenge 2 - Alternative Solution
-- Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
-- Step 1:
create temporary table adv_roy_each_sale
select 
ta.title_id, 
ta.au_id, 
t.advance * ta.royaltyper / 100 as advance, 
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as royalty_each_sale 
from titleauthor as ta
inner join titles as t
on t.title_id = ta.title_id
inner join sales as s
on s.title_id = ta.title_id
order by ta.title_id;


-- Step2:
create temporary table agg_roy_each_title
select au_id, title_id, 
advance as new_advance, 
sum(royalty_each_sale) as sum_royalty from

adv_roy_each_sale  -- instead of the whole subquery

group by au_id, title_id;

-- Step 3:

select 
au_id, 
sum(new_advance + sum_royalty) as profit 
from
agg_roy_each_title
group by au_id
order by profit desc;

-- Challenge 3

/* What to do
Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. 
The table should have 2 columns:
	au_id - Author ID
	profits - The profits of the author aggregating the advances and royalties
*/

create table most_profiting_authors
select 
au_id, 
sum(new_advance + sum_royalty) as profit 
from
agg_roy_each_title
group by au_id
order by profit desc;

select * from most_profiting_authors;









