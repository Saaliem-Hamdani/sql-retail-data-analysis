create database db_retail
use db_retail
select*from[dbo].[prod_cat_info]
select * from[dbo].[Customer]
select * from[dbo].[Transactions]






--Data prepration and understanding

--Q1 What is the total number of rows in each of the three tables in the database?
--Start

select 'Total rows in transaction table', count (transaction_id) from[dbo].[Transactions]
union
select 'Total rows in prod_cat_info table' ,count(prod_cat_code) from [dbo].[prod_cat_info]
union
select 'Total rows in customer table', count (customer_id) from[dbo].[Customer]

--End


--Q2 What is the total number of transactions that have a return?
--Start

select count (qty)as 'total no of returns' from[dbo].[Transactions]
where qty < 0

--end


--Q3 Convert the date variables into valid date formats before proceeding ahead? 
--Start

select convert(date,[tran_date], 103) from [dbo].[Transactions]
update [dbo].[Transactions]
set [tran_date]=  convert(date,[tran_date], 103)
alter table[dbo].[Transactions]
alter column [tran_date] date
------
select convert(date,[DOB], 103) from [dbo].[Customer]
update [dbo].[Customer]
set [DOB]=  convert(date,[DOB], 103)
alter table[dbo].[Customer]
alter column [DOB] date

--End


--Q4 What is the time range of the transaction data available for analysis? Show the output in no.of days,months and years simultaneously in different columns.
--Start

select datediff(day, MIN(tran_date), MAX(tran_date)) as toal_no_of_days, 
datediff(month,MIN(tran_date), MAX(tran_date)) as toal_no_of_months,  
datediff(year, MIN(tran_date), MAX(tran_date)) as toal_no_of_years
from [dbo].[Transactions]

--End


--Q5 Which product category does the sub_category "DIY" belong to?
--Start

select [prod_cat] from[dbo].[prod_cat_info]
where [prod_subcat] = 'DIY'

--End


--Data Analysis

--Q1 Which channel is most frequently used for transactions?
--Start

select  top 1 (Store_type),count (Store_type) as 'frequently used channel' from[dbo].[Transactions]
group by [Store_type]
order by count (Store_type) desc

--End


--Q2 What is the count of Male and Female customers in the database?
--Start

select  (gender),count (gender) as 'Total' from[dbo].[Customer]
group by [gender]
having gender in ('m','f')

--End


--Q3 Frpm which city do we have the maximum number of customers and how many?
--Start

select top 1(city_code),count (distinct (customer_Id) ) as 'no of customers'from [dbo].[Customer]
group by (city_code)
order by count(distinct (customer_Id)) desc

--End


--Q4 How many sub-categories are there under the books category?
--Start

select prod_cat ,count (prod_subcat) 'total no of sub cat' from[dbo].[prod_cat_info]
group by prod_cat
having prod_cat= 'books'

--End


--Q5 What is the max quantity of products ever ordered?
--Start

SELECT top 1 prod_cat ,sum (qty) from [dbo].[Transactions] t
inner join [dbo].[prod_cat_info] p
on t.prod_cat_code=p.prod_cat_code
group by prod_cat
order by sum (qty) desc

--End


--Q6 What is the net total revenue generated in categories Electronics and Books?
--Start

select sum(total_amt) as revenue_generated from [dbo].[Transactions] t
inner join [dbo].[prod_cat_info] p
on t.prod_cat_code=p.prod_cat_code
and t.prod_subcat_code =p.prod_sub_cat_code
where prod_cat in ('books','electronics')

--End


--Q7 How many customers have > 10 transactions with us, excluding returns?
--Begin

select count (*) from
(
select cust_id from[dbo].[Transactions]
where Qty > 0
group by (cust_id)
having count(cust_id)>10
) as t

--end


--Q8 What is the combined revenue earned from the "Electronics" and "Clothing" categories, from "Flagship stores" ?
--Begin

 select sum (total_amt)as 'combined_revenue' from [dbo].[Transactions] t
 inner join [dbo].[prod_cat_info] p
 on t.prod_cat_code =p.prod_cat_code
 and t.prod_subcat_code = p.prod_sub_cat_code
 where  prod_cat in ('clothing','electronics') and t.Store_type='flagship store'
 
-- end


--Q9 What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
--Begin
 
select prod_subcat , sum (total_amt) from [dbo].[Transactions] t
inner join [dbo].[prod_cat_info] p
on t.prod_cat_code = p.prod_cat_code
and t.prod_subcat_code = p.prod_sub_cat_code
inner join [dbo].[Customer] c
on t.cust_id=c.customer_Id
where prod_cat ='electronics' and gender = 'm'
group by prod_subcat

