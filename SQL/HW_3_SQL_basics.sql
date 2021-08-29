
-- Магазины, имеющие более 300 покупателей
select store_id 
from (select store_id, count(distinct customer_id) as customer_count
	from customer 
	group by store_id) c
where c.customer_count > 300
	
	
-- Города проживания покупателей
select customer_id, first_name, last_name, c2.city 
from customer c 
left join address a on c.address_id = a.address_id 
left join city c2 on c2.city_id = a.city_id 


-- ФИО сотрудников и города магазинов, имеющих больше 300-от покупателей
select c.store_id, s.first_name, s.last_name, a.address 
from (select store_id, count(distinct customer_id) as customer_count
	from customer 
	group by store_id) c
join staff s on c.store_id = s.store_id
join address a on a.address_id = s.address_id 
where c.customer_count > 300


-- Количество актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99
select f.film_id, count(actor_id)
from (select film_id, rental_rate/rental_duration 
	from film f
	where rental_rate/rental_duration = 2.99) f
join film_actor fa on f.film_id = fa.film_id 
group by f.film_id 
