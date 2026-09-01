set shell := ["bash", "-uc"]

ci-lint:
  zizmor .

ci-lint-fix:
  zizmor . --fix=all

ci-update:
  pinact run -min-age 7 -update

lint-ec:
  ecformat check -v
