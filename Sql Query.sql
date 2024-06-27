-- No 1

--  Please produce a table with the following columns: customer_id, customer_first_name, customer_email, and transaction_date which has the total line_item_amount the same with the total line_item_amount of user with customer_email ' Charissa@Integer.us' and transaction_date at April 20th, 2019. Please sort it with the latest transaction_date on top

with get_total as (
	select
		distinct
		t.customer_id
		, c.customer_email
		, t.transaction_date
		, sum(t.line_item_amount) as total_line_item_amount
	from `201904_sales_reciepts` t
	left join customer  c on c.customer_id = t.customer_id
	group by 1,2,3
)

select 
	distinct
	c.customer_id
	, c.`customer_first-name`
	, c.customer_email
	, g.transaction_date
from customer c 
left join `201904_sales_reciepts` t on c.customer_id = t.customer_id
left join get_total g on c.customer_id = g.customer_id
where g.total_line_item_amount = (select total_line_item_amount from get_total where customer_email = "Charissa@Integer.us" and transaction_date = date("2019-04-20"))
order by 4 desc


-- No 2
-- Please produce a table with the following columns: product_type, total quantity and status_sold, for transaction_date from April 6th, 2019 to April 14th, 2019. Please sort it from the largest to the smallest.
-- For status_sold column please apply the following rules:
-- 
-- a.      If total quantity more than or equal to 2000 then 'High Sold'
-- 
-- b.     If total quantity more than or equal to 1000 but less than 2000 then 'Medium Sold'
-- 
-- c.      If total quantity less than 1000 then 'Low Sold'


select 
	p.product_type
	, sum(quantity) as total_quantity
	, case
		when sum(quantity) >= 2000
		then "High sold"
		
		when sum(quantity) >= 1000 and sum(quantity) < 2000
		then "Medium Sold"
		
		when sum(quantity) < 1000
		then "Low Sold"
	end as status_sold
from `201904_sales_reciepts` t 
left join product p on t.product_id = p.product_id
where t.transaction_date between date("2019-04-06") and date("2019-04-14") 
group by 1
order by 2 desc


-- No 3
--  Produce a table with the following columns: product_type and total quantity sold. Please show all product_type for transaction_date at April 2nd, 2019, if total total quantity sold is empty (no transaction) then fill it with 0. Please sort it based on the largest to smallest total quantity sold

with all_prd_type as (
	select 
		distinct 
		p.product_type
	from product p
)

, all_qty as (
	select 
		p.product_type
		, sum(quantity) as total_quantity_sold
	from product p 
	left join `201904_sales_reciepts` t on t.product_id = p.product_id
	where t.transaction_date = date("2019-04-02")
	group by 1
)

select 
	apt.product_type
	, ifnull(q.total_quantity_sold, 0) as total_quantity_sold
from all_prd_type apt 
left join all_qty q on apt.product_type = q.product_type
order by 2 desc


-- no 4
-- Produce a table with the following columns: customer_id, customer_first_name, and customer_email which has the largest total quantity for each transaction date from April 12th, 2019 to April 20th, 2019. Please sort it with the latest date on top

-- untuk data customer, data "customer_id = 0", sepertinya salah karena email dan namanya null, jadi saya exclude
-- kemudian sepertinya query ini juga mau menampilkan transaction_date jadi saya tampilkan jg


with total_qty as (
	select 
		customer_id
		, transaction_date
		, sum(quantity) as total_quantity
	from `201904_sales_reciepts` t
	where t.transaction_date between date("2019-04-12") and date("2019-04-20")
	and customer_id != "0"
	group by 1,2
)

, get_max as (
	select 
		distinct
		transaction_date
		, max(total_quantity) as max_total_quantity
	from total_qty 
	group by 1
	order by transaction_date desc
)

select
	tq.transaction_date
	, tq.customer_id
	, c.`customer_first-name`
	, c.customer_email
from total_qty tq
left join get_max gm on tq.transaction_date = gm.transaction_date
left join customer c on c.customer_id = tq.customer_id
where tq.total_quantity = gm.max_total_quantity
order by 1 desc


-- no 5
-- Produce a table with the following columns: product_id, product. Show only 10 product with the largest total quantity for transaction_date from April 11th, 2019 to April 13th, 2019. Please sort it from the largest to the lowest total quantity

select 
	t.product_id
	, p.product
from `201904_sales_reciepts` t
left join product p on t.product_id = p.product_id
where t.transaction_date between date("2019-04-11") and date("2019-04-13")
group by 1,2
order by sum(quantity) desc
limit 10



