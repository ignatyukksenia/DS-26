create database название_базы_данных

create schema lecture_4_фамилия

set search_path to lecture_4

======================== Создание таблиц ========================
1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* псевдоним - ограничений нет

create table author (
	id serial primary key, --author_id 
	author_name varchar(50) not null,
	nick_name varchar(50),
	born_date date not null,
	create_date timestamp default now(),
	deleted int2 default 0
)

primary key = not null + unique + index

select * from author a

1*  Создайте таблицу "Произведения" с полями: id произведения, год, название, id автора
* для id произведения подойдет serial, ограничение primary key
* название - not null
* год > 0 CHECK (год > 0)
* id автора пока оставьте без ограничений

create table books (
	id serial primary key,
	book_name varchar(150) not null,
	book_year int2 not null check(book_year >= 1800 and book_year <= 2100),
	author_id int2 references author(id),
	create_date timestamp default now(),
	deleted int2 default 0
	--book_cost decimal(10,2) decimal = numeric
	-- add constraint books_author_fkey foreign key (author_id) references author(id)
	-- primary key(col_1, col_2, ...)
)

inn varchar(12) not null check(length(inn) = 12)
inn int not null check(length(inn::text) = 12)

select * from books b

======================== Заполнение таблицы ========================

2. Вставьте данные по 3-м любым писателям в таблицу авторов:
Жюль Габриэль Верн, 08.02.1828
Михаил Юрьевич Лермонтов, Гр. Диарбекир, 03.10.1814
Харуки Мураками, 12.01.1949
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into author (author_name, nick_name, born_date)
values ('Жюль Габриэль Верн', null, '08.02.1828'),
	('Михаил Юрьевич Лермонтов', 'Гр. Диарбекир', '03.10.1814'),
	('Харуки Мураками', null, '12.01.1949')
	
select * from author a
	
2. Вставьте данные по 5-м любым произведениям, id автора - заполните NULL:
Двадцать тысяч льё под водой, 1916
Бородино, 1837
Герой нашего времени, 1840
Норвежский лес, 1980
Хроники заводной птицы, 1994

insert into books (book_name, book_year)
select unnest(array['Двадцать тысяч льё под водой', 'Бородино', 'Герой нашего времени', 'Норвежский лес', 'Хроники заводной птицы']),
	unnest(array[1916, 1837, 1840, 1980, 1994])

select * from books b

insert into books (book_name, book_year)
select f.title, f.release_year::int2 from "dvd-rental".film f

delete from books

insert into books (book_name, book_year)
values ('какая-то книга 2', 1982)

insert into books (id, book_name, book_year)
values ( 1, 'какая-то книга 2', 1982)

smallserial 1 .. 32767
serial - 1 .. 2 147 483 647
bigserial 1 .. 9 223 372 036 854 775 807

books_id_seq

alter sequence books_id_seq restart with 5000;

======================== Модификация таблицы ========================

3. Добавьте поле "место рождения" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;
 
select * from author a

-- alter table author add column born_place varchar(50) default '' not null

alter table author add column born_place varchar(50)

alter table author drop column born_place 

alter table author alter column author_name drop not null

alter table author alter column author_name set not null

alter table author add constraint author_name_unique unique (author_name)

alter table author drop constraint author_name_unique 

alter table author alter column author_name type text using author_name::text

select null = null 

select pg_typeof(author_name) from author a
 
 3* В таблице произведений измените колонку id автора - внешний ключ - ссылка на авторов
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table books add constraint books_author_fkey foreign key (author_id) references author(id)

alter table books drop constraint books_author_fkey 

select * from author a

select * from books b

select null = null -- x = y

select (1 > 2)::text;
select (1 = 1)::text;
select (null = null)::text;

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное место рождения
писателю:
Жюль Габриэль Верн - Франция
Михаил Юрьевич Лермонтов - Российская Империя
Харуки Мураками - Япония
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;
  
select * from author a
  
update author
set born_place = 'Франция'
where id = 1

update author
set born_place = 'Российская Империя'
where id = 2

update author
set born_place = 'Япония'
where id = 3

update author
set born_place = 'Япония'

update author
set born_place = 'Япония'
where id = 3 or id = 1

4*. В таблице произведений проставьте id авторов:

Жюль Габриэль Верн: 
    Двадцать тысяч льё под водой
Михаил Юрьевич Лермонтов: 
    Бородино
    Герой нашего времени
Харуки Мураками:
    Норвежский лес
    Хроники заводной птицы

