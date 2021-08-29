create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five')

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight')

select * from table_one

select * from table_two

--left, right, inner, full outer, cross

select t1.name_one, t2.name_two
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select count(customer_id)
from customer

select count(customer_id)
from customer c
left join address a on a.address_id = c.address_id

select count(customer_id)
from customer c
join address a on a.address_id = c.address_id

select t1.name_one, t2.name_two
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select ...
from table_1
right join (
	select ...
	from table_2
	right join (
		select ...
		from table_3
		where ...
	)
	where ...
) on ....

select 
from (
	select 
	from 
)
right join 

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null 

select t1.name_one, t2.name_two
from table_one t1
cross join table_two t2 

select t1.name_one, t2.name_two
from table_one t1, table_two t2

select t1.name_one, t2.name_two
from table_one t1, table_two t2, table_3 t3
where t1.name_one = t2.name_two

delete from table_one;
delete from table_two;

insert into table_one (name_one)
select unnest(array[1,1,2])

insert into table_two (name_two)
select unnest(array[1,1,3])

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two

1а	1б
1А	1Б
2	3

1а-1б, 1А-1б, 1а-1Б, 1А-1Б

cross join -> inner join -> left/right join

-- Почитайте про 5 Нормальную Форму.

1а - 1б
1А - 1Б

склад 1 - город 1

склад 1 - город 1
склад 1 - город 2

склад 1 - продукт 1
склад 1 - продукт 2

город 1 - продукт 1
город 2 - продукт 2

select 1::text as x, 1 as y
union 
select 1::text as a, 1 as b

select 1 as x, 1 as y
union all
select 1 as a, 1 as b

select 1 as x, 1 as y
except 
select 1 as a, 1 as b

select 1 as x, 1 as y
union all
select 2 as a, 3 as b
union all
select 1 as a, 1 as b
union all
select 1 as a, 1 as b
union all
select 1 as a, 1 as b
union all
select 1 as a, 1 as b
except 
select 1 as a, 1 as b

select t1.a, t1.b
from (select 1 as a, 1 as b) t1
inner join (select 1 as a, 1 as b) t2 on t1.a = t2.a and t1.b = t2.b

