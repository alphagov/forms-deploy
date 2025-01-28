### Description

This module deploys an RDS cluster in Serverless V1 configuration using a postgres 11.x engine (the latest available on Serverless). Serverless V1 will scale to "off" if `auto_pause` is set to `true` and after the `seconds_until_auto_pause` duration without any activity. Serverless V1 was chosen because it is compatible with AWS Data API which provides Engineers access without the need for a Bastion host within our VPC. Serverless V2 is not compatible with AWS Data API and does not scale to "off" when not in use.

### How to prepare the databases

#### Forms-api and Forms-admin

Forms-api and Forms-admin each have their own database and both are setup in this single RDS cluster. The following is a one-off operation to be done after the initial creation of the cluster. Any subsequent restoration should be done via backups.
- Create a password for the `root` user and store it in SSM Parameter Store as a secure string in the `${app-identifier}/database/root-password` parameter that was created as part of the rds module.
- Using the console in AWS, add the same password created in the previous step as the `master password` of the aurora cluster you have just created.
- In secrets manager, create a new secret using the same password from the steps above.
- Create passwords for the `forms-api` and `forms-admin` users and store in SSM Parameter Store as secure strings.
- Use the AWS Data API to connect to the database and initialise it:
    - First, copy the `forms-admin-api-prepare.sql` script into the Data API console and replace the place-holders with the passwords above.
    - Using the forms-cli data_api method, run this script to set the database up.
    - Check each statement is successful.

Each app is currently configured to run its database migrations when it starts. These migrations will create the necessary tables and indexes and no further manual setup should be required.

#### Forms-runner

The Forms-runner database has its own database and is setup in a separate RDS cluster to Forms-api and Forms-admin. The steps for its initial creation are the same as above, but using `forms-runner-prepare.sql`. Any subsequent restoration should be done via backups.

It is configured to run its database migration when it starts. This migration will create the necessary tables and indexes and no further manual setup should be required.