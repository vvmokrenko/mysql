

-- Выбор предложений по конкретному направлению 

DROP PROCEDURE IF EXISTS get_place_offers;
DELIMITER //

CREATE PROCEDURE get_place_offers(p_place_id INT)
READS SQL DATA
BEGIN
  -- По каждому направлению отображаем пользователю предложения 
  -- Сортируем предложения по рейтингу
  
  -- Создаем список всех предложений, относящихся к данному направлению
   
   -- Предложения по адресам, котрые напрямую привязаны к направлению
   select 
     o.*
   from
     places p
     join addr_places ap on ap.place_id = p.id
     join addr_types at2 on at2.id = ap.addr_type_id 
     join offers o on o.address_id = ap.addr_id
   where 
     ap.place_id = p_place_id
     and at2.name = 'Адрес'
   union 
   -- Предложения по адресам, котрые привязаны к улицам, котрые в свою очередь привязаныы к направлению
   select 
     o.*
   from
     places p
     join addr_places ap on ap.place_id = p.id
     join addr_types at2 on at2.id = ap.addr_type_id 
     join addresses a on a.street_id = ap.addr_id
     join offers o on o.address_id = a.id
   where 
     ap.place_id = p_place_id
     and at2.name = 'Улица'
   union
   -- Предложения по адресам, котрые привязаны к городам
   select 
     o.*
   from
     places p
     join addr_places ap on ap.place_id = p.id
     join addr_types at2 on at2.id = ap.addr_type_id 
     join streets s on s.city_id = ap.addr_id
     join addresses a on a.street_id = s.id
     join offers o on o.address_id = a.id
   where 
     ap.place_id = p_place_id
     and at2.name = 'Город'     
   union
   -- Предложения по адресам, котрые привязаны к странам
   select 
     o.*
   from
     places p
     join addr_places ap on ap.place_id = p.id
     join addr_types at2 on at2.id = ap.addr_type_id 
     join cities c on c.country_id = ap.addr_id
     join streets s on s.city_id = c.id
     join addresses a on a.street_id = s.id
     join offers o on o.address_id = a.id
   where 
     ap.place_id = p_place_id
     and at2.name = 'Страна'  
   ;
   
END//

DELIMITER ;

-- call get_place_offers(2);
-- ------------------------------------------------------------------------------------------------------------------------


-- Триггеры, запрещающие менять какие-либо характеристики предложения, если оно уже забронировано

DELIMITER //
DROP TRIGGER IF EXISTS BD_OFFERS//
CREATE TRIGGER BD_OFFERS BEFORE DELETE ON offers
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = OLD.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в уже забронированное предложение';
  END IF;
  
END//

DELIMITER //
DROP TRIGGER IF EXISTS BU_OFFERS//
CREATE TRIGGER BU_OFFERS BEFORE UPDATE ON offers
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = OLD.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в уже забронированное предложение';
  END IF;
  
END//

DELIMITER //
DROP TRIGGER IF EXISTS AI_OFFERS//
CREATE TRIGGER AI_OFFERS AFTER INSERT ON offers
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = NEW.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в уже забронированное предложение';
  END IF;
  
END//

DELIMITER //
DROP TRIGGER IF EXISTS BD_OFFER_PROPERTIES//
CREATE TRIGGER BD_OFFER_PROPERTIES BEFORE DELETE ON offer_properties
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = OLD.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в характеристики уже забронированного предложения';
  END IF;
  
END//

DELIMITER //
DROP TRIGGER IF EXISTS BU_OFFER_PROPERTIES//
CREATE TRIGGER BU_OFFER_PROPERTIES BEFORE UPDATE ON offer_properties
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = OLD.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в характеристики уже забронированного предложения';
  END IF;
  
END//

DELIMITER //
DROP TRIGGER IF EXISTS AI_OFFER_PROPERTIES//
CREATE TRIGGER AI_OFFER_PROPERTIES AFTER INSERT ON offer_properties
FOR EACH ROW 
BEGIN
    
  IF EXISTS (select null from facts f where f.offer_id = NEW.id) then 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Нельзя вносить изменения в характеристики уже забронированного предложения';
  END IF;
  
END//

