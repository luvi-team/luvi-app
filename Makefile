.PHONY: analyze test flutter-version

analyze:
	@echo "Running Flutter analysis..."
	@scripts/flutter_codex.sh analyze

test:
	@echo "Running tests (sequential)..."
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

.PHONY: privacy-gate
privacy-gate:
	@echo "Running privacy gate check..."
	@scripts/flutter_codex.sh dart run tools/validate_assets_no_drafts.dart