select coalesce(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null 

select coalesce(null, null, 0)

select concat(t1.name_one, t2.name_two)
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null 

select 
	case
		when t.name_one is not null then t.name_one
		when t.name_two is not null then t.name_two
		else 'Что-то пошло не так'
	end
from (
	select *
	from table_one t1
	full join table_two t2 on t1.name_one = t2.name_two
	where t1.name_one is null or t2.name_two is null 
	union all
	select null, null) t

============= соединения =============

1. Выведите список названий всех фильмов и их языков (таблица language)
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name"
from film f
join "language" l on l.language_id = f.language_id

1.1 Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Выведите информацию о фильмах:
title, category."name"
--using

select f.title, c."name"
from film f
left join film_category fc using(film_id)
left join category c using(category_id)

select f.title, c."name"
from category c
join film_category fc using(category_id)
join film f using(film_id)

2. Выведите список всех актеров, снимавшихся в фильме Lambs Cincinatti (film_id = 508). 
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* Отфильтруйте, используя where и "title like" (для названия) или "film_id =" (для id)

select f.title, a.last_name
from actor a
left join film_actor fa on fa.actor_id = a.actor_id
left join film f on f.film_id = fa.film_id
where f.film_id = 508

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте , используя where и "city like" (для названия города) или "city_id ="  (для id)
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

select store_id, postal_code, country, city, district, address, address2, phone, address_id, city_id
from store s
join address a using(address_id)
join city c using(city_id)
join country c2 using(country_id)
where c.city_id = 576

select store_id, postal_code, country, city, district, address, address2, phone, a.address_id, c.city_id
from store s
left join address a on s.address_id = a.address_id
left join city c on c.city_id = a.city_id and c.city_id = 576
left join country c2 on c2.country_id = c.country_id
where c.city_id is not null

select store_id, postal_code, country, city, district, address, address2, phone, a.address_id, c.city_id
from store s
join address a on s.address_id = a.address_id
right join city c on c.city_id = a.city_id and c.city_id = 576
left join country c2 on c2.country_id = c.country_id
where s.store_id is not null

============= агрегатные функции =============

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "title like" (для названия) или "film_id =" (для id) 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
--ФЗ, Аксиомы Армстронга 

select count(fa.actor_id)
from film f
join film_actor fa on fa.film_id = f.film_id
where f.film_id = 384

select f.title, count(fa.actor_id), f.description, f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by f.film_id -- ХОРОШО

select f.title, count(fa.actor_id), f.description, f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by f.title, f.description, f.release_year -- ПЛОХО

select count(fa.actor_id), f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by f.release_year, f.rating -- ХОРОШО, так как нужно

select 1

FROM
ON
JOIN
WHERE
GROUP by --знает, но не в каждой СУБД это реализовано
WITH CUBE или WITH ROLLUP
HAVING
select --алиасы 
DISTINCT
ORDER by

select f.title as "Название фильма", count(fa.actor_id), f.description, f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by 1, 3, 4 
order by 2


3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select avg(rental_rate/rental_duration),
	max(rental_rate/rental_duration),
	min(rental_rate/rental_duration),
	sum(rental_rate/rental_duration)
from film 

select customer_id, avg(amount)
from payment p
group by customer_id

============= группировки =============

4. Выведите список фильмов, в которых снималось больше 10 актеров

* Используйте таблицу film
* Соедините с film_actor
* Сгруппируйте итоговую таблицу по film_id
* Для каждой группы посчитайте колличество актеров
* Воспользуйтесь фильтрацией групп, для выбора фильмов с колличеством > 10
--having, numeric, alias

select f.title, count(fa.actor_id), f.description, f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
where f.release_year = 2006
group by f.film_id 
having count(fa.actor_id) > 10

select f.title, count(fa.actor_id), f.description, f.release_year
from film f
join film_actor fa on fa.film_id = f.film_id
group by f.film_id 
having count(fa.actor_id) > 10 and f.release_year = 2006


4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select c."name"
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(rental_duration) > 5

select c.customer_id, p.staff_id, sum(amount)
from payment p
join customer c on p.customer_id = c.customer_id
where c.customer_id < 5
group by grouping sets (c.customer_id, p.staff_id)

select c.customer_id, p.staff_id, extract(month from p.payment_date), sum(amount)
from payment p
join customer c on p.customer_id = c.customer_id
where c.customer_id < 5
group by cube (c.customer_id, p.staff_id, extract(month from p.payment_date))
order by 1, 2, 3

select c.customer_id, p.staff_id, extract(month from p.payment_date), sum(amount)
from payment p
join customer c on p.customer_id = c.customer_id
where c.customer_id < 5
group by rollup (c.customer_id, p.staff_id, extract(month from p.payment_date))
order by 1, 2, 3

select * from payment p

============= подзапросы =============

5. Выведите количество фильмов, со стоимостью аренды за день больше, чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

select avg(rental_rate/rental_duration) from film 

select title, rental_rate/rental_duration
from film 
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film)

select title, rental_rate/rental_duration
from film 
where rental_rate/rental_duration = (select max(rental_rate/rental_duration) from film)

select title, rental_rate/rental_duration
from film 
where film_id in (select 1, 2, 3, 4, 5)

select title, rental_rate/rental_duration, (select count(customer_id) from customer)
from film 
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film)

6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
--position and time

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.29 / 0.47

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.47

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and 
	fc.category_id in (select category_id
	from category 
	where "name" like 'C%')
join category c on c.category_id = fc.category_id --175 / 47.11 / 0.45

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 46.96 / 0.43

explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.29 / 0.43

explain analyze
select category_id, "name"
from category 
where "name" like 'C%'
	
6.1. Выведите фильмы, с категорией начинающейся с буквы "C", но используйте данные подзапроса в условии фильтрации
* Используйте таблицу film
* Соедините с таблицей film_category
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Используйте результат работы подзапроса в фильтрации с помощью оператора in

C:\Users\имя_пользователя\AppData\Roaming\DBeaverData\workspace6\General\Scripts

-- разбор 2 доп kcu

Забыл разобрать запрос по второму дополнительному заданию, уверен, что сможете справиться самостоятельно:

select tc.table_name, kcu.column_name, tc.constraint_name, c.data_type
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.constraint_name = tc.constraint_name 
	and tc.table_name = kcu.table_name 
	and tc.constraint_schema = kcu.constraint_schema
left join information_schema.columns c on c.column_name = kcu.column_name 
	and kcu.table_name = c.table_name 
	and kcu.constraint_schema = c.table_schema
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'
