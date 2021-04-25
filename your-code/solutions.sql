use publications;

-- Challenge 1 - Most Profiting Authors

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication

SELECT ta.title_id as Title_ID, a.au_id as Author_ID, s.qty as Quantity, 
round(t.advance * ta.royaltyper / 100, 1) as Advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as Sales_Royalty
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ;

-- Step 2: Aggregate the total royalties for each title and author

SELECT Author_ID, Title_ID, sum(Sales_Royalty) as Total_Sales_Royalty, Advance FROM (
SELECT ta.title_id as Title_ID, a.au_id as Author_ID, s.qty as Quantity, 
round(t.advance * ta.royaltyper / 100, 1) as Advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as Sales_Royalty
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ) as sub
group by Author_ID, Title_ID;

-- Step 3: Calculate the total profits of each author

SELECT Author_ID, SUM(Total_Sales_Royalty + Advance) as Profit
FROM (
SELECT Author_ID, Title_ID, sum(Sales_Royalty) as Total_Sales_Royalty, Advance FROM (
SELECT ta.title_id as Title_ID, a.au_id as Author_ID, s.qty as Quantity, 
round(t.advance * ta.royaltyper / 100, 1) as Advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100, 1) as Sales_Royalty
FROM titleauthor as ta
JOIN authors as a
on a.au_id = ta.au_id
JOIN titles as t
on ta.title_id = t.title_id
JOIN sales as s
on ta.title_id = s.title_id ) as sub
group by Author_ID, Title_ID) as sub2
group by Author_ID
order by Profit desc
limit 3;