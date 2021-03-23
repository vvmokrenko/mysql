-- Справочник регионов мира
DROP TABLE IF EXISTS regions;
CREATE TABLE regions (
  id SMALLINT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Идентификатор региона",
  name VARCHAR(255)  COMMENT "Наименование региона"
) COMMENT 'Справочник регионов мира';

insert into regions(id, name)
values 
  (1, 'Европа'),
  (2, 'Азия'),
  (3, 'Северная Америка'),
  (4, 'Южная Америка'),
  (5, 'Африка'),
  (6, 'Австралия И Океания');

-- Справочник стран
DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор страны", 
  region_id SMALLINT UNSIGNED NOT NULL COMMENT "Идентификатор региона", 
  name VARCHAR(255)  COMMENT "Наименование страны"
) COMMENT 'Справочник стран мира';

-- Справочник городов
DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор города", 
  country_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор страны", 
  name VARCHAR(255)  COMMENT "Наименование города"
) COMMENT 'Справочник городов';

-- Справочник улиц
DROP TABLE IF EXISTS streets;
CREATE TABLE streets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор улицы", 
  city_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор города", 
  name VARCHAR(255)  COMMENT "Наименование улицы"
) COMMENT 'Справочник улиц';

-- Справочник адресов
DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор адреса", 
  postindex BIGINT COMMENT "Номер индекса",
  street_id BIGINT UNSIGNED COMMENT "Идентификатор улицы", 
  house    VARCHAR(32) COMMENT "Номер дома",
  buildings    VARCHAR(32) COMMENT "Корпус",
  flat    VARCHAR(32)  COMMENT "Номер квартиры",
  addrname VARCHAR(255)  COMMENT "Для неформализуемых адресов",
  distance_from_center int COMMENT "Расстояние от центра в метрах",
  distance_from_uground int COMMENT "Расстояние до ближайшего метро"
) COMMENT 'Справочник адресов';

