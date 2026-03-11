.PHONY: lint validate check bootstrap run-device run-sdl

bootstrap:
	./scripts/bootstrap.sh

lint:
	./scripts/lint.sh

validate:
	./scripts/validate.sh

check: lint validate

run-device:
	.venv/bin/esphome run esphome/dashboard_device.yaml

run-sdl:
	.venv/bin/esphome run esphome/dashboard_sdl.yaml
