.PHONY: up
up:
	@sh ./scripts/setup.sh

.PHONY: down
down:
	@kind delete cluster --name jyablonski-cluster