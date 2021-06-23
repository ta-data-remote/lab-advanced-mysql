/* Challenge 1 - Most Profiting Authors

In this challenge you'll find out who are the top 3 most profiting authors in the publications database? Step-by-step guidances to train your problem-solving thinking will help you get through this lab.

In order to solve this problem, it is important for you to keep the following points in mind:

In table sales, a title can appear several times. The royalties need to be calculated for each sale.

Despite a title can have multiple sales records, the advance must be calculated only once for each title.

In your eventual solution, you need to sum up the following profits for each individual author:

All advances, which are calculated exactly once for each title.
All royalties in each sale.
Therefore, you will not be able to achieve the goal with a single SELECT query, you will need to use subqueries. Instead, you will need to follow several steps in order to achieve the solution. There is an overview of the steps below:

Calculate the royalty of each sale for each author and the advance for each author and publication.

Using the output from Step 1 as a subquery, aggregate the total royalties for each title and author.

Using the output from Step 2 as a subquery, calculate the total profits of each author by aggregating the advances and total royalties of each title.

Below we'll guide you through each step. In your solutions.sql, please include the SELECT queries of each step so that your TA can review your problem-solving process.

Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

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

Step 2: Aggregate the total royalties for each title and author

Using the output from Step 1, write a query, containing a subquery, to obtain the following output:

Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.

Step 3: Calculate the total profits of each author

Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain the eventual output. Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:

Author ID
Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.

Challenge 2 - Alternative Solution

In the previous challenge, you have developed your solution the following way:

Derived tables (subqueries).(see reference)
We'd like you to try the other way:

Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
Include your alternative solution in solutions.sql.

Additional Learning

In the context of this lab, you may use either the derived table or the temp table way to develop the solution. You may feel the former is more convenient than the latter way. However, you need to know each way is suitable in certain contexts. Derived tables are kept in the MySQL runtime memory and will be lost once the query execution is completed. In contrast, temp tables are physically -- though temporarily -- stored in MySQL. As long as your user session is not expired, you can access the data in the temp tables readily.

If the data in your database is changing frequently, each time when you use derived tables to retrieve information, you may find the results are different. In contrast, once the temp tables are created, the data stored in the temp tables are persistent. Even if the relevant data in your database have changed, the data in the temp tables will remain the same unless you have updated the temp data. Therefore, if you care about the timeliness of the results, you should use derived tables so that you will always receive the latest information.

However, if your data are massive and queries are complicated, you receive signficiant performance benefits by using temp tables. Because when you use temp tables, the time-consuming calculations (which we call expensive database transactions) are only performed once and the results are persistent. When you query the temp tables repeatedly, you will not perform expensive transactions again and again in your database.

Challenge 3

Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. The table should have 2 columns:

au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
Include your solution in solutions.sql. */
USE publications;
-- First challenge author, title author, titles and sales
-- au_id
Select * from sales;
Select * from titles;
Select * from titleauthor;

Select a.au_id, a.title_id, a.royaltyper, b.advance ,b.royalty, c.qty FROM titleauthor as a
JOIN titles as b
ON a.title_id = b.title_id
JOIN sales as c
ON b.title_id = c.title_id;

select a.au_id, a.title_id, round((advance * royaltyper / 100),0) as advance, round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty FROM titleauthor as a
JOIN titles as b
ON a.title_id = b.title_id
JOIN sales as c
ON b.title_id = c.title_id
Order by au_id desc;


select au_id, title_id, round((advance * royaltyper / 100),0) as advance1, round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty from
	(select a.au_id, a.title_id, a.royaltyper, b.advance ,b.royalty,b.price, c.qty FROM titleauthor as a
	JOIN titles as b
	ON a.title_id = b.title_id
	JOIN sales as c
	ON b.title_id = c.title_id
    Order by au_id desc) as sub;
    
    select au_id, title_id, round((advance * royaltyper / 100),0) as advance1, round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty from
	(select a.au_id, a.title_id, a.royaltyper, b.advance ,b.royalty,b.price, c.qty FROM titleauthor as a
	JOIN titles as b
	ON a.title_id = b.title_id
	JOIN sales as c
	ON b.title_id = c.title_id
    Order by au_id desc) as sub;
    
 Select au_id,title_id, advance as total_advance, sum(sales_royalty) as total_royalty from   
(select a.au_id, a.title_id, round((advance * royaltyper / 100),0) as advance, round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty FROM titleauthor as a
JOIN titles as b
ON a.title_id = b.title_id
JOIN sales as c
ON b.title_id = c.title_id) as sub
Group by au_id, title_id
Order by total_advance desc;

Select au_id,sum(total_advance + total_royalty) as total_profits from
(Select au_id,title_id, advance as total_advance, sum(sales_royalty) as total_royalty from   
(select a.au_id, a.title_id, round((advance * royaltyper / 100),0) as advance, round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty FROM titleauthor as a
JOIN titles as b
ON a.title_id = b.title_id
JOIN sales as c
ON b.title_id = c.title_id) as sub
Group by au_id, title_id
Order by total_advance desc) as sub1
Group by au_id
Order by total_profits Desc;


-- temporary table step 1
create temporary table  publications.royalty_advance
select a.au_id, a.title_id, 
round((advance * royaltyper / 100),0) as advance, 
round((price * qty * royalty / 100 * royaltyper / 100),0) as sales_royalty FROM titleauthor as a
JOIN titles as b
ON a.title_id = b.title_id
JOIN sales as c
ON b.title_id = c.title_id
Order by au_id desc;


-- temporary table step 2
create temporary table  publications.new_royalty_advance
Select au_id,title_id, 
advance as total_advance, sum(sales_royalty) as total_royalty from publications.royalty_advance 
Group by au_id, title_id
Order by total_advance desc;

select * from publications.new_royalty_advance

-- temporary table step 3 

Create temporary table publications.new1_royalty_advance
Select au_id,sum(total_advance + total_royalty) as total_profits from publications.new_royalty_advance
Group by au_id
Order by total_profits Desc;

select * from publications.new1_royalty_advance

-- constant table
Create table publications_new
Select au_id,sum(total_advance + total_royalty) as total_profits from publications.new_royalty_advance
Group by au_id
Order by total_profits Desc;

select * from publications_new