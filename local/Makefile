#.PHONY: setup serve test test-watch lint db db-down

help:
	@echo "Usage:"
	@echo "make clean  - run docker-compose down (useful for chaining)"
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
	API_BASE=http://host.docker.internal:9292 docker-compose up -d redis postgres forms-runner forms-admin
runner:
	docker-compose up -d redis postgres forms-admin forms-api
ps:
	docker-compose ps
logs:
	docker-compose logs -f
reset:
	docker-compose down --volumes