select * from author a

select * from books
    
update books
set author_id = 1
where id = 5000

update books
set author_id = 2
where id in (5001, 5002)

update books
set author_id = (select id from author where author_name = 'Харуки Мураками')
where id in (5003, 5004)


 ======================== Удаление данных ========================
 
5. Удалите произведение " Двадцать тысяч льё под водой"

update books
set deleted = 1 
where id = 5000

select * 
from books

where deleted = 0

delete from books 
where id = 5000

5.1 Удалить автора 

delete from author 
where id = 1

delete from author 
where id = 2

delete from books 

delete from author 

select * from author

drop table author cascade

drop table books cascade

drop schema lecture_4

drop database название_базы

 ======================================================= Сложные типы данных =======================================================
 
 ======================== json ========================
 Создайте таблицу orders
 
CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{ "customer": "John Doe", "items": {"product": "Beer","qty": 6}}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary /"ttt Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
select * from orders

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )
 
|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|


6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select *
from orders o

select pg_typeof(info)
from orders o

select info->'customer'
from orders o

select pg_typeof(info->'customer')
from orders o

select info->>'customer'
from orders o

select pg_typeof(info->>'customer')
from orders o

select count(info->'items')
from orders o

select sum((info->'items'->>'qty')::int)
from orders o

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::int)
from orders o
where info->'items'->>'product' ilike 'toy%'

--Получить все ключи из json
select json_object_keys(info) 
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

--wish_list 1, 14, 55, 60

select array_length(array[1, 14, 55, 60], 1)

select pg_typeof(f.special_features)
from film f

text[] --массив содержит строки
int[] --массив содержит числа

select f.title, array_length(f.special_features, 1)
from film f

select array_length('{{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}}'::text[], 2)

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers','Commentaries'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/12/functions-subquery
https://postgrespro.ru/docs/postgrespro/12/functions-array

-- ПЛОХАЯ ПРАКТИКА --
explain analyze --79
select f.title, f.special_features
from film f
where f.special_features::text ilike '%Trailers%' or f.special_features::text ilike '%Commentaries%'

explain analyze --84
select f.title, f.special_features
from film f
where f.special_features[1] = 'Trailers' or f.special_features[1] = 'Commentaries' or
	f.special_features[2] = 'Trailers' or f.special_features[2] = 'Commentaries' or
	f.special_features[3] = 'Trailers' or f.special_features[3] = 'Commentaries' or
	f.special_features[4] = 'Trailers' or f.special_features[4] = 'Commentaries'

-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --
explain analyze --2143
select title, string_agg(special_features, ', ')
from (select film_id, title, unnest(special_features) as special_features from film) t
where special_features = 'Trailers' or special_features = 'Commentaries'
group by film_id, title

-- ХОРОШАЯ ПРАКТИКА --
explain analyze --69
select f.title, f.special_features
from film f
where array_position(f.special_features, 'Trailers') is not null or
	array_position(f.special_features, 'Commentaries') is not null

array_position - вернет индекс первого вхождения
array_positions - вернет массив с индексами всех вхождений

explain analyze --89
select f.title, f.special_features
from film f
where 'Trailers' = any(f.special_features) or 'Commentaries' = any(f.special_features)

select f.title, f.special_features
from film f
where 'Trailers' = all(f.special_features) or 'Commentaries' = all(f.special_features)

any = some

explain analyze --71.50
select f.title, f.special_features
from film f
where special_features @> array['Trailers'] or f.special_features @> array['Commentaries'] or 
	special_features @> array['Trailers', 'Commentaries']

explain analyze --89
select f.title, f.special_features
from film f
where special_features <@ array['Trailers'] or f.special_features <@ array['Commentaries'] or 
	special_features <@ array['Trailers', 'Commentaries']
	
explain analyze --71.50
select f.title, f.special_features
from film f
where special_features && array['Trailers'] or f.special_features && array['Commentaries'] or 
	special_features && array['Trailers', 'Commentaries']
	
explain analyze --89
select f.title, f.special_features
from film f
where special_features <@ array['Trailers'] or f.special_features <@ array['Commentaries'] or 
	special_features <@ array['Trailers', 'Commentaries']
	
-- НЕ СОДЕРЖИТ
select f.title, f.special_features
from film f
where not ('Trailers' = any(f.special_features)) and not ('Commentaries' = any(f.special_features))

select f.title, f.special_features
from film f
where array_position(f.special_features, 'Trailers') is null and
	array_position(f.special_features, 'Commentaries') is null