# KopraGrade — Flutter frontend redesign

A source-only redesign of your supplied frontend, using Flutter/Dart only.

## Updated screens
- Sign in and registration: custom coconut artwork, stronger heading hierarchy, cleaner forms, accessible password-toggle labels.
- Grading: coconut sample illustration, leaf-tinted image area, quality legend, clear scan/upload actions.
- History: clearer heading, bordered sample rows and wrapping grade metadata.
- Results: coordinated quality colors, confidence display, unframed recommendation and sample details.
- Profile: clearer account identity and personal-details sections.
- Camera: charcoal and leaf-green scanning colors; original capture/steadiness behavior retained.

## Palette
Leaf green #24634B; sunshine #F1CB58; clean ivory #F5F7F3;
charcoal green #223B32; amber #976700; review red #B44238.
All color tokens live in lib/core/theme.dart. Coconut artwork uses Flutter CustomPainter.
No new dependencies, generated photos, remote fonts, or placeholder records were added.

## Use in your existing Flutter project
1. Back up your current frontend.
2. Replace lib/core/theme.dart, lib/widgets/common.dart and lib/screens/ with these versions.
3. Keep your existing platform folders and API configuration.
4. Run flutter pub get, flutter analyze, flutter test, then flutter run.

The original archive did not contain Android, iOS or web platform folders.
This delivery therefore preserves its source-only structure, rather than pretending to be a complete platform project.

## Checks and limitations
- Dart parsing and formatting passed for all changed Dart files.
- Nine existing validation/image-signature and scanner-steadiness tests passed using a temporary Dart assertion adapter.
- Flutter-only platform detection tests, Flutter analysis/build, rendered screen checks, camera hardware and live account/grading calls remain unverified.
- Flutter SDK downloads were unavailable and pub.dev dependency retrieval failed in this environment.
- Services, models, providers, main.dart and non-UI core logic are unchanged.
