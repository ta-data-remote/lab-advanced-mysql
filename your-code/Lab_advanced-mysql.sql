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

*/

use publications;

/* Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
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

select distinct(a.au_id) as authors, t.title_id, round((£t.advance * a.royaltyper / 100),0) as advances, round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100),0) as total_royalty from titleauthor as a
join titles as t
on a.title_id = t.title_id
join sales as s
on a.title_id = s.title_id
order by authors desc;

/* Step 2: Aggregate the total royalties for each title and author
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
*/

select au_id, title_id, advances, round(sum(total_royalty),2) as summ_royal from
(select a.au_id, t.title_id, round((t.advance * a.royaltyper / 100),0) as advances, round((t.price * s.qty * t.royalty / 100 * a.royaltyper / 100),0) as total_royalty from titleauthor as a
join titles as t
on a.title_id = t.title_id
join sales as s
on a.title_id = s.title_id
order by a.au_id desc) as sub
group by au_id, title_id;


SELECT au_id, sum(advances + summ_royalty) AS profit FROM
(SELECT au_id, title_id, advance AS advances, round(sum(sales_royalty),2) AS summ_royal FROM
(SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC) AS sub
GROUP BY au_id, title_id) AS sub1
GROUP BY au_id
ORDER BY profit DESC;



/* Challenge 2 - Alternative Solution
In the previous challenge, you have developed your solution the following way:

Derived tables (subqueries).(see reference)
We'd like you to try the other way:

Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
Include your alternative solution in solutions.sql.
*/

CREATE TEMPORARY TABLE publications.royalty_advance
SELECT ta.title_id, ta.au_id, 
round((t.advance * ta.royaltyper / 100),0) AS advance, 
round((t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100),0) AS sales_royalty FROM titleauthor AS ta
JOIN titles AS t
ON ta.title_id = t.title_id
JOIN sales AS s
ON t.title_id = s.title_id
ORDER BY ta.au_id DESC;

CREATE TEMPORARY TABLE publications.royalty_advances
SELECT au_id, title_id, advance AS advances, 
round(sum(sales_royalty),2) AS summ_royalty FROM publications.royalty_advance
GROUP BY au_id, title_id;


SELECT au_id, sum(advances + summ_royalty) AS profit FROM publications.royalty_advances
GROUP BY au_id
ORDER BY profit DESC;


/* Challenge 3
Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors to hold the data about the most profiting authors. The table should have 2 columns:

au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
Include your solution in solutions.sql.

Additional Learning
To balance the performance of database transactions and the timeliness of the data, software/data engineers often schedule automatic scripts to query the data periodically and save the results in persistent summary tables. Then when needed they retrieve the data from the summary tables instead of performing the expensive database transactions again and again. In this way, the results will be a little outdated but the data we want can be instantly retrieved.
*/


CREATE TABLE publications.most_profiting_authors
SELECT au_id, sum(advances + summ_royalty) AS profit FROM publications.royalty_advances
GROUP BY au_id
ORDER BY profit DESC;