-- 1. ������, � ������� ������ ������ ���������

--����� �������� ������� � ������� ���������� ���������� � ������
select a.city, count(a.airport_code) cnt 
from airports a 
-- ��������� ���������� �������� �� ��� city
group by a.city 
-- ������� ����������, ��������� ������, ��� ������ ������ ���������
having count(a.airport_code) > 1

-- 2. ��������� � �������, ������������ ���������� � ������������� ���������� ��������

select a.airport_code, a.airport_name 
from (	select  ac.aircraft_code acc   -- ��������� ���������� ��� �������� � ������������ ��������� ��������
		from aircrafts ac
		order by ac."range" desc
		limit 1) max_range
-- ���������� ����������� ���� �������� � ������� � ��������� (�������� ������ � ���������� ������ � �������)
-- ��������� ������ join, ����� �������� ���������� � ���� ����������� ������ �  ���������� ������/������� 
right join flights f on max_range.acc = f.aircraft_code 
-- ���������� � �������� ���������, ������������ ����������� ���������� ������� �����������
join airports a on f.departure_airport = a.airport_code 
-- ���������� � �������� ���������, ������������ ����������� ���������� ������� �������
join airports a2 on a2.airport_code = f.arrival_airport 
-- ��������� ���������� ����� � �������� ����������
group by a.airport_code

-- 3. 10 ������ � ������������ �������� �������� ������

select f.flight_id , (f.actual_departure::timestamp - f.scheduled_departure::timestamp) as delay
from flights f 
-- ������� ���������� � ����� ����������� ����� ������, ��������� �����, �� ������� ��� ������ � ����������� ������� ������
where (f.actual_departure::timestamp - f.scheduled_departure::timestamp) is not null
-- ���������� �� ��������, ����� ����� � ����. ��������� ��������� � ������� �����
order by delay desc
-- ����������� 10 ������ ����� ���������� ���������� �������
limit 10

-- 4. �����, �� ������� �� ���� �������� ���������� ������

select b.book_ref
from bookings b 
-- ���������� ������� ������������ � ������� � �������
-- ����������� ������ join, ��� �� ���������� ����������� ��� ���� ������� (� ����� ����� �� ����� ���� ���������)
right join tickets t on b.book_ref = t.book_ref 
--������������� ������� � ������� � ��������� (�������� ���������� � ������)
-- ����������� ������ join ����� ���������� ����������� ��� ���� ��������� (� ����� ������ �� ����� ���� ���������)
right join ticket_flights tf on t.ticket_no = tf.ticket_no 
-- ������������� ������ �� ��������� ���������� ������. ����������� inner join,
-- �.�. ��������� ����� ticket_no � flight_id ��������� � ����� �������� ����� ������� ������ ���� �����������
join boarding_passes bp on tf.ticket_no = bp.ticket_no and tf.flight_id = bp.flight_id
-- � ���������� ���������� join'� ��� ������, ������ �� ������� �� ���� ���������������� �� ����,
-- �������� ����������� ������ ����� ����� NULL
-- ������� ���������� ��������� ��� ������������, � ������� ����� ����������� ������ ������� �� NULL
where bp.boarding_no is null
-- ��������� ���������� ������� ������������
group by b.book_ref 

-- 5a. ��������� ����� � �� % ��������� � ������ ���������� ���� � ��������

select f.flight_id,
		-- ������ ���������� ��������� ����
		ts.total_seats - nd.n_departed as free_seats,
		-- ������ �������� ��������� ���� � ������ ����������
		round((ts.total_seats-nd.n_departed)/(ts.total_seats::numeric)*100, 2) as free_seats_percent
from flights f 
-- ������������� ����������� ����������, ������������� ���������� ����������� ���������� �� ������� �����
join (select bp.flight_id, count(bp.seat_no) n_departed
		from boarding_passes bp 
		group by bp.flight_id) nd using(flight_id)
-- ������������� ����������� ����������, ������������� ����� ���������� ���� � �������� ������ ������ 
join (select s.aircraft_code, count(s.seat_no) total_seats
		from seats s
		group by s.aircraft_code) ts on f.aircraft_code = ts.aircraft_code

-- 5b. ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����

