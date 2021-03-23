-- Услуги с наибольшим спросом. 
/*
 * Спрос определяем по количесту фактически заказанных услуг по фактам бронирования
 */
select 
  p.path as "Услуга",
  count(*) "Колиество заказов"
from  
  fact_properties f
  join v_properties p on p.id = f.property_id 
  join facts f2 on f2.id = f.fact_id 
  join offers o on o.id = f2.offer_id 
  join booking_types bt on bt.id = o.booking_type_id
where 
  p.parent_id is not null -- доп. фильтр к тестовм значениям
group by 
  p.path
order by 
 count(*) desc
;
-- ------------------------------------------------------------------------------------------------

-- Дома, которые нравятся гостям 
/*
 * Используем количество раз бронирования, но по предложениям за последние три года
 */

select 
  f_address_info(o.address_id, 1) as "Адрес объекта",
  rating
from (
    select 
      o.id,
      count(*) rating
    from  
      facts f 
      join offers o on o.id = f.offer_id 
    where 
      o.booking_type_id = 1 -- Жилье
      and o.begin_date >= DATE_ADD(NOW(), INTERVAL -3 YEAR)
    group by o.id 
    order by count(*) desc 
    limit 5
) t 
join offers o on o.id = t.id
order by rating
;
-- ----------------------------------------------------------------------------------------------------------------------


-- Запрос "Россия — откройте для себя эту страну"
/*
 * Берем все направления/ориентиры/достопримечательности из России и отображаем список всех доступных предложений
 */
DELIMITER //
DROP PROCEDURE IF EXISTS get_country_offers//
CREATE PROCEDURE get_country_offers (p_name varchar(255))
BEGIN
  DECLARE place_id BIGINT;
  DECLARE is_end INT DEFAULT 0;

  -- Запрос
  DECLARE cur CURSOR FOR 
  select 
  distinct 
    ap.place_id
    -- , ap.addr_id, ap.addr_type_id, c.id, ct.id, s.id, a.id 
    from 
      countries c
      left join cities ct on ct.country_id =c.id
      left join streets s on s.city_id = ct.id
      left join addresses a on a.street_id = s.id
      left join addr_places ap on 
        (
          (ap.addr_type_id = 1 and ap.addr_id = a.id) -- привязка места к конкретному адресу
          or 
          (ap.addr_type_id = 2 and ap.addr_id = s.id) -- привязка места к улице
          or 
          (ap.addr_type_id = 3 and ap.addr_id = ct.id) -- привязка места к городу
          or 
          (ap.addr_type_id = 4 and ap.addr_id = c.id) -- привязка места к стране
        )
    where 
      c.name = CONVERT(p_name USING utf8)
      and ap.id is not null -- Не интересуют пустые направления отдыха
    order by 
      -- Сортируем в порядке убывания географического размера
      -- Сначала то, что относится к стране, в конце то, что прикреплено к конкретному алресу 
      (case when ct.id is not null then 1 end),
      ap.addr_type_id desc,
      ap.addr_id -- добавочная сортировка
    ; 
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;
  
  --
  
  OPEN cur;

  cycle : LOOP
    FETCH cur INTO place_id;
    IF is_end THEN LEAVE cycle;
    END IF;

    -- Вызываем процедуру, отображающую ифнормацию о предложениях по конкретному направлению 
    call get_place_offers(place_id);

  END LOOP cycle;

  CLOSE cur;
END//

DELIMITER ;


call get_country_offers('Russia');
-- -----------------------------------------------------------------------------------------------------------------------------------

-- Лучшие три направления для дайвинга 
/*
 * Берем места, где больше всего востребована услуга "Дайвинг".
 * Перечисляем не конкретные адреса, где предоставлена услуга, а направления.
 * При этом если направление имеет адрес, по которому есть направление с адресом географически более крупным,
 * то в отбор должно попасть второе направление. Пример: если Улица1 иммет Направление1, а Улица2 имеет Направление2,
 * и обе улицы принадлежат городу с Направлением3, то в отбор должно попасть Направление3 
 */
select 
  p.name "Best places with diving"
  from (
    select
      coalesce(
        ap_countries.place_id,
        ap_cities.place_id,
        ap_streets.place_id,
        ap_addresses.place_id  
        ) top_place_id
    from 
      fact_properties fp
      join facts f on f.id = fp.fact_id 
      join offers o on o.id = f.offer_id
      join addresses a2 on a2.id = o.address_id 
      join streets s on s.id = a2.street_id 
      join cities c on c.id = s.city_id 
      join countries c2 on c2.id = c.country_id 
      join addr_places ap_addresses on ap_addresses.addr_id = a2.id and ap_addresses.addr_type_id = 1 -- адрес
      left join addr_places ap_streets on ap_streets.addr_id = s.id and ap_streets.addr_type_id = 2 -- улица
      left join addr_places ap_cities on ap_cities.addr_id = c.id and ap_cities.addr_type_id = 3 -- город  
      left join addr_places ap_countries on ap_countries.addr_id = s.id and ap_countries.addr_type_id = 4 -- страна
    where 
      fp.property_id  = 606 -- Дайвинг
    ) t 
    join places p on p.id = t.top_place_id
    group by p.name 
    order by count(*) desc 
    limit 3
;


