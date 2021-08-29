-- ��������� ������ ��� ������� ������������ � ����������� �� ����

select *,
	row_number () over (partition by customer_id order by rental_date)
from rental r 
order by customer_id

-- ���������� ������� � ��������� Behind the Scenes �� ������� ������������

-- ������� 1
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

-- ������� 1
with cte as (
	select r.customer_id, r.rental_date ,f.film_id 
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id
	where 'Behind the Scenes' = any(f.special_features)
	) 
select cte.customer_id, count(cte.film_id) GROUP BY cte.customer_id
from cte

-- ������� 2
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

-- ������� 3
select distinct r.customer_id, count(f.film_id) over(partition by customer_id)
from rental r 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id 
where special_features @> array['Behind the Scenes']


-- ����������������� �������������

create materialized view rental_count as
	select distinct r.customer_id, count(f.film_id) over(partition by customer_id)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id 
	join film f on i.film_id = f.film_id 
	where special_features @> array['Behind the Scenes']
with no data

-- ���������� ������������������ �������������

refresh materialized view rental_count



