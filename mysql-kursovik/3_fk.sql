alter table countries add constraint fk_countries  foreign key (region_id) references regions(id);
alter table cities add constraint fk_cities  foreign key (country_id) references countries(id);
alter table streets add constraint fk_streets  foreign key (city_id) references cities(id);
alter table addresses add constraint fk_addresses  foreign key (street_id) references streets(id);

-- -------------------------------------------------------------------------------------------------------
alter table addr_places add constraint fk_addr_places_addr_type_id foreign key (addr_type_id) references addr_types(id);
alter table addr_places add constraint fk_addr_places_place_id foreign key (place_id) references places(id);

-- -------------------------------------------------------------------------------------------------------
alter table profiles add constraint fk_profiles_users  foreign key (user_id) references users(id);
alter table profiles add constraint fk_profiles_address_id  foreign key (address_id) references addresses(id);

-- -------------------------------------------------------------------------------------------------------
alter table properties add constraint fk_properties_parent_id  foreign key (parent_id) references properties(id);
alter table properties add constraint fk_properties_parent_id2  foreign key (parent_id2) references properties(id);
alter table properties add constraint fk_properties_parent_id3  foreign key (parent_id3) references properties(id);

-- -------------------------------------------------------------------------------------------------------
alter table booking_properties add constraint fk_booking_properties_types foreign key (booking_type_id) references booking_types(id);
alter table booking_properties add constraint fk_booking_properties_properties foreign key (property_id) references properties(id);

-- -------------------------------------------------------------------------------------------------------
alter table offers add constraint fk_offers_user_id foreign key (user_id) references users(id);
alter table offers add constraint fk_offers_booking_type_id foreign key (booking_type_id) references booking_types(id);
alter table offers add constraint fk_offers_address_id foreign key (address_id) references addresses(id);

-- -------------------------------------------------------------------------------------------------------
alter table offer_properties add constraint fk_offer_properties_offer_id foreign key (offer_id) references offers(id);
alter table offer_properties add constraint fk_offer_properties_booking_properties_id foreign key (booking_property_id) references booking_properties(id);

-- -------------------------------------------------------------------------------------------------------
alter table facts add constraint fk_facts_offer_id foreign key (offer_id) references offers(id);
alter table facts add constraint fk_facts_user_id foreign key (user_id) references users(id);

-- -------------------------------------------------------------------------------------------------------
alter table fact_properties add constraint fk_fact_properties_fact_id foreign key (fact_id) references facts(id);
alter table fact_properties add constraint fk_fact_properties_property_id foreign key (property_id) references properties(id);

-- -------------------------------------------------------------------------------------------------------
alter table likes add constraint uk_likes unique key(user_id, target_id, target_type_id);
alter table likes add constraint fk_likes_user_id foreign key (user_id) references users(id);
alter table likes add constraint fk_likes_target_type_id foreign key (target_type_id) references target_types(id);

