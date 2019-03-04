SHELL := /bin/bash

default: run-beers

run:
	source .custom.env; docker-compose -f docker-compose.yml up -d

log:
	source .custom.env; docker-compose -f docker-compose.yml logs -f

clean: 
	source .custom.env; docker-compose -f docker-compose.yml stop && docker-compose -f docker-compose.yml rm -f && docker volume prune -f

run-beers: run
	source .custom.env; docker-compose -f docker-compose.beers.yml up -d

log-beers:
	source .custom.env; docker-compose -f docker-compose.yml -f docker-compose.beers.yml logs -f

clean-beers: clean
	source .custom.env; docker-compose -f docker-compose.beers.yml stop && docker-compose -f docker-compose.beers.yml rm -f && docker volume prune -f

run-token_exchange: run
	source .custom.env; docker-compose -f docker-compose.token_exchange.yml up -d

log-token_exchange:
	source .custom.env; docker-compose -f docker-compose.yml -f docker-compose.token_exchange.yml logs -f

clean-token_exchange: clean
	source .custom.env; docker-compose -f docker-compose.token_exchange.yml stop && docker-compose -f docker-compose.token_exchange.yml rm -f && docker system prune -f

run-all: run-beers run-token_exchange

log-all:
	source .custom.env; docker-compose -f docker-compose.yml -f docker-compose.beers.yml -f docker-compose.token_exchange.yml logs -f

clean-all: clean-beers clean-token_exchange