select f.flight_id, f.departure_airport , f.actual_departure, nd.n_departed,
		-- ��������� ���������� ��������� ���������� ���������� �� ������� ��������� �� ������ ����
		-- ������ ����������� ���� ������ ���� �������� � ���� ������ timestamp ��� ����������� ������� ���������� ����
		sum(nd.n_departed) over (partition by f.departure_airport, f.actual_departure::date order by f.actual_departure)
from flights f 
-- ������������� ����������� ����������, ������������� ���������� ����������� ���������� �� ������� �����
join (select bp.flight_id, count(bp.seat_no) n_departed
		from boarding_passes bp 
		group by bp.flight_id) nd using(flight_id)
-- ������������� ����������� ����������, ������������� ����� ���������� ���� � �������� ������ ������ 
join (select s.aircraft_code, count(s.seat_no) total_seats
		from seats s
		group by s.aircraft_code) ts on f.aircraft_code = ts.aircraft_code
order by f.departure_airport, f.actual_departure

-- 6. ���������� ����������� ��������� �� ����� ��������� �� ������ ����������

select acc.aircraft_code,
		-- ������ �������� ���������, ������������ �� ������ ������ ��������
		round(acc.ac_count/sum(acc.ac_count) over()*100, 2) as percent_per_aircraft
-- ��������� ���������� ��� �������� � ����� ���������� ��������� �� ������, ���������� � ��
from (select f.aircraft_code, count(f.flight_id) ac_count
		from flights f 
		group by f.aircraft_code) acc
-- ��������� ���������� ����� ���������
group by acc.aircraft_code, acc.ac_count

-- 7. ������, � ������� ����� ��������� �������-������� �������, ��� ������-������� � ������ ��������

with cte as (
		select ae.flight_id, ae.a_economy, ab.a_business
		-- ��������� ���������� ��������� ������� ������-������ ��� ������� �����
		from (select tf.flight_id, tf.amount as a_economy
				from ticket_flights tf 
				where tf.fare_conditions = 'Economy'
				group by tf.flight_id, tf.amount) ae
		-- ������������� ����������� ����������, ������������� ��������� ������ ������-������ ��� ������� �����
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
-- ������������� ��������� �������� (�������� ���������� � ���������� ������/�������)
join flights f on f.flight_id = cte.flight_id
-- ������������� ��������� ��������� (�������� ���������� � ������� ������/�������)
join airports a on a.airport_code = f.arrival_airport
-- ������� ��������� ���������� ��������, � ������� ��������� ������ ������-������ ������� ������-������
where cte.a_economy > cte.a_business

-- 8. ������������� "�������� ������������ ���������"
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
			-- ������ ������������ ������
			f.scheduled_arrival-f.scheduled_departure as duration,
			-- ����������� ��� ������ ��������
			extract(isodow from f.scheduled_departure) as day_of_week
	from flights f 
	-- ������������� ��������� ���������, ������������ ������������ �� ������ �������� ������
	join airports ap1 on f.departure_airport = ap1.airport_code 
	-- ������������� ��������� ���������, ������������ ������������ �� ������ �������� �������
	join airports ap2 on f.arrival_airport = ap2.airport_code 

-- ������: ������, ����� �������� ��� ������ ������

select ap1.city, ap2.city 
-- ��������� ���� ��������� ��������� ������� ������ � ������� �� ��������� ������������ ��������� ��������� ������ �� ����
from airports ap1, airports ap2
-- ������� ���������� ��������� ���������, ��� ����� ������ � ������� ���������
where ap1.city <> ap2.city
-- ���������� ������ ��������� �� ����������� ���������� ����������
except(select r.departure_airport, r.arrival_airport
		from routes_ r)

-- 9. ���������� ����� ����������, ���������� ������� �������

select r.departure_airport,
		r.departure_airport_name,
		r.departure_city,
		r.arrival_airport,
		r.arrival_airport_name,
		r.arrival_city,
		r.aircraft_code,
		-- ������ ���������� ����� �����������
		round(6371 * acos(sind(r.latitude_a)*sind(r.latitude_b) + cosd(r.latitude_a)*cosd(r.latitude_b)*cosd(r.longitude_a - r.longitude_b))) as distance,
		ac."range" 
from routes_ r 
-- ������������� ��������� �������� (�������� ���������� � ����.��������� ��������)
join aircrafts ac on r.aircraft_code = ac.aircraft_code 
