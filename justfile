set shell := ["bash", "-uc"]

ci-lint:
	zizmor .

ci-lint-fix:
  zizmor . --fix=all

ci-update:
	PINACT_MIN_AGE=7 pinact run
