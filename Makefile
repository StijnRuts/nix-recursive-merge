default: test

.PHONY: test

format:
	treefmt .
test:
	nix eval .#tests
hash:
	@echo "url = \"https://raw.githubusercontent.com/StijnRuts/nix-recursive-merge/$$(git rev-parse HEAD)/recursive.nix\";"
	@echo "sha256 = \"sha256:$$(nix-prefetch-url https://raw.githubusercontent.com/StijnRuts/nix-recursive-merge/refs/heads/main/recursive.nix 2>/dev/null)\";"
