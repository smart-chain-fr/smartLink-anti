ifndef LIGO
LIGO=docker run --platform linux/amd64 --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.43.0
endif

JSON_OPT=--michelson-format json

help: ## show help
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## install dependencies
	@echo "Installing dependencies..."
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@if [ ! -f ./scripts/metadata.json ]; then cp scripts/metadata.json.dist \
        scripts/metadata.json ; fi
	@npm i

compile: ## compile contracts
	@echo "Running compilation script..."
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@$(LIGO) compile contract src/anti.mligo -o compiled/anti.tz
	@$(LIGO) compile contract src/anti.mligo $(JSON_OPT) -o compiled/anti.json

test: test_ligo  ## run integration tests

test_ligo: test/main.mligo
	@echo "Running integration tests..." 
	@$(LIGO) run test $^

deploy: ## deploy
	@echo "Running deployment script..."
	@npx ts-node ./scripts/deploy.ts

sandbox-start: ## start sandbox
	@./scripts/run-sandbox

sandbox-stop: ## stop sandbox
	@docker stop sandbox
