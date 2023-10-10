CREATE USER forms_admin WITH PASSWORD 'forms_admin' CREATEDB;
CREATE DATABASE forms_admin_development;
GRANT ALL PRIVILEGES ON DATABASE forms_admin_development TO forms_admin;

CREATE USER forms_api WITH PASSWORD 'forms_api' CREATEDB;
CREATE DATABASE forms_api_development;
GRANT ALL PRIVILEGES ON DATABASE forms_api_development TO forms_api;

ALTER DATABASE forms_admin_development OWNER TO forms_admin;
ALTER DATABASE forms_api_development OWNER TO forms_api;
