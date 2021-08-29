create schema HomeWork4

-- Создание таблиц-справочников

create table languages (
language_id serial primary key,
language_name varchar(15) unique not null);

create table nationality (
nationality_id serial primary key,
nationality_name varchar(15) unique not null);

create table country (
country_id serial primary key,
country_name varchar(60) unique not null);

-- Создание внешних ключей краткой записью

create table language_nationality (
language_id integer,
nationality_id integer,
primary key(language_id, nationality_id),
foreign key(language_id) references languages(language_id),
foreign key(nationality_id) references nationality(nationality_id));

-- Присвоение внешних ключей существующей таблице

create table country_nationality (
country_id integer,
nationality_id integer,
primary key(country_id, nationality_id));

alter table country_nationality
add constraint country_fkey
foreign key(country_id) references country(country_id)

alter table country_nationality
add constraint nationality_fkey
foreign key(nationality_id) references nationality(nationality_id)

-- Наполнение таблиц данными

insert into languages (language_name)
select
unnest (array['русский', 'английский', 'латынь', 'немецкий', 'литовский'])

insert into nationality (nationality_name)
select
unnest (array['славяне', 'кельты', 'германцы', 'балты', 'тюрки'])

insert into country (country_name)
select
unnest (array['Россия', 'Германия', 'Великобритания', 'Франция', 'Литва'])

insert into language_nationality (language_id, nationality_id)
values (1, 1), (1, 5), (2, 2), (2, 3), (5, 4)

insert into country_nationality (country_id, nationality_id)
values (1, 1), (1, 5), (2, 3), (3, 2), (3, 3)

-- Масштабирование базы данных

-- Добавление столбцов и значений в таблицу-справочник languages
alter table languages 
add column dead_language int2,
add column last_update date default now() not null

update languages
set dead_language = 0,
	last_update = now()
where language_id  in (1, 2, 4, 5)

update languages
set dead_language = 1,
	last_update = now()
where language_id  = 3


-- Добавление столбцов и значений в таблицу-справочник nationality

alter table nationality
add column group_members text[],
add column last_update date default now() not null

update nationality
set group_members = array['русские', 'украинцы', 'белорусы', 'поляки',
						'чехи', 'словаки', 'лужичане', 'кашубы', 'селезцы',
						'болгары', 'босняки', 'македонцы', 'сербы', 'хорваты', 'словенцы', 'черногорцы'],
	last_update = now()
where nationality_id = 1

update nationality
set group_members = array['ирландцы', 'шотландцы', 'валлийцы', 'бретонцы', 'корнцы', 'мэнцы'],
	last_update = now()
where nationality_id = 2

update nationality
set group_members = array['немцы', 'австрийцы', 'германошвейцарцы', 'люксембуржцы', 'эльзасцы',
						'лотарингцы', 'тирольцы', 'бельгийские немцы', 'шлезвиги', 'англичане',
						'голландцы', 'фламандцы', 'норвежцы', 'шведы', 'финские шведы', 'датчане',
						'фарерцы', 'исландцы', 'фризы'],
	last_update = now()
where nationality_id = 3

update nationality
set group_members = array['литовцы', 'латыши'],
	last_update = now()
where nationality_id = 4

update nationality
set group_members = array['турки', 'узбеки', 'азербайджанцы', 'казахи', 'уйгуры', 'туймены', 'татары',
						'киргизы', 'башкиры', 'кашкайцы', 'чуваши', 'хорасанские тюрки', 'каракалпаки',
						'кумыки', 'крымские татары', 'якуты', 'афшары', 'карачаевцы', 'тувинцы', 'гагаузы', 
						'балкарцы', 'ногайцы', 'салары', 'хакасы', 'алтайцы', 'халаджи', 'югуры', 'долганы', 
						'белорусские татары', 'литовские татары', 'польские татары', 'хотоны', 'шорцы', 
						'караимы', 'крымчаки', 'тофалары', 'чулымцы', 'цаатаны'],
	last_update = now()
where nationality_id = 5

-- Добавление столбцов и значений в таблицу-справочник country

alter table country 
add column exists_now int2,
add column last_update date default now() not null

update country
set exists_now = 1,
	last_update = now()

-- Добавление столбцов и значений в таблицу-справочник country

alter table country_nationality 
add column population text,
add column last_update date default now() not null

update country_nationality
set population = 'около 82.69% населения по данным ВПН2010',
	last_update = now()
where country_id = 1 and nationality_id = 1

update country_nationality
set population = 'около 7.6% населения по данным ВПН2010',
	last_update = now()
where country_id = 1 and nationality_id = 5

update country_nationality
set population = 'около 92% населения по данным переписи населения 2018г.',
	last_update = now()
where country_id = 2 and nationality_id = 3

update country_nationality
set population = 'около 15.6% населения по данным переписи населения 2001г.',
	last_update = now()
where country_id = 3 and nationality_id = 2

update country_nationality
set population = 'около 76.6% населения по данным переписи населения 2001г.',
	last_update = now()
where country_id = 3 and nationality_id = 3
