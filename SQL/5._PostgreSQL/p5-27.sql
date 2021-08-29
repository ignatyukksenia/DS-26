FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
select
over
DISTINCT
ORDER BY

============= оконные функции =============

1. Выведите таблицу с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
from film f
join film_actor fa using(film_id)
join actor a using(actor_id)

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

select c.last_name, f.title, avg(p.amount) over (partition by c.customer_id)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	min(p.amount) over (partition by c.customer_id),
	max(p.amount) over (partition by c.customer_id),
	avg(p.amount) over (),
	sum(p.amount) over (),
	min(p.amount) over (),
	max(p.amount) over ()
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.payment_date,
	lag(p.amount) over (partition by c.customer_id),
	p.amount,
	lead(p.amount) over (partition by c.customer_id)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.payment_date,
	lag(p.amount, 5) over (partition by c.customer_id),
	p.amount,
	lead(p.amount, 5) over (partition by c.customer_id)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.payment_date,
	sum(p.amount) over (partition by c.customer_id order by p.payment_date)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.payment_date, c.store_id,
	sum(p.amount) over (partition by c.customer_id, date_trunc('month', p.payment_date), c.store_id order by p.payment_date)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, p.payment_date,
	row_number() over (partition by c.customer_id order by p.payment_date),
	rank() over (partition by c.customer_id order by date_trunc('month', p.payment_date)),
	dense_rank() over (partition by c.customer_id order by date_trunc('month', p.payment_date))
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id

--Одним запросом ответить на два вопроса: в какой из месяцев взяли в аренду фильмов больше всего? 
--На сколько по отношению к предыдущему месяцу было сдано в аренду больше/меньше фильмов.

with cte as (
select date_trunc('month', r.rental_date) md, count(r.rental_id) cm,
	lag(count(r.rental_id)) over (order by date_trunc('month', r.rental_date)) lc,
	count(r.rental_id) - lag(count(r.rental_id)) over (order by date_trunc('month', r.rental_date)) dc,
	max(count(r.rental_id)) over () m
from rental r
group by date_trunc('month', r.rental_date))
select md, dc, (select md from cte where cm = m), m, cm
from cte


============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Фамилия и Имя сотрудника (staff) и количество прокатов двд (retal), которые он продал
* Создайте CTE:
 - Используйте таблицу staff
 - соедините с rental
 - || - оператор конкатенации
 * напишите запрос к полученной CTE:
 - сгруппируйте по fio
 - count - агрегатная функция подсчета значений
 - выведите значения в виде: fio, количество прокатов(rental_id)

with cte as (
	select s.last_name, r.rental_id, s.staff_id
	from staff s
	join rental r on r.staff_id = s.staff_id)
select last_name, count(rental_id)
from cte
group by staff_id, last_name

2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
--10 и 12 postgre

select version()

explain analyze --143,77
with cte_1 as (
	select category_id, "name"
	from category 
	where name ilike 'c%'
),
cte_2 as (
	select *
	from film_category 
),
cte_3 as (
	select film_id, title
	from film 
)
select c3.title, c1.name
from cte_1 c1
join cte_2 c2 on c1.category_id = c2.category_id
join cte_3 c3 on c2.film_id = c3.film_id

explain analyze --99.85
select c1."name", c3.title
from category c1
join film_category c2 on c1.category_id = c2.category_id
join film c3 on c2.film_id = c3.film_id
where name ilike 'c%'

explain analyze --119.85 для постгре 10 версии, 99,85 для постгре 12+ версии
with cte as (
	select c1."name", c3.title
	from category c1
	join film_category c2 on c1.category_id = c2.category_id
	join film c3 on c2.film_id = c3.film_id
	where name ilike 'c%')
select *
from cte

 ============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие останова
 + Напишите запрос к CTE

with recursive r as (
	--стартовой части
	select 1 as i, 1 as factorial
	union
	--рекурсивная часть
	select i + 1 as i, factorial * (i + 1) as factorial
	from r
	where i < 10
)
select *
from r

create table geo ( 
	id int primary key, 
	parent_id int references geo(id), 
	name varchar(1000) );

