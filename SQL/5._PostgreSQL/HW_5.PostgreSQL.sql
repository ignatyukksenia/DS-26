-- Нумерация аренды для каждого пользователя с сортировкой по дате

select *,
	row_number () over (partition by customer_id order by rental_date)
from rental r 
order by customer_id

-- Количество фильмов с атрибутом Behind the Scenes по каждому пользователю

-- вариант 1
explain analyze 
with cte as (
	select r.customer_id, r.rental_date ,f.film_id 
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id
	where 'Behind the Scenes' = any(f.special_features)
	) 
select distinct cte.customer_id, count(cte.film_id) over(partition by customer_id)
from cte

-- вариант 1
with cte as (
	select r.customer_id, r.rental_date ,f.film_id 
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id
	where 'Behind the Scenes' = any(f.special_features)
	) 
select cte.customer_id, count(cte.film_id) GROUP BY cte.customer_id
from cte

-- вариант 2
explain analyze 
with cte as (
	select r.customer_id, r.rental_date ,f.film_id, f.special_features 
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id
	where array_position(f.special_features, 'Behind the Scenes') is not null
	) 
select distinct cte.customer_id, count(cte.film_id) over(partition by customer_id)
from cte

-- вариант 3
select distinct r.customer_id, count(f.film_id) over(partition by customer_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
where special_features @> array['Behind the Scenes']


-- Материализованное представление

create materialized view rental_count as
	select distinct r.customer_id, count(f.film_id) over(partition by customer_id)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id 
	where special_features @> array['Behind the Scenes']
with no data

-- Обновление материализованного представления

refresh materialized view rental_count



