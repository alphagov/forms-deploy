### Description

This module deploys an RDS cluster in Serverless V2 configuration using a postgres 13.x engine.

### How to prepare the databases

#### Forms-api and Forms-admin

Forms-api and Forms-admin each have their own database and both are setup in a single RDS cluster. The following is a one-off operation to be done after the initial creation of the cluster. Any subsequent restoration should be done via backups.
- Create a password for the `root` user and store it in SSM Parameter Store as a secure string in the `${app-identifier}/database/root-password` parameter that was created as part of the rds module.
- Using the console in AWS, add the same password created in the previous step as the `master password` of the aurora cluster you have just created.
- Create passwords for the `forms-api` and `forms-admin` users and store in SSM Parameter Store as secure strings in the `/${app-name}-${environment}/database/password` paramaters that were created as part of the rds module.
- Update the `/${app-name}-${environment}/database/url` with the database url in the format: `postgres://${db-user}:${password}@${aurora-endpoint}/${database name}`.
- Use the AWS Data API console to connect to the `postgres` database using username `root` and the root password created above.
- copy the `forms-admin-api-prepare.sql` script into the Data API console and replace the place-holders with the passwords above.
- Run the script and check each statement is successful.

Each app is currently configured to run its database migrations when it starts. These migrations will create the necessary tables and indexes and no further manual setup should be required.

#### Forms-runner

Forms-runner has two databases, which are setup in a separate RDS cluster to Forms-api and Forms-admin. There is an app database and a  database used by Solid Queue. The steps for their initial creation are the same as above, but using `forms-runner-prepare.sql`. Any subsequent restoration should be done via backups.

Forms-runner is currently configured to run its database migrations when it starts. These migrations will create the necessary tables and indexes and no further manual setup should be required.
