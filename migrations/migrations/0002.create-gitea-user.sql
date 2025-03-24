--
-- file: migrations/0002.create-gitea.user.sql
--

-- depends: 0001.create-gitea-database

CREATE USER 'gitea'@'localhost' IDENTIFIED BY 'pass';

GRANT ALL PRIVILEGES ON gitea.* TO 'gitea'@'localhost';

FLUSH PRIVILEGES;
