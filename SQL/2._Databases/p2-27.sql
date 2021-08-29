select tc.table_name, tc.constraint_name
from information_schema.table_constraints tc
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select film_id, title, description, release_year
from film

select film_id as Filmfilm_id, title as Filmtitle, description Filmdescription, release_year Filmrelease_year
from film

select film_id as "Filmfilm_id", title as "Filmtitle", 
	description "Описание фильма", release_year "Filmrelease_year"
from film

filmReleaseYear -- плохо в названии таблиц и столбцов
film_release_year -- хорошо в названии таблиц и столбцов

select "select"
from language 

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration

select title, rental_duration/rental_rate,
	rental_duration * rental_rate,
	rental_duration + rental_rate,
	rental_duration - rental_rate
from film 

select title, rental_rate/rental_duration as cost_per_day, rental_rate
from film 

select title, round(rental_rate/rental_duration, 2) as cost_per_day
from film 

select round(1/2., 2), pg_typeof(2.)

select round(1/(2::numeric), 2), pg_typeof(2.)

-- 
/* */

int2 = smallint 0-65535 / -32767 - +327678
int = int4 = integer
int8 = bigint

float real / double precision 

numeric = decimal 
decimal(15,2)
9 999 999 999 999,99

numeric -> 12,5 + 12,5 = 25.
float -> 12,49999999999 + 12,50000000001 = 25.

SELECT x,
  round(x::numeric) AS num_round,
  round(x::double precision) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

2* В полученной таблице задайте вычисленному столбцу псевдоним cost_per_day

- as - для задания синонимов 



3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)

- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select title, round(rental_rate/rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

--asc 

select title, round(rental_rate/rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate/rental_duration, 2) desc

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, amount
from payment 
where amount > 0
order by amount

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды

- используйте limit

select title, round(rental_rate/rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
limit 10

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции

- воспользуйтесь Limit и offset

select title, round(rental_rate/rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc, title
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000

- воспользуйтесь Limit и Offset

select payment_id, amount
from payment 
order by amount
offset (select count(payment_id) from payment) - 5
limit 15

select *
from (
	select payment_id, amount
	from payment 
	order by amount desc
	offset 5
	limit 15) t
order by t.amount

select count(film_id)
from film
	
4. Вывести все уникальные годы выпуска фильмов

- воспользуйтесь distinct

select distinct film_id
from film

select distinct release_year
from film

4* Вывести уникальные имена покупателей

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select count(first_name)
from customer 

select count(distinct first_name)
from customer 

select distinct first_name
from customer 

==========

логический порядок

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
SELECT <-- объявляем алиасы (псевдонимы)
DISTINCT
ORDER BY

select title as "Название фильма"
from film f
where "Название фильма" = 'чему-то'

select title as "Название фильма"
from film f
order by "Название фильма" desc

название_схемы.название_таблицы --from
название_таблицы.название_столбца --select

select * 
from world.country

select * 
from "dvd-rental".country

select f.title, a.first_name
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id

select film.title, actor.first_name, film.film_id
from film
join film_actor on film_actor.film_id = film.film_id
join actor on actor.actor_id = film_actor.actor_id

select f.title, a.first_name
from film f
join (select fa.film_id as "Идентфиикатор фильма", fa.actor_id from film_actor fa) t 
	on t."Идентфиикатор фильма" = f.film_id
join actor a on a.actor_id = t.actor_id

select f.title
from film f
where (select count(fa.film_id) from film_actor fa where f.film_id = fa.film_id) > 0

select distinct a.last_name
from actor a
join film_actor fa on fa.actor_id = a.actor_id

==========

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации 
- where - конструкция фильтрации
- "=" - оператор сравнения

select title || ' - ' || release_year
from film f

select concat(title, ' - ', release_year, ' - ', description)
from film f

select concat_ws(' - ', title, release_year, description)
from film f

select 'Hello' || null 

select concat('Hello', null )

select concat(title, ' - ', release_year, ' - ', description)
from film f
where rating = 'PG-13'

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'

- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск

select pg_typeof(rating)
from film f

select concat(title, ' - ', release_year), rating
from film f
where cast(rating as text) like 'PG%'

select concat(title, ' - ', release_year), rating
from film f
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating
from film f
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film f
where rating::text like 'PG___'

select concat(title, ' - ', release_year), rating
from film f
where rating::text like ''''

select t.s
from (select '__%__' as s) t
where t.s like '%%__'

select ''''

select concat(title, ' - ', release_year), rating
from film f
where rating::text ilike 'pg%'

select concat(title, ' - ', release_year), rating
from film f
where upper(rating::text) like 'PG%'

select concat(title, ' - ', release_year), rating
from film f
where lower(rating::text) like 'pg%'

select concat(title, ' - ', release_year), rating
from film f
where lower(rating::text) like 'pg%' and length(rating::text) = 5

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания), в виде: "имя фамилия" - одной строкой.

- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск

select concat(first_name, ' ', last_name)
from customer c
where first_name not ilike '%jam%'

select strpos('Hello world!', 'world')

select character_length('Hello world!')

select overlay('Hello world!' placing 'Max' from 7 for 5)

select overlay('Hello world!' placing 'Max' from 
	(select strpos('Hello world!', 'world')) for 
	(select character_length('world')))
	
select regexp_match() -- самостоятельное изучение

varchar
text

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)

date
timestamp 
timestamptz 

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date >= '27-05-2005 00:00:00' and rental_date <= '28-05-2005 00:00:00'
order by rental_date desc

'2005-05-27'
'27-05-2005'
'27/05/2005'
'27.05.2005'

select customer_id, rental_date
from rental 
where rental_date >= '27-05-2005 00:00:00' and rental_date <= '28-05-2005 23:59:59'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day'
order by rental_date desc

select '28/02/2020'::date + interval '1 day'

select customer_id, rental_date
from rental 
where rental_date::date between '27-05-2005' and '28-05-2005'
order by rental_date desc

select trunc(10,8)

6* Вывести платежи поступившие после 30-04-2007

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select payment_id, payment_date
from payment p
where payment_date > '30-04-2007'
order by payment_date

select payment_id, payment_date
from payment p
where payment_date > '30-04-2007'::date + interval '1 day'
order by payment_date

select payment_id, payment_date
from payment p
where payment_date::date > '30-04-2007'
order by payment_date

select extract(year from '28/02/2020'::date) || ' - ' || extract(month from '28/02/2020'::date)

select extract(month from '28/02/2020'::date)

select extract(week from '28/02/2020'::date)

select extract(day from '28/02/2020'::date)

select date_part('year', '28/02/2020'::date), date_part('month', '28/02/2020'::date)

select date_trunc('year', '28/02/2020'::date)

select date_trunc('month', '28/02/2020'::date)

select date_trunc('day', '28/02/2020'::date)

select now()

select payment_id, payment_date
from payment p
where extract(hour from payment_date) >= 18
order by payment_date

select pg_typeof('28/02/2020'::date::timestamp::timestamptz)

select '28/02/2020'::date::timestamp::timestamptz

select now() - '28/02/2020'

select extract(epoch from '28/02/2020'::timestamp)

select now() - '28/02/2020'

select payment_id, payment_date
from payment p
where extract(day from payment_date)::int % 2 = 0
order by payment_date

select '2022/05/15' - now () -- работает, а 

select now () + interval '100 days' + interval ' 4 month'

--дни:
select date_part('day', now() - r.rental_date)
from rental r

--Месяцы:
select date_part('year', age(now(), r.rental_date)) * 12 + date_part('month', age(now(), r.rental_date)) 
from rental r

--Года:
select date_part('year', age(now(), r.rental_date))
from rental r

select pg_typeof(release_year)
from film

film.release_year -- тип данных integer