--end


--Q10 What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
--Begin

select [prod_cat],p.[prod_cat_code],[prod_subcat],p.[prod_sub_cat_code], total_sales, "sales% ", "returned_%" from
(select top 5 t1.[prod_cat_code],t1.[prod_subcat_code], total_sales, "sales% ", "returned_%"  from
(select [prod_cat_code], [prod_subcat_code], sum (total_amt)as 'total_sales',
concat(round((sum (total_amt)/(select sum (total_amt) from [dbo].[Transactions]))*100,2),'%') as 'sales%'
 from [dbo].[Transactions]
group by [prod_subcat_code],[prod_cat_code]) as t1
inner join 
(select[prod_cat_code], [prod_subcat_code],concat(round((sum (total_amt)/(select sum (total_amt) 
from [dbo].[Transactions]))*100,2),'%') as 'returned_%' from [dbo].[Transactions]
where qty < 0
group by [prod_subcat_code],[prod_cat_code]) as t2
on t1.[prod_cat_code]=t2.[prod_cat_code]
and t1.[prod_subcat_code]=  t2.[prod_subcat_code]
order by total_sales desc ) as t3
inner join [dbo].[prod_cat_info] p
on t3.[prod_cat_code]=p.[prod_cat_code]
and t3.[prod_subcat_code] = p.[prod_sub_cat_code]

--end


--Q11 For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?
--Begin

select sum (t1.total_amt) as revenue from
(select [cust_id],[total_amt], datediff(day,[tran_date],(select max([tran_date]) from  [dbo].[Transactions]))as daydifference from[dbo].[Transactions]
where datediff(day,[tran_date],(select max([tran_date]) from  [dbo].[Transactions]))<31 ) as t1
inner join
(select * from
(select distinct [customer_Id],
case
when month([dob])> month (getdate())
then datediff(year, [DOB],getdate()) -1 
when month ([DOB])=month (getdate()) and day ([DOB])> day (getdate())
then datediff(year, [DOB],getdate()) -1 
else datediff (year, [DOB],getdate ())
END AS AGE 
FROM [dbo].[Customer]) as t
where AGE between 25 and 35) as t2
on t1.cust_id=t2.customer_Id

-- end


--Q12 12.	Which product category has seen the max value of returns in the last 3 months of transactions?
--Begin

select top 1 [prod_cat] ,t1.prod_cat_code [prod_cat_code], qt  from 
(select prod_cat_code,sum(qty) as qt from 
(select prod_cat_code,qty , datediff(MONTH,[tran_date],(select max([tran_date]) from  [dbo].[Transactions]))as mo 
from[dbo].[Transactions]) as t
 where mo <=3 and qty<0 
 group by prod_cat_code ) as t1
inner join 
(select [prod_cat],[prod_cat_code] from [dbo].[prod_cat_info]) p
on p.prod_cat_code= t1.prod_cat_code
order by qt asc

-- end


--Q13 Which store-type sells the maximum products; by value of sales amount and by quantity sold?
--Begin

select top 1 store_type , round(sum ([total_amt]),2) as sales , sum (qty) as qty_sold from[dbo].[Transactions]
group by Store_type
order by sum ([total_amt]) desc , sum (qty) desc

--end


--Q14 What are the categories for which average revenue is above the overall average.
--Begin

select prod_cat , round(avg(total_amt),2) as average_revenue from [dbo].[Transactions] t 
inner join [dbo].[prod_cat_info] p 
on t.prod_cat_code=p.prod_cat_code
group by prod_cat
having avg (total_amt)>(select avg(total_amt)from [dbo].[Transactions])

--end


--Q15 Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.
--Begin

select prod_cat,[prod_subcat],revenue , average from
(select t1.prod_cat_code,prod_subcat_code ,sum (total_amt) as revenue,ROUND( AVG(total_amt),2) as average from
(select top 5 prod_cat_code,sum (qty) as tot from [dbo].[Transactions]
group by prod_cat_code
having sum (qty) > (select min (tot) from 
(select prod_cat_code,sum (qty) as tot from [dbo].[Transactions]
group by prod_cat_code) as tt)) as t1
inner join[dbo].[Transactions] t
on t.[prod_cat_code]= t1. [prod_cat_code]
group by t1.prod_cat_code,prod_subcat_code) as t2
inner join [dbo].[prod_cat_info] p
on t2.prod_cat_code = p.[prod_cat_code]
and t2.prod_subcat_code = p.[prod_sub_cat_code]
order by [prod_cat]

--end