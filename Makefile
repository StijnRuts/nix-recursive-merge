default: test

.PHONY: test

format:
	treefmt .
test:
	nix eval .#tests
