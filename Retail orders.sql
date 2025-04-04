create database project1;
use project1;
drop database project1;

create table cleaned_order(
order_id int primary key auto_increment,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2));

select * from cleaned_order;

#find top 10 highest revenue generating products
select product_id, sum(sale_price) as revenue from cleaned_order group by product_id order by revenue desc limit 10;


#find top5 highest selling products in each region
with cte as(
select product_id, region, sum(sale_price) as revenue from cleaned_order group by product_id,region)
select * from
(select *
, rank() over(partition by region order by revenue desc) as rn
from cte) as cte
where rn<=5;


#find month over month growth comparison for 2022 and 2023 sales: eg jan 2022 vs jan 2023
with cte as(
select year(order_date) as order_year, monthname(order_date) as order_month, sum(sale_price) as revenue from cleaned_order 
group by order_year,monthname(order_date)  
)
select order_month,
sum(case when order_year=2022 then revenue else 0 end) as revenue_2022,
sum(case when order_year=2023 then revenue else 0 end) as revenue_2023
from cte
group by order_month
order by field(order_month, 'January', 'February', 'March', 'April', 'May', 'June', 
                            'July', 'August', 'September', 'October', 'November', 'December');
               
               
#for each category which month has highest sales
with cte as(
select category, year(order_date) as order_year,month(order_date) as order_month, sum(sale_price) as revenue 
from cleaned_order group by category,  order_year,order_month
)
select * from
(select *,
row_number() over(partition by category order by revenue desc) as rn
from cte) as cte
where rn=1;


#which sub category had highest growth by profit in 2023
with cte as(
select sub_category, sum(sale_price) as revenue, year(order_date) as order_year from cleaned_order group by sub_category, year(order_date)
),
cte2 as(
select sub_category,
sum(case when order_year=2022 then revenue else 0 end) as revenue2022,
sum(case when order_year=2023 then revenue else 0 end) as revenue2023
from cte 
group by sub_category)
select *,
((revenue2023-revenue2022)/revenue2022)*100 as growth_percent
from cte2
order by growth_percent desc limit 1;



