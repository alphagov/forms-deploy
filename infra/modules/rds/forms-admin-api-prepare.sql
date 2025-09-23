-- This SQL is intended to only run when first creating the postgres rds instances
-- for forms-admin and forms-api. It should be applied via the AWS Data API. The passwords
-- for each user should be found in SSM Parameter Store at the paths shown below.
-- All tables are created and managed by forms-api and forms-admin db migrations via Ruby.

-- Prepare forms-api database, role and user
CREATE DATABASE "forms-api";
CREATE ROLE "forms-api-readwrite";
GRANT CONNECT ON DATABASE "forms-api" TO "forms-api-readwrite";
GRANT USAGE, CREATE ON SCHEMA "public" TO "forms-api-readwrite";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "public" TO "forms-api-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "forms-api-readwrite";
GRANT USAGE ON ALL SEQUENCES IN SCHEMA "public" TO "forms-api-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO "forms-api-readwrite";
-- CREATE USER "forms-api-app" WITH PASSWORD [REPLACE WITH VALUE FROM SSM PARAMETER STORE /forms-api/database/password and then uncomment];
GRANT "forms-api-readwrite" TO "forms-api-app";

-- Prepare forms-admin database, role and user
CREATE DATABASE "forms-admin";
CREATE ROLE "forms-admin-readwrite";
GRANT CONNECT ON DATABASE "forms-admin" TO "forms-admin-readwrite";
GRANT USAGE, CREATE ON SCHEMA "public" TO "forms-admin-readwrite";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "public" TO "forms-admin-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "forms-admin-readwrite";
GRANT USAGE ON ALL SEQUENCES IN SCHEMA "public" TO "forms-admin-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO "forms-admin-readwrite";
-- CREATE USER "forms-admin-app" WITH PASSWORD [REPLACE WITH VALUE FROM SSM PARAMETER STORE /forms-admin/database/password and then uncomment];
GRANT "forms-admin-readwrite" TO "forms-admin-app";
GRANT "rds_extension" TO "forms-admin-app";