insert into geo (id, parent_id, name)
values 
	(1, null, 'Планета Земля'),
	(2, 1, 'Континент Евразия'),
	(3, 1, 'Континент Северная Америка'),
	(4, 2, 'Европа'),
	(5, 4, 'Россия'),
	(6, 4, 'Германия'),
	(7, 5, 'Москва'),
	(8, 5, 'Санкт-Петербург'),
	(9, 6, 'Берлин');

select * from geo
order by id

with recursive r(a, b, c) as (
	select id, parent_id, name, 1 as level
	from geo 
	where id = 5
	union
	select geo.id, geo.parent_id, geo.name, level + 1 as level
	from r 
	join geo on geo.parent_id = r.a
)
select c, level
from r

with recursive r(a, b, c) as (
	select id, parent_id, name, 1 as level
	from geo 
	where id = 5
	union
	select geo.id, geo.parent_id, geo.name, level + 1 as level
	from r 
	join geo on geo.id = r.b
)
select c, level
from r

/*
with recursive r(a, b, c) as (
	select id, parent_id, name, 1 as level
	from knowledge_base_category
	where id = '5a7c165458e975878'
	union
	select geo.id, geo.parent_id, geo.name, level + 1 as level
	from r 
	join knowledge_base_category geo on geo.parent_id = r.a
)
select c, level
from r
*/

explain analyze
with recursive r as (
	select date('01/01/2021') as x
	union
	select x + 1 as x
	from r 
	where x < date('01/02/2021')
)
select *
from r

explain analyze
select date(generate_series(date('01/01/2021'), date('01/02/2021'), interval '1 day'))


Есть исходные данные:
create table test (
	date_event timestamp,
	field varchar(50),
	old_value varchar(50),
	new_value varchar(50)
)

insert into test (date_event, field, old_value, new_value)
values
('2017-08-05', 'val', 'ABC', '800'),
('2017-07-26', 'pin', '', '10-AA'),
('2017-07-21', 'pin', '300-L', ''),
('2017-07-26', 'con', 'CC800', 'null'),
('2017-08-11', 'pin', 'EKH', 'ABC-500'),
('2017-08-16', 'val', '990055', '100')

select * from test order by date(date_event)

В данной таблице хранят информацию по изменению "статуса" для каждого типа поля (field ). 
То есть, есть поле pin, на 21.07.2017 было изменено значение, соответственно новое (new_value ) стало '' (пустая строка) и старое  (old_value), записалось как '300-L'.
Далее 26.07.2017 изменили значение с '' (пустая строка) на '10-AA'. И так по разным полям в разные даты были какие-то изменения значений.

Задача: составить запрос таким образом, что бы в новой результирующей таблице был календарь изменения значений для каждого поля. 
Всего три столбца: дата, поле, текущий статус.
То есть для каждого поля будет отображение каждого дня с отображением текущего статуса. К примеру, для поля pin на 21.07.2017 статус будет  '' (пустая строка), на 22.07.2017 -  '' (пустая строка). и т.д. до 26.07.2017, где статус станет '10-AA'

Решение должно быть универсальным для любого SQL, не только под PostgreSQL ;)

explain analyze --8 000 000
select
	gs::date as change_date,
	fields.field as field_name,
	case 
		when (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event = gs::date) is not null 
			then (
				select new_value 
				from test t 
				where t.field = fields.field and t.date_event = gs::date)
		else (
			select new_value 
			from test t 
			where t.field = fields.field and t.date_event < gs::date 
			order by date_event desc 
			limit 1) 
	end as field_value
from 
	generate_series((select min(date(date_event)) from test), (select max(date(date_event)) from test), interval '1 day') as gs, 
	(select distinct field from test) as fields
order by 
	field_name, change_date
	
explain analyze --93 000	
select
	distinct field, gs, first_value(new_value) over (partition by value_partition)
from
	(select
		t2.*,
		t3.new_value,
		sum(case when t3.new_value is null then 0 else 1 end) over (order by t2.field, t2.gs) as value_partition
	from
		(select
			field,
			generate_series((select min(date_event)::date from test), (select max(date_event)::date from test), interval '1 day')::date as gs
		from test) as t2
	left join test t3 on t2.field = t3.field and t2.gs = t3.date_event::date) t4
order by 
	field, gs

