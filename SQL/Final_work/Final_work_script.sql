-- 1. Города, в которых больше одного аэропорта

--выбор названий городов и подсчет количества аэропортов в городе
select a.city, count(a.airport_code) cnt 
from airports a 
-- получение уникальных значений по пол city
group by a.city 
-- условие фильтрации, выделеяет города, где больше одного аэропорта
having count(a.airport_code) > 1

-- 2. Аэропорты с рейсами, выполняемыми самолетами с максмимальной дальностью перелета

select a.airport_code, a.airport_name 
from (	select  ac.aircraft_code acc   -- подзапрос возвращает код самолета с максимальной дальность перелета
		from aircrafts ac
		order by ac."range" desc
		limit 1) max_range
-- соединение полученного кода самолета с данными о перелетах (содержит данные о аэропортах вылета и прилета)
-- выполнени правый join, чтобы получить информацию о всех выполненных рейсах и  аэропортах выдета/прилета 
right join flights f on max_range.acc = f.aircraft_code 
-- соединение с таблицей Аэропорты, установление соответсвия названиями городов отправления
join airports a on f.departure_airport = a.airport_code 
-- соединение с таблицей Аэропорты, установление соответсвия названиями городов прилета
join airports a2 on a2.airport_code = f.arrival_airport 
-- получение уникальных кодов и названий аэропортов
group by a.airport_code

-- 3. 10 рейсов с максимальным временем задержки вылета

select f.flight_id , (f.actual_departure::timestamp - f.scheduled_departure::timestamp) as delay
from flights f 
-- условие фильтрации с явным приведением типов данных, отсеивает рейсы, по которым нет данных о фактическом времени вылета
where (f.actual_departure::timestamp - f.scheduled_departure::timestamp) is not null
-- сортировка по убыванию, чтобы рейсы с макс. задержкой оказались в верхней части
order by delay desc
-- отображение 10 первых строк результата выполнения скрипта
limit 10

-- 4. Брони, по которым не были получены посадочные талоны

select b.book_ref
from bookings b 
-- соединение таблицы Бронирование с данными о билетах
-- использован правый join, что бы установить соответсвие для всех билетов (в одной брони их может быть несколько)
right join tickets t on b.book_ref = t.book_ref 
--присоединение таблицы с данными о перелетах (содержит информацию о рейсах)
-- использован правый join чтобы установить соответсвие для всех перелетов (в одном билете их может быть несколько)
right join ticket_flights tf on t.ticket_no = tf.ticket_no 
-- присоединение данных из отношения Посадочные талоны. Использован inner join,
-- т.к. сочетание полей ticket_no и flight_id уникально в обеих таблицах будет найдено только одно соответсвие
join boarding_passes bp on tf.ticket_no = bp.ticket_no and tf.flight_id = bp.flight_id
-- в результате последнего join'а для броней, билеты из которых не были зарегистрированы на рейс,
-- значение посадочного талона будет равно NULL
-- условие фильтрации отсеивает все бронирования, у которых номер посадочного талона отличен от NULL
where bp.boarding_no is null
-- получение уникальных номеров бронирования
group by b.book_ref 

-- 5a. Свободные места и их % отношение к общему количеству мест в самолете

select f.flight_id,
		-- расчет количества свободных мест
		ts.total_seats - nd.n_departed as free_seats,
		-- расчет процента свободных мест к общему количеству
		round((ts.total_seats-nd.n_departed)/(ts.total_seats::numeric)*100, 2) as free_seats_percent
from flights f 
-- присоединение результатов подзапроса, возвращающего количество вывезененых пассажиров по каждому рейсу
join (select bp.flight_id, count(bp.seat_no) n_departed
		from boarding_passes bp 
		group by bp.flight_id) nd using(flight_id)
-- присоединение результатов подзапроса, возвращающего общее количество мест в самолете каждой модели 
join (select s.aircraft_code, count(s.seat_no) total_seats
		from seats s
		group by s.aircraft_code) ts on f.aircraft_code = ts.aircraft_code

-- 5b. Суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день

select f.flight_id, f.departure_airport , f.actual_departure, nd.n_departed,
		-- суммарное накопление количесва вывезенных пассадиров из каждого аэропорта на каждый день
		-- формат фактической даты вылета явно приведен к типу данных timestamp для корректного задания параметров окна
		sum(nd.n_departed) over (partition by f.departure_airport, f.actual_departure::date order by f.actual_departure)
from flights f 
-- присоединение результатов подзапроса, возвращающего количество вывезененых пассажиров по каждому рейсу
join (select bp.flight_id, count(bp.seat_no) n_departed
		from boarding_passes bp 
		group by bp.flight_id) nd using(flight_id)
