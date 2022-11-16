## Notes on the RDS Module

### Deployment configuration

This module deploys an RDS cluster in Serverless V1 configuration using a postgres 11.x engine (the latest availble on Serverless). Serverless V1 will scale to "off" if `auto_pause` is set to `true` and after the `seconds_until_auto_pause` duration without any activity. Serverless V1 was chosen because it is compatible with AWS Data API which provides Engineers access without the need for a Bastion host within our VPC. Serverless V2 is not compatible with AWS Data API and does not scale to "off" when not in use.

### How to prepare the databases

Forms-api and Forms-admin each have their own database and both are setup in this single RDS cluster. After the initial `terraform apply` of this module into an environment run the SQL within `prepare.sql` via the Data API to create the databases, roles and users for the apps. The `prepare.sql` SQL is idempotent in a basic sense, if the object already exists that particular statement will fail but the others will continue to execute (unless you select the "fail on first error" within Data API). This is a one off operation and any future restores will be from snap shots or backups. The passwords for each of the app users should be set as a secure string within SSM parameter store at the location shown in the file.

Each app is currently configured to run its database migrations when it starts. These migrations will create the necessary tables and indexes and no further manual setup should be required.