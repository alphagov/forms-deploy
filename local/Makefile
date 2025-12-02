#.PHONY: setup serve test test-watch lint db db-down

help:
	@echo "Usage:"
	@echo "make all		- run the whole Docker Compose stack"
	@echo "make admin		- run everything BUT the admin"
	@echo "make runner		- run everything BUT the runner"
	@echo "make product-page	- run everything BUT the product-page"
	@echo "make db			- run just postgres"
	@echo "make logs		- show Docker Compose logs"
	@echo "make ps			- show Docker Compose processses"
	@echo "make down		- run Docker Compose down (useful for chaining)"
	@echo "make reset		- remove all Docker Compose volumes and containers"

all:
	docker compose up -d
admin:
	docker compose up -d redis postgres runner product-page
runner:
	docker compose up -d redis postgres admin product-page
product-page:
	docker compose up -d redis postgres runner admin
db:
	docker compose up -d postgres
logs:
	docker compose logs -f
ps:
	docker compose ps
down:
	docker compose down
reset:
	docker compose down --volumes
