.PHONY: lint validate check bootstrap

bootstrap:
	./scripts/bootstrap.sh

lint:
	./scripts/lint.sh

validate:
	./scripts/validate.sh

check: lint validate
