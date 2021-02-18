-- Изменения структур по внесенным учениками предложениям
alter table users modify column created_at datetime not null;
alter table users modify column updated_at datetime not null;

alter table profiles add constraint fk_profile_users foreign key (user_id) references users(id);

alter table users add username varchar(30) not null comment "Имя пользователя для входа в сервис";

alter table messages modify column id bigint;
alter table media modify column id bigint;


-- Приводим в порядок временные метки
UPDATE users SET updated_at = NOW() WHERE updated_at < created_at;  
UPDATE communities SET updated_at = NOW() WHERE updated_at < created_at;  
UPDATE friendship SET updated_at = NOW() WHERE updated_at < created_at;
UPDATE friendship_statuses SET updated_at = NOW() WHERE updated_at < created_at;  
UPDATE media SET updated_at = NOW() WHERE updated_at < created_at;  
UPDATE media_types SET updated_at = NOW() WHERE updated_at < created_at;  
UPDATE profiles SET updated_at = NOW() WHERE updated_at < created_at;  


-- Добавим значения username
UPDATE users SET username = LOWER(last_name);                

-- Преобразуем в тип ENUM поле gender
ALTER TABLE profiles MODIFY COLUMN gender ENUM('m', 'w');

-- Создаём временную таблицу стран
CREATE TEMPORARY TABLE countries(name VARCHAR(50));

-- Удаляем все типы
TRUNCATE media_types;

-- Добавляем нужные типы
INSERT INTO media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio')
;

-- Обновляем данные для ссылки на тип
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 3);


-- Добавим страны
INSERT INTO countries VALUES
  ('Russian Federation'),
  ('Belarus'),
  ('Germany'),
  ('USA');
  
-- Вставляем случайную страну в столбец country  
UPDATE profiles SET country = (SELECT name FROM countries ORDER BY RAND() LIMIT 1);  

-- Создаём временную таблицу форматов медиафайлов
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));

-- Заполняем значениями
INSERT INTO extensions VALUES ('jpeg'), ('avi'), ('mpeg'), ('png');

-- Проверяем
SELECT * FROM extensions;

-- Обновляем ссылку на файл
UPDATE media SET filename = CONCAT(
  'http://dropbox.net/vk/',
  filename,
  '.',
  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);

-- Обновляем размер файлов
UPDATE media SET size = FLOOR(10000 + (RAND() * 1000000)) WHERE size < 1000;

-- Заполняем метаданные
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
  '"}');  



-- Обновляем ссылки на друзей
UPDATE friendship SET 
  user_id = FLOOR(1 + RAND() * 100),
  friend_id = FLOOR(1 + RAND() * 100);

-- Исправляем случай когда user_id = friend_id
UPDATE friendship SET friend_id = friend_id + 1 WHERE user_id = friend_id;
 
  
  
  -- Очищаем таблицу
TRUNCATE friendship_statuses;

-- Вставляем значения статусов дружбы
INSERT INTO friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');
 
-- Обновляем ссылки на статус 
UPDATE friendship SET friendship_status_id = FLOOR(1 + RAND() * 3); 


DELETE FROM communities WHERE id > 20;


-- Обновляем значения community_id и user_id
UPDATE communities_users SET
  user_id = FLOOR(1 + RAND() * 100),
  community_id = FLOOR(1 + RAND() * 20)
;


  ------------------------------------------------------------------------------------
  -- Таблица постов
  drop table if exists `posts`;
  CREATE TABLE `posts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор поста',
  `from_user_id` int unsigned NOT NULL COMMENT 'Ссылка на автора поста',
  `body` text NOT NULL COMMENT 'Текст сообщения',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  PRIMARY KEY (`id`)
) COMMENT='Таблица постов';

-- Таблица лайков и дизлайков. PK создается для того, чтобы обеспечить от одного пользовтеля
-- только один ответ на конкретный пост
 drop table if exists `likes`;
 CREATE TABLE `likes` (
  `post_id` bigint unsigned NOT null COMMENT 'Ссылка на пост',
  `from_user_id` int unsigned NOT NULL COMMENT 'Ссылка на автора лайка',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания строки',
  `is_like` bool COMMENT 'Лайк или дизлайк',
  PRIMARY KEY (`post_id`,`from_user_id`) COMMENT 'Составной первичный ключ',
  CONSTRAINT `fk_likes_posts` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
) COMMENT='Таблица лайков';


-- Таблица для быстрого отображения статистики по лайкам и дизлайкам. 
-- Выделена отдельно, чтобы улучшить производительность.
-- Обновляем синхронно по триггеру в таблице likes или асинхронно.

 drop table if exists `posts_stat`;
 CREATE TABLE `posts_stat` (
  `post_id` bigint unsigned NOT null COMMENT 'Ссылка на пост',
  `count_likes` bigint unsigned NOT NULL COMMENT 'Количество лайков',
  `count_dislikes` bigint unsigned NOT NULL COMMENT 'Количество дизлайков',
  CONSTRAINT `fk_posts_stat_posts` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
) COMMENT='Таблица статитсики по лайкам для постов';

  

