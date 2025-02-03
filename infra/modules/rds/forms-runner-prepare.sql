-- This SQL is intended to only run when first creating the postgres rds instances
-- for forms-runneri. It should be applied via the AWS Data API. The passwords
-- for each user should be found in SSM Parameter Store at the paths shown below.
-- All tables are created and managed by forms-runner db migrations via Ruby.

-- Prepare forms-runner database, role and user
CREATE DATABASE "forms-runner";
CREATE ROLE "forms-runner-readwrite";
GRANT CONNECT ON DATABASE "forms-runner" TO "forms-runner-readwrite";
GRANT USAGE, CREATE ON SCHEMA "public" TO "forms-runner-readwrite";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA "public" TO "forms-runner-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "forms-runner-readwrite";
GRANT USAGE ON ALL SEQUENCES IN SCHEMA "public" TO "forms-runner-readwrite";
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT USAGE ON SEQUENCES TO "forms-runner-readwrite";
-- CREATE USER "forms-runner-app" WITH PASSWORD [REPLACE WITH VALUE FROM SSM PARAMETER STORE /forms-runner-{env}/database/password and then uncomment - note: password needs single quotes];
GRANT "forms-runner-readwrite" TO "forms-runner-app";

