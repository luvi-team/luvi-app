.PHONY: analyze test flutter-version

analyze:
	@scripts/flutter_codex.sh analyze

test:
	@scripts/flutter_codex.sh test -j 1

flutter-version:
	@scripts/flutter_codex.sh --version

.PHONY: format format-apply fix

format:
	@echo "Checking formatting (no changes applied)..."
	@scripts/flutter_codex.sh dart format --output=none --set-exit-if-changed .

format-apply:
	@echo "Applying formatting..."
	@scripts/flutter_codex.sh dart format .

fix:
	@scripts/flutter_codex.sh dart fix --apply
