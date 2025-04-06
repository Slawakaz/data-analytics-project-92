With tab1 as (
Select 
  concat_ws(' ', 
    nullif(first_name, ''), 
    nullif(middle_initial, ''), 
    nullif(last_name, ''), 
    nullif(age::text, '')
  ) as name_ffu
From customers
)
Select count(distinct name_ffu) as customers_count
From tab1;
Первый запрос обьединяет четыре столбца (first_name, middle_initial,last_name, age), игнорируя значения null, 
При этом меняет тип данных на текст у последнего столбца, тем самым создаю уникальную комбинация для каждого клиента, затем 
Во втором запросе считаю количество уникальных строк.
  
  
Select concat( e.first_name, ' ', last_name) as seller, 
Count(s.sales_person_id) as operations, 
Floor(sum(s.quantity * p.price)) as income
From  sales s
Join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by concat( e.first_name, ' ', last_name) 
 order by income desc
Limit 10;
 Объединяю имя и фамилию продавца, считаю количество строк с его ID в таблице sales, при помощи Floor округляю до целого в меньшую сторону, 
присоединяю необходимые таблицы, групирую, сортирую и выставляю лимит 10.



With tab1 as(select concat( e.first_name, ' ', last_name) as seller,  
Floor(avg(s.quantity * p.price)) as average_income
From  sales s
Join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by concat( e.first_name, ' ', last_name) 
 )
 select seller, average_income
 from tab1 
 where average_income < (select floor(avg(s.quantity * p.price))
 from  sales s
 join products p on s.product_id = p.product_id )
 order by average_income ;
  Использую СТЕ, чтобы посчитать общее среднее значение для каждого продавца, 
затем  фильтую с помощью функции where и подзапроса с общим средним значением.




Select concat(e.first_name, ' ', e.last_name) as seller, 
Case  
        when extract(isodow from s.sale_date) = 1 then  'monday'
        when extract(isodow from s.sale_date) = 2 then  'tuesday'
        when extract(isodow from s.sale_date) = 3 then  'wednesday'
        when extract(isodow from s.sale_date) = 4 then  'thursday'
        when extract(isodow from s.sale_date) = 5 then  'friday'
        when extract(isodow from s.sale_date) = 6 then  'saturday'
        when extract(isodow from s.sale_date) = 7 then 'sunday'
    end as day_of_week,
Floor(sum(s.quantity * p.price)) as income
From  sales s
Join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by  extract(isodow from s.sale_date), concat(e.first_name, ' ', e.last_name)
 order by extract(isodow from s.sale_date), seller;
 Для обозначения дней недели использую фукцию Case, использую функции extract(isodow для обозначения номеров дней недели в формате iso, 
когда неделя начинается с понедельника, каждую цифру назвываю соответсвующим днем недели. Фильтрую по цифровому значению дней недели.




Select case
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
Использую функцию case для деления на категории по возрасту




Select 
To_char(s.sale_date, 'yyyy-mm') as selling_month,
Count(distinct(s.customer_id)) as total_customers ,
Floor(sum(s.quantity * p.price)) as income
From  sales s
Join employees e on e.employee_id = s.sales_person_id
 join products p on s.product_id = p.product_id 
 group by  selling_month 
 order by selling_month
Извлекаю из даты год и месяц, считаю количество уникальных id покупателей, групирую и сортирую по месяцам




With tab1 as (select concat(c.first_name, ' ', c.last_name) as customer,
Sale_date,
Concat(e.first_name, ' ', e.last_name) as seller,
C.customer_id,
Sum(price * quantity ) as income, 
S.sales_id
From  sales s
Join employees e on e.employee_id = s.sales_person_id
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
При помощи СТЕ создаю tab1, где нахожу имена покупателей, дату покупки, имена продавцов, id покупателей, сумму одной покупки,и id покупки.
Создаю вторую таблицу tab2, где фильтрую покупки по сумме равной 0, с помощью оконной функции row_number() over(partition by создаю нумерацию
в пределах одного покупателя и сортирую по дате покупки. Создаю финальную таблицу, где делаю фильтрацию по 1 номеру из оконной функции, сортирую по id покупателя.
