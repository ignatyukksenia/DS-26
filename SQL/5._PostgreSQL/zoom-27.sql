https://postgrespro.ru/docs/postgresql/13/ddl-inherit

https://postgrespro.ru/docs/postgresql/13/ddl-partitioning

create table products(
	product_id serial primary key,
	product_name varchar(50) not null unique,
	product_amount decimal(10, 2) not null,
	product_color varchar(30) not null,
	product_count integer not null
)

insert into products_temp (product_name, product_amount, product_color, product_count)
values 
	('фиалка', 500, 'фиалковый', 100),
	('роза', 1000, 'розовый', 250),
	('сирень', 320, 'сиреневый', 37),
	('гладиолус', 705, 'гладиолусовый', 80),
	('астра', 80, 'астровый', 90),
	('пион', 50, 'пионовый', 588),
	('тюльпан', 70, 'тюльпановый', 255)
	
	select * from products
	
create index on products(product_name)

-- вертикальное шардирование
table_1
a | b | c | d |

table_2
a_1 | e | f | n	

-- горизонтальное шардирование
table_1 -- a-g
a | b | c | d | n

table_2 -- h-m
a | b | c | d | n

table_3 -- m-z
a | b | c | d | n
	
alter table table_1 add check (a[1] in ['a-g']);
alter table table_2 add check (a[1] in ['h-m']);
alter table table_3 add check (a[1] in ['m-z']);
	
create or replace function table_insert_foo(i_product_id int, product_name varchar, 
	product_amount decimal, product_color varchar, product_count int) returns integer as $$
	if new.a[1] in ['a-g'] then insert into table_1
	if new.a[1] in ['h-m'] then insert into table_2
	insert into flowers.products (product_id, product_name, product_amount, product_color, product_count) values ($1,$2,$3,$4,$5);
    select 1;
$$ language 'sql';	
alter function flowers.insert_products(int, varchar, decimal, varchar, int) owner to postgres;

create trigger table_insert
before insert on table_1
for each row execute function table_insert_foo();
	
create table products_temp (like products including all);

alter table products_temp inherit products

create function p (x int, y int, out z numeric) as $$
	begin
		select power(x, y) into z;
	end;
$$ language plpgsql

select p(2, 3)

create function f (date_start date, date_end date) returns numeric as $$
	declare z numeric;
	begin
		if date_start is null or date_end is null
			then raise exception 'ќтсутствует дата начала или окончани€';
		elseif date_end < date_start
			then raise exception 'ƒата окончани€ не может быть меньше даты начала';
		else
			select sum(amount)
			from payment 
			where date(payment_date) between date_start and date_end
			into z;
		end if;
	return z;
	end;
$$ language plpgsql

select p(2, 3)

select f('2007-02-16', '2007-02-19')

select * from payment p

--“аблица дл€ аудита
идентификатор | действие | дата_действи€ | ѕользователь | данные | “аблица с которой совершили действие.

create function process_table_audit() returns trigger as $$
    begin 
   		if (TG_OP = 'DELETE') then 
       		insert into emp_audit select 'D', now(), user, old.*, TG_TABLE_NAME;
       	elsif (TG_OP = 'UPDATE') then 
           	insert into emp_audit select 'U', now(), user, new.*, TG_TABLE_NAME;
       	elsif (TG_OP = 'INSERT') then 
           	insert into emp_audit select 'I', now(), user, new.*, TG_TABLE_NAME;
       	end if;
       	return null; -- возвращаемое значение дл€ триггера AFTER игнорируетс€
    end;
$$ language plpgsql;

create trigger table_audit
after insert or update or delete on some_table
for each row execute function process_table_audit();

-- дл€ 10 версии и ниже execute procedure
-- дл€ 11 версии и выше execute procedure или execute function

