Use publications;

#Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

SELECT ta.title_id, ta.au_id,
round((t.advance * ta.royaltyper/100),0) as advance,
round((t.price * s.qty*t.royalty/100 * ta.royaltyper/100),0) as sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on t.title_id = s.title_id
order by ta.au_id desc

#Step 2: Aggregate the total royalties for each title and author
Select au_id, title_id, advance as advance_n, round(sum(sales_royalty),2) as royalty_n from
(SELECT ta.title_id, ta.au_id,
round((t.advance * ta.royaltyper/100),0) as advance,
round((t.price * s.qty*t.royalty/100 * ta.royaltyper/100),0) as sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on t.title_id = s.title_id
order by ta.au_id desc) as sub
GROUP BY au_id, title_id;


#Step 3: Calculate the total profits of each author
Select au_id,  (advance_n + Sum(royalty_n)) as profit from
(Select au_id, title_id, advance as advance_n, round(sum(sales_royalty),2) as royalty_n from
(SELECT ta.title_id, ta.au_id,
round((t.advance * ta.royaltyper/100),0) as advance,
round((t.price * s.qty*t.royalty/100 * ta.royaltyper/100),0) as sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on t.title_id = s.title_id
order by ta.au_id desc) as sub
GROUP BY au_id, title_id) as sub2
GROUP BY au_id
order by profit desc
limit 3;


#Challenge 2 - Alternative Solution
CREATE TEMPORARY TABLE subquery (
SELECT ta.title_id, ta.au_id,
round((t.advance * ta.royaltyper/100),0) as advance,
round((t.price * s.qty*t.royalty/100 * ta.royaltyper/100),0) as sales_royalty from titleauthor as ta
join titles as t
on ta.title_id = t.title_id
join sales as s
on t.title_id = s.title_id
order by ta.au_id desc  
);

CREATE TEMPORARY TABLE subquery_2 (
Select au_id, title_id, advance as advance_n, round(sum(sales_royalty),2) as royalty_n from subquery
GROUP BY au_id, title_id);


Select au_id,  (advance_n + Sum(royalty_n)) as profit from subquery_2
GROUP BY au_id
order by profit desc
limit 3;

#Create permanent table
SELECT  au_id,  (advance_n + Sum(royalty_n)) as profit
INTO permanent_table
FROM subquery_2;