explain analyze --2616
with recursive r(a, b, c) as (
    select temp_t.i, temp_t.field, t.new_value
    from 
	    (select min(date(t.date_event)) as i, f.field
	    from test t, (select distinct field from test) as f
	    group by f.field) as temp_t
    left join test t on temp_t.i = t.date_event and temp_t.field = t.field
    union all
    select a + 1, b, 
    	case 
    		when t.new_value is null then c
    		else t.new_value
		end
    from r  
    left join test t on t.date_event = a + 1 and b = t.field
    where a < (select max(date(date_event)) from test)
)    
SELECT *
FROM r
order by b, a

explain analyze --476
with recursive r as (
 	--стартовая часть рекурсии
 	 	select
 	     	min(t.date_event) as c_date
		   ,max(t.date_event) as max_date
	from test t
	union
	-- рекурсивная часть
	select
	     r.c_date+ INTERVAL '1 day' as c_date
	    ,r.max_date
	from r
	where r.c_date < r.max_date
 ),
t as (select t.field
		, t.new_value
		, t.date_event
		, case when lead(t.date_event) over (partition by t.field order by t.date_event) is null
			   then max(t.date_event) over ()
			   else lead(t.date_event) over (partition by t.field order by t.date_event)- INTERVAL '1 day'
		  end	  
			   as next_date
		, min (t.date_event) over () as min_date
		, max(t.date_event) over () as max_date	  
from (
select t1.date_event
		,t1.field
		,t1.new_value
		,t1.old_value
from test t1
union all
select distinct min (t2.date_event) over () as date_event --первые стартовые даты
		,t2.field
		,null as new_value
		,null as old_value
from test t2) t
)
select r.c_date, t.field , t.new_value
from r
join t on r.c_date between t.date_event and t.next_date
order by t.field,r.c_date

============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1 as 
--explain analyze 2291
	with cte as (
		select r.*, row_number() over (partition by r.customer_id order by r.rental_date desc)
		from rental r
	)
	select c.last_name, c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1 
	
explain analyze --2291
select * from task_1

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_2 as 
	select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa using(film_id)
	join actor a using(actor_id)
	
select * from task_2	

============= материализованные представления =============

5. Создайте матеиализованное представление с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные

create materialized view task_3 as 
--explain analyze 2291
	with cte as (
		select r.*, row_number() over (partition by r.customer_id order by r.rental_date desc)
		from rental r
	)
	select c.last_name, c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1 
with NO data

refresh materialized view task_3

explain analyze --11
select * from task_3

название_представления | дата_обновления | ответственный_за_обновление

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные
 
create materialized view task_4 as 
	select c."name"
	from film f
	join film_category fc on fc.film_id = f.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(f.rental_duration) > 5
with data

select * from task_4

explain analyze --96.47
select * 
from film f
join film_actor fa on fa.film_id = f.film_id
where f.film_id = 508

ALTER TABLE "dvd-rental".film add CONSTRAINT film_pkey primary key (film_id) ;

explain analyze --38.26

create index idx_s_f on film.special_features

select * 
from film f
join film_actor fa on fa.film_id = f.film_id
where f.film_id = 508

Ссылка на сервис по анализу плана запроса https://explain.depesz.com/
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

EXPLAIN [ ( параметр [, ...] ) ] оператор
EXPLAIN [ ANALYZE ] [ VERBOSE ] оператор

Здесь допускается параметр:

    ANALYZE [ boolean ]
    VERBOSE [ boolean ]
    COSTS [ boolean ]
    BUFFERS [ boolean ]
    TIMING [ boolean ]
    FORMAT { TEXT | XML | JSON | YAML }
 
explain
select c."name"
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(f.rental_duration) > 5

explain (format json) 
select c."name"
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(f.rental_duration) > 5

В 5 домашке если количество ресурсов менее 800, значит запрос укладывается в 15 мс
Если запрос скушает 550 ресурсов - примерно 6-8 мс

memcached

explain (format json, analyze) 
	with cte as (
		select r.*, row_number() over (partition by r.customer_id order by r.rental_date desc)
		from rental r
	)
	select c.last_name, c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1 
	
	explain analyze
	with cte as (
		select r.*, row_number() over (partition by r.customer_id order by r.rental_date desc)
		from rental r
	)
	select c.last_name, c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1 
