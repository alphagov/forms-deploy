#.PHONY: setup serve test test-watch lint db db-down

help:
	@echo "Usage:"
	@echo "make all		- run the whole docker-compose stack"
	@echo "make admin		- run everything BUT the admin"
	@echo "make runner		- run everything BUT the runner"
	@echo "make product-page	- run everything BUT the product-page"
	@echo "make db			- run just postgres"
	@echo "make logs		- show docker-compose logs"
	@echo "make ps			- show docker-compose processses"
	@echo "make down		- run docker-compose down (useful for chaining)"
	@echo "make reset		- remove all docker-compose volumes and containers"

all:
	docker-compose up -d
admin:
	docker-compose up -d redis postgres forms-runner forms-product-page
runner:
	docker-compose up -d redis postgres forms-admin forms-product-page
product-page:
	docker-compose up -d redis postgres forms-runner forms-admin
db:
	docker-compose up -d postgres
logs:
	docker-compose logs -f
ps:
	docker-compose ps
down:
	docker-compose down
reset:
	docker-compose down --volumes