-- Справочник направлений/ориентиров/достопримечателностей
DROP TABLE IF EXISTS places;
CREATE TABLE places (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор направления/ориентира/достопримечателности", 
  name VARCHAR(255)  COMMENT "Наименование направления/ориентира/достопримечателности",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT 'Справочник направлений/ориентиров/достопримечателностей';

-- Справочник типов адресной информации
DROP TABLE IF EXISTS addr_types;
CREATE TABLE addr_types (
  id SMALLINT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Идентификатор типа адресной информации", 
  name VARCHAR(64) COMMENT "Наименование типа адресной информации",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник типов адресной информации"; 


INSERT INTO addr_types(id, name) 
VALUES (1, 'Адрес'),
       (2, 'Улица'),
       (3, 'Город'),
       (4, 'Страна'),
       (5, 'Регион')
;

-- Связь базы адресов/городов/улиц с данными по направлениям/ориентирам/достопримечательностям
DROP TABLE IF EXISTS addr_places;
CREATE TABLE addr_places (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  addr_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор строки таблицы адресной базы",
  addr_type_id SMALLINT UNSIGNED NOT NULL COMMENT "Идентификатор типа адресной информации", 
  place_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор направления/ориентира/достопримечателности",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT 'Связь базы адресов/городов/улиц с данными по направлениям/ориентирам/достопримечательностям';


-- Таблица пользователей
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
  email VARCHAR(100) NOT NULL COMMENT "Почта",
  phone VARCHAR(100) NOT NULL COMMENT "Телефон",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  username VARCHAR(30) NOT NULL COMMENT 'Имя пользователя для входа в сервис',
  UNIQUE KEY uk_users_email (email),
  UNIQUE KEY uk_users_phone (phone)
) COMMENT "Пользователи";  


-- Таблица профилей
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Ссылка на пользователя", 
  gender enum('m','f') NOT NULL COMMENT "Пол",
  birthday DATE COMMENT "Дата рождения",
  address_id BIGINT UNSIGNED COMMENT  "Адрес места жительства",
  last_login DATETIME COMMENT "Последний вход в систему",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Профили"; 




/* 
Справочник свойств(услуг, опций) бронирования.
Делаем самоссылающийся справочник, т.к. некотрые атрибуты могут иметь одну или более характеристик, которые, в свою очередь, являются тоже атрибутами. 
(например, модель авто является характеристикой марки авто и в то же время имеет характеристику класс авто) 
*/
DROP TABLE IF EXISTS properties;
CREATE TABLE properties(
  id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Идентификатор свойства", 
  name VARCHAR(64) COMMENT "Наименование свойства",  
  parent_id  INT UNSIGNED COMMENT "Идентификатор родительского свойства 1-го порядка",   
  parent_id2  INT UNSIGNED COMMENT "Идентификатор родительского свойства 2-го порядка",   
  parent_id3  INT UNSIGNED COMMENT "Идентификатор родительского свойства 3-го порядка", 
  default_price_formula VARCHAR(255) COMMENT "Формула расчета цены по умолчанию при включении данной услуги в предложение", 
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник свойств(услуг, опций) бронирования."; 



INSERT INTO properties(id, name, parent_id, parent_id2, parent_id3) 
VALUES (100, 'Типы жилья',          null, null, null),
       (101, 'Отель',               100, null, null),
       (901, '5 звезд',             101, null, null),
       (902, '4 звезды',            101, null, null),
       (903, '3 звезды',            101, null, null),
       (102, 'Санаторий',           100, null, null),
       (103, 'Профилакторий',       100, null, null),
       (104, 'Коттедж',             100, null, null),
       (105, 'Аппартаменты',        100, null, null),
       (106, 'Дом отдыха',          100, null, null),
       (107, 'База отдыха',         100, null, null),
       (108, 'Кемпинг',             100, null, null),
       (109, 'Комната',             100, null, null),
       (110, 'Хостел',              100, null, null),
       (200, 'Класс авиабилетов',   null, null, null),
       (201, 'Бизнес',              200, null, null),
       (202, 'Эконом',              200, null, null),
       (300, 'Класс авто',          null, null, null),
       (301, 'Эконом',              300, null, null),
       (302, 'Комфорт',             300, null, null),
       (303, 'Бизнес',              300, null, null),    
       (400, 'Марка авто',          null, null, null),        
       (401, 'BMW',                 400, null, null),                
       (402, 'VW',                  400, null, null),                
       (403, 'KIA',                 400, null, null),    
       (500, 'Модель авто',         null, null, null),        
       (501, 'X1',                  501, 401, 303),        
       (502, 'Tuareg',              502, 402, 303),        
       (503, 'Polo',                503, 402, 301),         
       (504, 'K5',                  504, 403, 302),         
       (505, 'Rio',                 505, 403, 301),     
       (600, 'Доп.услуги',          null, null, null),                   
       (601, 'Трансферт до',        600, null, null),                       
       (602, 'Трансферт после',     600, null, null),                       
       (603, 'Экскурсия',           600, null, null),                       
       (604, 'Гид',                 600, null, null),                       
       (605, 'СПА',                 600, null, null),                       
       (606, 'Дайвинг',             600, null, null),                       
       (607, 'Горный туризм',       600, null, null),                       
       (608, 'Прогулки по городу',  600, null, null),                           
       (609, 'Бассейн',             600, null, null),                           
       (610, 'Массаж',              600, null, null),                           
       (611, 'Косметолог',          600, null, null),                           
       (612, 'Парковка',            600, null, null),       
       (700, 'Точки маршрута',      null, null, null),       
       (701, 'От',                  700, null, null),       
       (702, 'До',                  700, null, null),       
       (800, 'Удобства',            null, null, null),       
       (801, 'Кровать',             800, null, null),       
       (802, 'односпальная',        801, null, null),       
       (803, 'полуторная',          801, null, null),       
       (804, 'двуспальняя',         801, null, null),       
       (805, 'диван-кровать',       801, null, null),           
       (806, 'раскладное кресло',   801, null, null),           
       (807, 'диван-кровать',       801, null, null),           
       (808, 'Доп. кровать',        800, null, null),           
       (809, 'Кондиционер',         800, null, null),           
       (810, 'Телевизор',           800, null, null),           
       (811, 'Холодильник',         800, null, null),           
       (812, 'Санузел',             800, null, null),           
       (813, 'Мини-бар',            800, null, null),           
       (814, 'Wi-Fi',               800, null, null),           
       (1000, 'Тип питания',        null, null, null),           
       (1001, 'завтрак',            1000, null, null),           
       (1002, 'обед',               1000, null, null),           
       (1003, 'ужин',               1000, null, null),           
       (1004, 'индивидуальный стол',1000, null, null),           
       (1005, 'собственная кухня',  1000, null, null),           
       (1100, 'Тип отдыха',         null, null, null),               
       (1101, 'семейный',           1100, null, null),           
       (1102, 'молодежный',         1100, null, null),           
       (1103, 'индивидуальный',     1100, null, null),           
       (1200, 'Тип программы',      null, null, null),           
       (1201, 'Экскурсионная',      1200, null, null),           
       (1202, 'Туристическая',      1200, null, null)            
;




-- Справочник основных услуг бронирования
DROP TABLE IF EXISTS booking_types;
CREATE TABLE booking_types (
  id SMALLINT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Идентификатор типа основной услуги", 
  name VARCHAR(64) COMMENT "Наименование типа основной услуги",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник основных услуг бронирования"; 

INSERT INTO booking_types(id, name) 
VALUES (1, 'Жилье'),
       (2, 'Авиабилеты'),
       (3, 'Аренда машин'),
       (4, 'Варианты досуга'),
       (5, 'Такси от/до аэропорта')
;


/*
Справочник допустимых комбинаций "основная услуга-опция". 
Служит для настройки фильтра опций по конкретной основной услуге и предоставлению выбора пользователю.
*/

DROP TABLE IF EXISTS booking_properties;
CREATE TABLE booking_properties(
  id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Идентификатор комбинации", 
  booking_type_id SMALLINT UNSIGNED COMMENT "Ссылка на основную услугу",  
  property_id INT UNSIGNED COMMENT "Ссылка на допустимую опцию для услуги",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT "Справочник наборов атрибутов по каждой основной услуге"; 


insert into booking_properties(id, booking_type_id, property_id)
VALUES 
  (10, 1, 100), 
  (11, 1, 800), 
  (20, 2, 200), 
  (21, 2, 701), 
  (22, 2, 702),
  (23, 2, 601),
  (24, 2, 602),
  (30, 3, 300),
  (31, 3, 400),
  (32, 3, 500), 
  (40, 4, 603), 
  (41, 4, 604), 
  (42, 4, 605), 
  (43, 4, 606), 
  (44, 4, 607), 
  (45, 4, 608), 
  (46, 4, 609), 
  (47, 4, 610), 
  (48, 4, 611), 
  (50, 5, 701),
  (51, 5, 702)
;
 



-- Таблица предложений по бронированию
DROP TABLE IF EXISTS offers;
CREATE TABLE offers (
id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор предложения", 
user_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор пользователя, разместившего предложение",
booking_type_id SMALLINT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор основной услуги бронирования",
address_id BIGINT UNSIGNED NOT NULL COMMENT "Основной адрес предложения",
begin_date datetime COMMENT "Дата начала предложения. Если пусто, то предложение ограничивается любой датой до даты окончания предложения",
end_date datetime COMMENT "Дата окончания предложения. Если пусто, то предложение не ограничено датой справа",
note VARCHAR(512) COMMENT "Комментарий к предложению",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT "Таблица предложений по бронированию"
; 



/*
Таблица возможных свойств(услуг) в рамках конкретного предложения. 
Обращаем внимание, что здесь ссылаемся на справочник потенциальных опций по основной услуге.
*/

DROP TABLE IF EXISTS offer_properties;
CREATE TABLE offer_properties (
id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор услуги по предложению", 
offer_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор предложения",
booking_property_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор пары свойство-услуга",
is_optional bool COMMENT "Признак опциональности опции в рамках предложения",
price NUMERIC(10,2) COMMENT "Цена опции в рамках предложения",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT "Таблица возможных атрибутов(услуг) в рамках конкретного предложения"
; 


-- Таблица фактов бронирования 
DROP TABLE IF EXISTS facts;
CREATE TABLE facts (
id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор брони", 
offer_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор забронированного предложения",
user_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор пользователя, забронировавшего предложение",
total_price NUMERIC(10,2) NOT NULL COMMENT "Сумма к оплате по факту бронирования",
note VARCHAR(512) COMMENT "Ссылка на идентификатор основной услуги бронирования",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT "Таблица фактов бронирования по предложению"
; 


-- Таблица свойств(атрибутов) бронирования. Содержит четкий список услуг, заказынных в рамках конкретной брони. 
-- Обращаем внимание, что здесь ссылаемся на конкретную оплаченную опцию по забронированному предложению.
DROP TABLE IF EXISTS fact_properties;
CREATE TABLE fact_properties (
id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор заказанной опции", 
fact_id BIGINT UNSIGNED NOT NULL COMMENT "Идентификатор предложения",
property_id INT UNSIGNED NOT NULL COMMENT "Ссылка на идентификатор заказанной опции по основной услуге",
price NUMERIC(10,2) COMMENT "Фактическая цена опции",
created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
) COMMENT "Таблица свойств(атрибутов) бронирования. Содержит четкий список услуг, заказынных в рамках конкретной брони"
; 


-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id SMALLINT UNSIGNED NOT NULL PRIMARY KEY COMMENT 'Идентификатор типа(объекта) лайка',
  name VARCHAR(255) NOT NULL UNIQUE  COMMENT 'Наименование типа(объекта) лайка',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки'
);

INSERT INTO target_types (id, name) VALUES 
  (1, 'address'),
  (2, 'property'),
  (3, 'offer'),
  (4, 'client'),
  (5, 'executor');


-- Таблица лайков и дизлайков. UK создается для того, чтобы обеспечить от одного пользователя только один ответ на конкретный объект
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Идентификатор строки',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'Ссылка на автора лайка/дизлайка',
  target_id BIGINT UNSIGNED NOT NULL COMMENT 'Ссылка на идентифкатор объекта лайка',
  target_type_id SMALLINT UNSIGNED NOT NULL COMMENT 'Ссылка на идентификатор типа лайка',
  is_like bool NOT NULL COMMENT 'Лайк или дизлайк',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки'
) COMMENT='Таблица лайков/дизлайков';

