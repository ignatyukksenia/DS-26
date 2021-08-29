/*  Все неактивные пользователи  */
select customer_id, first_name, last_name
from customer
where active = 0

/* Все фильмы, выпущенные в 2006году */
select title, release_year
from film
where release_year = 2006

/* 10 последних платежей за прокат фильмов */
select * 
from payment
order by payment_date desc
limit 10

/* Дополнительная часть */

/* Информация о первичных ключах */

select tc.table_name, kcu.column_name 
from information_schema.table_constraints tc 
join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name 
where tc.constraint_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'

/* Информация о первичных ключах и их типе данных  */

select tc.table_name, kcu.column_name, c.data_type 
from information_schema.table_constraints tc 
join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
join information_schema."columns" c on tc.table_name = c.table_name and kcu.column_name = c.column_name 
where tc.constraint_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'

