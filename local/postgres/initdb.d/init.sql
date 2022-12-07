CREATE USER forms_admin WITH PASSWORD 'forms_admin' CREATEDB;
CREATE DATABASE forms_admin;
GRANT ALL PRIVILEGES ON DATABASE forms_admin TO forms_admin;

CREATE USER forms_api WITH PASSWORD 'forms_api' CREATEDB;
CREATE DATABASE forms_api;
GRANT ALL PRIVILEGES ON DATABASE forms_api TO forms_api;

ALTER DATABASE forms_admin OWNER TO forms_admin;
ALTER DATABASE forms_api OWNER TO forms_api;
