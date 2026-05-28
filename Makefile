include .env
export

PROJECT_ROOT := $(shell pwd)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Error: parameter 'seq' is required. Example: make migrate-create seq=init"; \
		exit 1; \
	fi
	docker compose run --rm todoapp_postgres_migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"
	@sudo chown -R $(shell id -u):$(shell id -g) migrations/

migrate-up:
	@$(MAKE) migrate-action action=up

migrate-down:
	@$(MAKE) migrate-action action=down extra=$(count)

migrate-version:
	@$(MAKE) migrate-action action=version

migrate-force:
	@$(MAKE) migrate-action action=force extra=$(version)

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Error: parameter 'action' is required. Example: make migrate-action action=up"; \
		exit 1; \
	fi
	docker compose run --rm todoapp_postgres_migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}?sslmode=disable" \
		$(action) $(extra)
