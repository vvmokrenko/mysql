-- это НЕ внешний ключ
create index i_likes_target_id on likes(target_id);
-- это НЕ внешний ключ
create index i_addr_places_addr_id on addr_places(addr_id);
--
create index i_countries_name on countries(name);


