ifndef LIGO
LIGO=docker run --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:next
endif

json=--michelson-format json
tsc=npx tsc

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## install dependencies
	@if [ ! -f ./.env ]; then cp .env.dist .env ; fi
	@if [ ! -f ./scripts/metadata.json ]; then cp scripts/metadata.json.dist \
        scripts/metadata.json ; fi
	@npm i

compile: ## compile contracts
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@$(LIGO) compile contract src/anti.mligo -o compiled/anti.tz
	@$(LIGO) compile contract src/anti.mligo $(json) -o compiled/anti.json

deploy: ## deploy
	@npx ts-node ./scripts/deploy.ts

sandbox-start: ## start sandbox
	@./scripts/run-sandbox

sandbox-stop: ## stop sandbox
	@docker stop sandbox
