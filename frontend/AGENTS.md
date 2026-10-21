# Frontend architecture
- Keep this delivery in Flutter/Dart; the native source is the requested deliverable, not a converted web frontend.
- Define colors and Material control themes in lib/core/theme.dart so all screens share semantic styling.
- Keep reusable branding and visual primitives in lib/widgets/common.dart to avoid per-screen duplication.
- Preserve services, Riverpod controllers, API contracts and role-based navigation when adjusting presentation.
- Draw the coconut branding with CustomPainter to keep the UI independent of network assets and additional packages.
