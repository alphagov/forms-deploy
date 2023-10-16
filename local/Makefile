#.PHONY: setup serve test test-watch lint db db-down

help:
	@echo "Usage:"
	@echo "make clean  - run docker-compose down (useful for chaining)"
	@echo "make all    - run the whole docker-compose stack" 
	@echo "make db     - run just postgres"
	@echo "make admin  - run everything BUT the admin"
	@echo "make api    - run everything BUT the API"
	@echo "make runner - run everything BUT the runner"
	@echo "make ps     - show docker-compose processses"
	@echo "make logs   - show docker-compose logs"
	@echo "make reset  - remove all docker-compose volumes and containers"

db:
	docker-compose up -d postgres
down:
	docker-compose down
all:
	docker-compose up -d
admin:
	docker-compose up -d redis postgres forms-runner forms-api
api:
	SETTINGS__FORMS_API__BASE_URL=http://host.docker.internal:9292 docker-compose up -d redis postgres forms-runner forms-admin
runner:
	docker-compose up -d redis postgres forms-admin forms-api
ps:
	docker-compose ps
logs:
	docker-compose logs -f
reset:
	docker-compose down --volumes

bundle-all: bundle-forms-api setup-forms-admin setup-forms-runner

bundle-%:
	docker-compose build $*
	docker-compose run --no-deps $* bundle config unset --local without
	docker-compose run --no-deps $* bundle

setup-all: setup-forms-api setup-forms-admin setup-forms-runner

setup-forms-runner: bundle-forms-runner
	docker-compose run forms-runner bin/setup

setup-%: bundle-%
	docker-compose run $* bin/setup
	docker-compose run $* env RAILS_ENV=test bin/rails db:create
