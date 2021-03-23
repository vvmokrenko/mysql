-- Подробная информация об адресе
create or replace view v_address as 
select 
  a.id,                    -- "Идентификатор адреса", 
  r.name as region_name,   -- "Регион"
  c2.name as country_name, -- "Страна"
  a.postindex,             -- "Почтовый индекс",
  c.name as city_name,     -- "Город"
  a.street_id,             -- "Идентификатор улицы", 
  s.name as street_name,   -- "Наимеование улицы" 
  a.house,                 -- "Номер дома", 
  buildings,               -- "Корпус",
  a.flat,                  -- "Номер квартиры",
  a.addrname,              -- "Для неформализуемых адресов",
  a.distance_from_center,  -- "Расстояние от центра в километрах",
  a.distance_from_uground  -- "Расстояние до ближайшего метро"
from 
  addresses a 
  left join streets s on s.id = a.street_id 
  left join cities c on c.id = s.city_id 
  left join countries c2 on c2.id = c.id
  left join regions r on r.id = c2.region_id 
;

-- select * from v_address;
-- -------------------------------------------------------------------------------------------------------------------------

-- Функция для отображения информации об адресе 
DROP FUNCTION IF EXISTS f_address_info;
DELIMITER //

CREATE FUNCTION f_address_info(p_addr_id BIGINT, p_addr_type_id SMALLINT)
RETURNS VARCHAR(512) READS SQL DATA
BEGIN 
  DECLARE v_ret TEXT;  
  DECLARE table_name VARCHAR(50);
  SELECT name FROM addr_types WHERE id = p_addr_type_id INTO table_name;
  
  CASE table_name
    WHEN 'Адрес' THEN
    
     select 
       case when va.addrname is not null 
            then va.addrname 
            else CONCAT_WS(', ', va.region_name, va.country_name, va.postindex, va.city_name, va.street_name, va.house, va.buildings, va.flat)
       end address_info 
     into v_ret
     from v_address va
     where va.id=p_addr_id;
 
    WHEN 'Улица' THEN 
    
     select
       CONCAT_WS(', ', r.name, c2.name, c.name, s.name)
     into v_ret
     from 
       streets s
       join cities c on c.id = s.city_id 
       join countries c2 on c2.id = c.id 
       join regions r on r.id = c2.region_id 
     where s.id=p_addr_id;
 
    WHEN 'Город' THEN 
    
     select
       CONCAT_WS(', ', r.name, c2.name, c.name)
     into v_ret
     from 
       cities c 
       join countries c2 on c2.id = c.id 
       join regions r on r.id = c2.region_id 
     where c.id=p_addr_id;
    
    WHEN 'Страна' THEN
    
     select
       CONCAT_WS(', ', r.name, c2.name)
     into v_ret
     from 
       countries c2
       join regions r on r.id = c2.region_id 
     where c2.id=p_addr_id;
    
      
    WHEN 'Регион' THEN
    
     select
       r.name 
     into v_ret
     from 
       regions r
     where r.id=p_addr_id;
 
  END CASE;
  
  RETURN SUBSTRING(v_ret,1,512);
END//

DELIMITER ;

-- SELECT f_address_info(1,1);
-- SELECT f_address_info(1,2);
-- SELECT f_address_info(1,3);
-- SELECT f_address_info(1,4);
-- SELECT f_address_info(1,5);
-- ------------------------------------------------------------------------------------------------------------



-- Функция для отображения подробной информации о пользователе/участнике в виде json
DROP FUNCTION IF EXISTS f_user_info;
DELIMITER //

CREATE FUNCTION f_user_info(p_user_id BIGINT)
RETURNS JSON READS SQL DATA
BEGIN 
  DECLARE v_ret JSON;
  
  select 
    json_object("Фамилия", u.last_name,
                "Имя",     u.first_name,
                "Email",   u.email,
                "Телефон", u.phone,
                "Пол",     case p.gender 
                           when 'm' then 'муж'
                           when 'f' then 'жен'
                           end,
                "Дата рождения", p.birthday,
                "Адрес для связи", f_address_info(p.address_id, 1),
                "Последний сеанс", p.last_login)
  into
    v_ret
  from 
    users u
    join profiles p on p.user_id  = u.id
  where u.id = p_user_id
  ;

  RETURN v_ret;
END//

DELIMITER ;

-- SELECT f_user_info(1);
-- --------------------------------------------------------------------------------------------------------------



-- Описание предложения по бронироваию
create or replace view v_offer as 
select 
  bt.name as "Тип предложения",
  f_user_info(o.user_id) as "Кем размещено",
  -- Для адреса используем униваеральную функцию
  f_address_info(o.address_id, 1) as "Адрес объекта",
  o.begin_date as "Возможная дата старта предложения",
  o.end_date as "Возможная дата окончания предложения",
  o.note as "Комментарий к предложению",
  o.created_at as "Дата размещения предложения",
  o.id
from 
  offers o
  join booking_types bt on bt.id = o.booking_type_id
;  

-- select * from v_offer;
-- ------------------------------------------------------------------------------------------------------------------------------------


-- Справочник свойств с развернутой иерархией. Использует recursive feature
create or replace view v_properties as
with recursive cte (id, name, parent_id, path) as (
  select     id,
             name,
             parent_id,
             name path
  from       properties 
  where      parent_id is null
  union all
  select     p.id,
             p.name,
             p.parent_id,
             concat_ws('->', cte.path, p.name) path
  from       properties p
  inner join cte
          on p.parent_id = cte.id
)
select * from cte;


-- select * from v_properties;


