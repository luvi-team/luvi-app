# Git-Report (heute, Branch: feat/welcome-setup)

## Commits (heute)
- 58b682a — Wed Sep 10 23:00:50 2025 — feat: add Welcome screen setup with theme tokens and tests
- 4523703 — Wed Sep 10 19:27:07 2025 — fix(welcome-01): enable theme; map headlineMedium to Playfair 32/40; update test for custom widgets
- b633f88 — Wed Sep 10 18:53:59 2025 — fix(welcome): make wave full-width and cache-reset for filter removal
- 78f447a — Wed Sep 10 18:50:14 2025 — chore: fix lints after router+svg
- 2ae33e5 — Wed Sep 10 18:48:26 2025 — chore(svg): remove filter block; drop shadow provided via BoxShadow in code
- 5170f12 — Wed Sep 10 18:47:55 2025 — feat(router): wire consent routes and start at /consent/w1 (temp for dev)
- a20ea5f — Wed Sep 10 18:45:51 2025 — chore(router): add go_router and remove analyzer suppression
- 6af7d78 — Wed Sep 10 18:43:35 2025 — chore: fix lints for welcome_01
- c18743b — Wed Sep 10 18:41:37 2025 — feat(consent): Welcome_01 screen + shell (hero contain, wave exact) + route + widget test [ADR-0001|0003]
- 9e64474 — Wed Sep 10 18:32:12 2025 — chore(pubspec): register consent assets folder + add flutter_svg
- b8365b7 — Wed Sep 10 18:30:28 2025 — chore(pubspec): register consent asset directory under flutter assets
- 792f7c2 — Wed Sep 10 18:25:31 2025 — chore(assets): scaffold consent asset folders (1x/2x/3x) + keepers
- c7d0a57 — Wed Sep 10 17:54:55 2025 — chore(figma): unify fileKey for MCP (Dev Mode) [ADR-0001]
- b632096 — Wed Sep 10 17:12:36 2025 — Reorganize agent documentation with numbered prefixes
- b1b9e70 — Wed Sep 10 16:37:52 2025 — Reset: remove Welcome sprint (screens/routes/tokens/tests). Keep theme scaffold, assets, CI golden scaffold, Figma tooling.
## Diff-Statistik (heute vs. Stand 00:00)
 assets/fonts/Figtree/.gitkeep                      |    0
 assets/fonts/Figtree/Figtree-Bold.ttf              | 2132 ++++++++++++++++++++
 assets/fonts/Figtree/Figtree-Regular.ttf           | 2132 ++++++++++++++++++++
 assets/fonts/Inter/.gitkeep                        |    0
 assets/fonts/Inter/Inter-Medium.ttf                | 2132 ++++++++++++++++++++
 assets/fonts/PlayfairDisplay/.gitkeep              |    0
 .../PlayfairDisplay/PlayfairDisplay-Regular.ttf    | 2132 ++++++++++++++++++++
 assets/images/consent/.gitkeep                     |    0
 assets/images/consent/2.0x/.gitkeep                |    0
 assets/images/consent/2.0x/welcome_01.png          |  Bin 0 -> 1469330 bytes
 assets/images/consent/3.0x/.gitkeep                |    0
 assets/images/consent/3.0x/welcome_01.png          |  Bin 0 -> 3039663 bytes
 assets/images/consent/welcome_01.png               |  Bin 0 -> 398217 bytes
 assets/images/consent/welcome_wave.svg             |   17 +
 .../agents/{ui-frontend.md => 01-ui-frontend.md}   |    0
 .../agents/{api-backend.md => 02-api-backend.md}   |    0
 context/agents/{db-admin.md => 03-db-admin.md}     |    0
 context/agents/{dataviz.md => 04-dataviz.md}       |    0
 context/agents/{qa-dsgvo.md => 05-qa-dsgvo.md}     |    0
 context/refs/figma_nodes_m4.backup.json            |    8 +
 context/refs/figma_nodes_m4.json                   |    8 +
 lib/core/design_tokens/README.md                   |   13 +
 lib/core/design_tokens/sizes.dart                  |    6 +
 lib/core/design_tokens/spacing.dart                |    8 +
 lib/core/design_tokens/typography.dart             |   22 +
 lib/core/theme/app_theme.dart                      |   94 +
 lib/features/consent/routes.dart                   |   14 +
 .../consent/screens/consent_welcome_01_screen.dart |   47 +
 lib/features/consent/widgets/dots_indicator.dart   |   36 +
 lib/features/consent/widgets/welcome_shell.dart    |   92 +
 lib/main.dart                                      |  103 +-
 macos/Runner.xcodeproj/project.pbxproj             |   98 +-
 macos/Runner.xcworkspace/contents.xcworkspacedata  |    3 +
 pubspec.lock                                       |   74 +-
 pubspec.yaml                                       |   19 +
 .../consent/consent_welcome_01_screen_test.dart    |   38 +
 test/features/consent/dots_indicator_test.dart     |   20 +
 test/features/consent/welcome_shell_test.dart      |   28 +
 38 files changed, 9179 insertions(+), 97 deletions(-)

