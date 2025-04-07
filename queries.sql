select count(*)
from customers
считаю количество строк.
  
  
select concat( e.first_name, ' ', last_name) as seller, 
count(s.sales_person_id) as operations, 
floor(sum(s.quantity * p.price)) as income
from  sales s
join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by concat( e.first_name, ' ', last_name) 
 order by income desc
limit 10;
 объединяю имя и фамилию продавца, считаю количество строк с его id в таблице sales, при помощи floor округляю до целого в меньшую сторону, 
присоединяю необходимые таблицы, групирую, сортирую и выставляю лимит 10.



with tab1 as(select concat( e.first_name, ' ', last_name) as seller,  
floor(avg(s.quantity * p.price)) as average_income
from  sales s
join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by concat( e.first_name, ' ', last_name) 
 )
 select seller, average_income
 from tab1 
 where average_income < (select floor(avg(s.quantity * p.price))
 from  sales s
 join products p on s.product_id = p.product_id )
 order by average_income ;
  использую сте, чтобы посчитать общее среднее значение для каждого продавца, 
затем  фильтую с помощью функции where и подзапроса с общим средним значением.




select concat(e.first_name, ' ', e.last_name) as seller, 
to_char(s.sale_date, 'day') as day_of_week,
floor(sum(s.quantity * p.price)) as income
from  sales s
join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by  to_char(s.sale_date, 'day'), concat(e.first_name, ' ', e.last_name), extract(isodow from s.sale_date)
 order by extract(isodow from s.sale_date), seller;
для обозначения дней недели использую фукцию to_char.  использую функции extract(isodow  from…)  для обозначения номеров дней недели в формате iso, так же добавляю по ним сортировку и группировку 




select case
 	when age between 16 and 25 then '16-25'
 	when age between 26 and 40 then '26-40'
 	when age > 40 then '40+'
 end as age_category,
 count (customer_id) as age_count
 from customers 
 group by case
 	when age between 16 and 25 then '16-25'
 	when age between 26 and 40 then '26-40'
 	when age > 40 then '40+'
 end 
  order by age_category;
использую функцию case для деления на категории по возрасту




select 
to_char(s.sale_date, 'yyyy-mm') as selling_month,
count(distinct(s.customer_id)) as total_customers ,
floor(sum(s.quantity * p.price)) as income
from  sales s
join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by  selling_month 
 order by selling_month
извлекаю из даты год и месяц, считаю количество уникальных id покупателей, групирую и сортирую по месяцам




with tab1 as (select concat(c.first_name, ' ', c.last_name) as customer,
sale_date,
concat(e.first_name, ' ', e.last_name) as seller,
c.customer_id,
sum(price * quantity ) as income, 
s.sales_id
from  sales s
join employees e on e.employee_id = s.sales_person_id
 join customers c  on s.customer_id  = c.customer_id
 join products p on p.product_id = s.product_id
 group by s.sales_id, concat(c.first_name, ' ', c.last_name), sale_date, concat(e.first_name, ' ', e.last_name), c.customer_id
 ), 
  tab2 as (select customer, sale_date, seller, income, customer_id, 
 row_number() over(partition by customer order by sale_date) as rn
 from tab1 
 where income = 0 )
 
 select customer, sale_date, seller 
 from tab2 
 where rn = 1
 order by customer_id
при помощи сте создаю tab1, где нахожу имена покупателей, дату покупки, имена продавцов, id покупателей, сумму одной покупки,и id покупки.
создаю вторую таблицу tab2, где фильтрую покупки по сумме равной 0, с помощью оконной функции row_number() over(partition by создаю нумерацию
в пределах одного покупателя и сортирую по дате покупки. создаю финальную таблицу, где делаю фильтрацию по 1 номеру из оконной функции, сортирую по id покупателя.