-- присоединение результатов подзапроса, возвращающего общее количество мест в самолете каждой модели 
join (select s.aircraft_code, count(s.seat_no) total_seats
		from seats s
		group by s.aircraft_code) ts on f.aircraft_code = ts.aircraft_code
order by f.departure_airport, f.actual_departure

-- 6. Процентное соотношение перелетов по типам самолетов от общего количества

select acc.aircraft_code,
		-- расчет процента перевозок, приходящихся на каждую модель самолета
		round(acc.ac_count/sum(acc.ac_count) over()*100, 2) as percent_per_aircraft
-- подзапрос возвращает код самолета и общее количество перелетов за период, отраженный в БД
from (select f.aircraft_code, count(f.flight_id) ac_count
		from flights f 
		group by f.aircraft_code) acc
-- получение уникальных кодов самолетов
group by acc.aircraft_code, acc.ac_count

-- 7. Города, в которые можно добраться бизнесс-классом дешевле, чем эконом-классом в рамках перелета

with cte as (
		select ae.flight_id, ae.a_economy, ab.a_business
		-- подзапрос возвращает стоимости билетов эконом-класса для каждого рейса
		from (select tf.flight_id, tf.amount as a_economy
				from ticket_flights tf 
				where tf.fare_conditions = 'Economy'
				group by tf.flight_id, tf.amount) ae
		-- присоединение результатов подзапроса, возвращающего стоимость билета бизнес-класса для каждого рейса
		join (select tf2.flight_id,
				tf2.amount as a_business
				from ticket_flights tf2
				where tf2.fare_conditions = 'Business'
				group by tf2.flight_id, tf2.amount) ab 
				on ae.flight_id = ab.flight_id
		--where ae.a_economy > ab.a_business
		group by ae.flight_id, ae.a_economy, ab.a_business
			)
select a.city, cte.flight_id, cte.a_economy, a_business
from cte 
-- присоединение отношения Перелеты (содержит информацию о аэропортах вылета/прилета)
join flights f on f.flight_id = cte.flight_id
-- присоединение отношения Аэропорты (содердит информацию о городах вылета/прилета)
join airports a on a.airport_code = f.arrival_airport
-- условие филтрации показывает перелеты, в которых стоимость билета бизнес-класса дешевле эконом-класса
where cte.a_economy > cte.a_business

-- 8. Представление "Маршруты пассажирских перевозок"
create view routes_ as 
	select distinct f.flight_no,
			f.departure_airport,
			ap1.airport_name as departure_airport_name,
			ap1.city as departure_city,
			ap1.latitude as latitude_a,
			ap1.longitude as longitude_a,
			f.arrival_airport,
			ap2.airport_name as arrival_airport_name,
			ap2.city as arrival_city,
			ap2.latitude as latitude_b,
			ap2.longitude as longitude_b,
			f.aircraft_code,
			-- расчет длительности полета
			f.scheduled_arrival-f.scheduled_departure as duration,
			-- определение дня недели перелета
			extract(isodow from f.scheduled_departure) as day_of_week
	from flights f 
	-- присоединение отношения Аэропотры, установление соответствия по домену Аэропорт вылета
	join airports ap1 on f.departure_airport = ap1.airport_code 
	-- присоединение отношения Аэропотры, установление соответствия по домену Аэропорт прилета
	join airports ap2 on f.arrival_airport = ap2.airport_code 

-- Запрос: Города, между которыми нет прямых рейсов

select ap1.city, ap2.city 
-- получение всех возможных сочетаний городов вылета и прилета из декатрова произведения отношения Аэропорты самого на себя
from airports ap1, airports ap2
-- условие фильтрации отсеивает сочетания, где город вылета и прилета совпадает
where ap1.city <> ap2.city
-- исключения прямых маршрутов из результатов выполнения подзапроса
except(select r.departure_airport, r.arrival_airport
		from routes_ r)

-- 9. Расстояние между аэрпортами, связанными прямыми рейсами

select r.departure_airport,
		r.departure_airport_name,
		r.departure_city,
		r.arrival_airport,
		r.arrival_airport_name,
		r.arrival_city,
		r.aircraft_code,
		-- расчет расстояния между аэропортами
		round(6371 * acos(sind(r.latitude_a)*sind(r.latitude_b) + cosd(r.latitude_a)*cosd(r.latitude_b)*cosd(r.longitude_a - r.longitude_b))) as distance,
		ac."range" 
from routes_ r 
-- присоединение отношения Самолеты (содержит информацию о макс.дальности перелета)
join aircrafts ac on r.aircraft_code = ac.aircraft_code 
