# GOV.UK Forms Development

This is a guide to getting the Gov.uk Forms development environment up and running.

list of github projects.

This repo lives at:
https://github.com/alphagov/forms-deploy

The components which make up the service are:
https://github.com/alphagov/forms-runner
https://github.com/alphagov/forms-api
https://github.com/alphagov/forms-admin

## How it works
Each of the components above has a Dockerfile in its repo which is used to build
a docker image. The `docker-compose.yml` defines the configuration for using
those images to run GOVUK Forms locally including a Postgres and Redis
container.

The local repo for each component is mounted into its corresponding container,
for example the local directory `../forms-api` is mounted into the forms-api
container under the `/app` directory so that any changes made to that
component's code locally is immediately apparent in the locally running
services.

### Setting up the databases
There is a single postgres container defined within the docker-compose setup
which is configured with two databases named `forms-admin` and `forms-api`. The two
databases are initially created using the the `local/postgres/initdb.d` which is
mounted into the postgres container's 'docker-entrypoint-initdb.d' directory.
The start command for `forms-admin` is modified by the docker-compose.yml file
to include running `rails db:setup` and `rails db:seed` which will run
migrations and prepare a local dev user respectively.

If you need to connect to the postgres instance directly you can use `psql -h
localhost -p 5432 -U postgres` and enter `postgres` for the password when
prompted. To view available databases use `\l` and to connect to one use 
`\c databasename`. For more information view psql help page.

## Commands for running the whole thing in docker.

You need to check out all three projects in the parent directory of this repo.
Your directory structure should look like this:

```
top-level/
├── forms-admin
├── forms-api
└── forms-runner
└── forms-deploy
    └── local
        ├── README.md
        └── docker-compose.yml
```

Then run:
```bash
docker-compose up
```

Wait a while as the images are downloaded and built. Eventually you should see
the screen fill with logging information as the postgres, redis and the forms
services start.

You should be able to open the admin interface on http://localhost:3000 , and
the runner on http://localhost:3001

To stop the services from running, press `Ctrl-c` and then enter:
```bash
docker-compose stop
```

If you make changes to the docker file:

```bash
docker-compose up --build
```