## Geänderte Dateien (heute)
- assets/fonts/Figtree/.gitkeep
- assets/fonts/Figtree/Figtree-Bold.ttf
- assets/fonts/Figtree/Figtree-Regular.ttf
- assets/fonts/Inter/.gitkeep
- assets/fonts/Inter/Inter-Medium.ttf
- assets/fonts/PlayfairDisplay/.gitkeep
- assets/fonts/PlayfairDisplay/PlayfairDisplay-Regular.ttf
- assets/images/consent/.gitkeep
- assets/images/consent/2.0x/.gitkeep
- assets/images/consent/2.0x/welcome_01.png
- assets/images/consent/3.0x/.gitkeep
- assets/images/consent/3.0x/welcome_01.png
- assets/images/consent/welcome_01.png
- assets/images/consent/welcome_wave.svg
- context/agents/01-ui-frontend.md
- context/agents/02-api-backend.md
- context/agents/03-db-admin.md
- context/agents/04-dataviz.md
- context/agents/05-qa-dsgvo.md
- context/refs/figma_nodes_m4.backup.json
- context/refs/figma_nodes_m4.json
- lib/core/design_tokens/README.md
- lib/core/design_tokens/sizes.dart
- lib/core/design_tokens/spacing.dart
- lib/core/design_tokens/typography.dart
- lib/core/theme/app_theme.dart
- lib/features/consent/routes.dart
- lib/features/consent/screens/consent_welcome_01_screen.dart
- lib/features/consent/widgets/dots_indicator.dart
- lib/features/consent/widgets/welcome_shell.dart
- lib/main.dart
- macos/Runner.xcodeproj/project.pbxproj
- macos/Runner.xcworkspace/contents.xcworkspacedata
- pubspec.lock
- pubspec.yaml
- test/features/consent/consent_welcome_01_screen_test.dart
- test/features/consent/dots_indicator_test.dart
- test/features/consent/welcome_shell_test.dart

## Top-Dateien nach Änderungsumfang (heute)
- +2132 ~0 assets/fonts/PlayfairDisplay/PlayfairDisplay-Regular.ttf
- +2132 ~0 assets/fonts/Inter/Inter-Medium.ttf
- +2132 ~0 assets/fonts/Figtree/Figtree-Regular.ttf
- +2132 ~0 assets/fonts/Figtree/Figtree-Bold.ttf
- +97 ~1 macos/Runner.xcodeproj/project.pbxproj
- +94 ~0 lib/core/theme/app_theme.dart
- +92 ~0 lib/features/consent/widgets/welcome_shell.dart
- +69 ~5 pubspec.lock
- +47 ~0 lib/features/consent/screens/consent_welcome_01_screen.dart
- +38 ~0 test/features/consent/consent_welcome_01_screen_test.dart
- +36 ~0 lib/features/consent/widgets/dots_indicator.dart
- +28 ~0 test/features/consent/welcome_shell_test.dart
- +22 ~0 lib/core/design_tokens/typography.dart
- +20 ~0 test/features/consent/dots_indicator_test.dart
- +19 ~0 pubspec.yaml
- +17 ~0 assets/images/consent/welcome_wave.svg
- +14 ~0 lib/features/consent/routes.dart
- +13 ~0 lib/core/design_tokens/README.md
- +12 ~91 lib/main.dart
- +8 ~0 lib/core/design_tokens/spacing.dart
- +8 ~0 context/refs/figma_nodes_m4.json
- +8 ~0 context/refs/figma_nodes_m4.backup.json
- +6 ~0 lib/core/design_tokens/sizes.dart
- +3 ~0 macos/Runner.xcworkspace/contents.xcworkspacedata
- +0 ~0 context/agents/{ui-frontend.md
- +0 ~0 context/agents/{qa-dsgvo.md
- +0 ~0 context/agents/{db-admin.md
- +0 ~0 context/agents/{dataviz.md
- +0 ~0 context/agents/{api-backend.md
- +0 ~0 assets/images/consent/3.0x/.gitkeep
- +0 ~0 assets/images/consent/2.0x/.gitkeep
- +0 ~0 assets/images/consent/.gitkeep
- +0 ~0 assets/fonts/PlayfairDisplay/.gitkeep
- +0 ~0 assets/fonts/Inter/.gitkeep
- +0 ~0 assets/fonts/Figtree/.gitkeep
- +- ~- assets/images/consent/welcome_01.png
- +- ~- assets/images/consent/3.0x/welcome_01.png
- +- ~- assets/images/consent/2.0x/welcome_01.png
