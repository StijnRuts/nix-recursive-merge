default: test

.PHONY: test

format:
	treefmt .
test:
	nix eval .#tests
hash:
	@echo "url = \"https://raw.githubusercontent.com/StijnRuts/nix-wrench/$$(git rev-parse HEAD)/wrench.nix\";"
	@echo "sha256 = \"sha256:$$(nix-prefetch-url https://raw.githubusercontent.com/StijnRuts/nix-wrench/$$(git rev-parse HEAD)/wrench.nix 2>/dev/null)\";"
