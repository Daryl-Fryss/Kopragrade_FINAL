import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Keeps content a readable width on big web screens, full width on phones.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 640});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// One messenger for the whole app, so a notification can be shown even right after a
/// screen was closed (for example "you are registered" on the way back to the sign-in screen).
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// The kinds of short notifications (SnackBars) the app shows.
enum NotificationKind { success, info, warning, error }

/// Shows a short notification anywhere in the app, without needing a BuildContext.
///
///     AppNotification.success('You are registered!');
///     AppNotification.warning('Your session has expired. Please sign in again.');
class AppNotification {
  const AppNotification._();

  static void show(
    String message, {
    NotificationKind kind = NotificationKind.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = appMessengerKey.currentState;
    if (messenger == null) return; // no screen to show it on (for example in a test)
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          backgroundColor: _background(kind),
          content: Row(
            children: [
              Icon(_icon(kind), color: KopraPalette.paper, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: KopraPalette.paper,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(String message) =>
      show(message, kind: NotificationKind.success);

  static void info(String message) =>
      show(message, kind: NotificationKind.info);

  static void warning(String message) => show(
        message,
        kind: NotificationKind.warning,
        duration: const Duration(seconds: 5),
      );

  static void error(String message) =>
      show(message, kind: NotificationKind.error);

  static Color _background(NotificationKind kind) => switch (kind) {
    NotificationKind.success => KopraPalette.leaf,
    NotificationKind.info => KopraPalette.ink,
    NotificationKind.warning => KopraPalette.amber,
    NotificationKind.error => KopraPalette.danger,
  };

  static IconData _icon(NotificationKind kind) => switch (kind) {
    NotificationKind.success => Icons.check_circle_outline,
    NotificationKind.info => Icons.info_outline,
    NotificationKind.warning => Icons.warning_amber_rounded,
    NotificationKind.error => Icons.error_outline,
  };
}

class GradeBadge extends StatelessWidget {
  const GradeBadge(this.grade, {super.key, this.large = false});
  final String grade;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(grade);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(gradeIcon(grade), color: color, size: large ? 22 : 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              grade,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: large ? 20 : 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper so every screen shows a photo the same way (with a fallback icon).
class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SizedBox(
              height: height,
              width: width,
              child: const Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (context, error, stack) => Container(
        height: height,
        width: width,
        color: KopraPalette.leafTint,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

/// Coconut cross-section drawn in Dart; no network or extra asset dependency.
class CopraArtwork extends StatelessWidget {
  const CopraArtwork({super.key, this.size = 132});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _CopraPainter()),
  );
}

class _CopraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 160);
    final leaf = Paint()..color = KopraPalette.leaf;
    final leafPath = Path()
      ..moveTo(72, 64)
      ..quadraticBezierTo(67, 12, 137, 20)
      ..quadraticBezierTo(122, 67, 72, 64)
      ..close();
    canvas.drawPath(leafPath, leaf);
    canvas.drawLine(
      const Offset(75, 61),
      const Offset(123, 30),
      Paint()
        ..color = KopraPalette.leafTint
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(30, 32),
      13,
      Paint()..color = KopraPalette.sunshine,
    );
    const outer = Rect.fromLTWH(24, 59, 116, 86);
    canvas.drawOval(outer, Paint()..color = KopraPalette.shell);
    canvas.drawOval(
      const Rect.fromLTWH(29, 56, 106, 74),
      Paint()..color = KopraPalette.flesh,
    );
    canvas.drawOval(
      const Rect.fromLTWH(44, 69, 76, 43),
      Paint()..color = KopraPalette.shell,
    );
    canvas.drawOval(
      const Rect.fromLTWH(49, 72, 66, 35),
      Paint()..color = KopraPalette.leafDark,
    );
    final fiber = Paint()
      ..color = KopraPalette.flesh.withAlpha(100)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 7; i++) {
      final x = 43.0 + i * 12;
      canvas.drawLine(Offset(x, 132), Offset(x + 3, 140), fiber);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CopraPainter oldDelegate) => false;
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CopraArtwork(size: 42),
          SizedBox(width: 8),
          Text('KopraGrade'),
        ],
      );
    }
    return Column(
      children: [
        const CopraArtwork(),
        const SizedBox(height: 12),
        Text('KopraGrade', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Copra drying quality classification',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: KopraPalette.muted),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle ?? '',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: KopraPalette.muted),
          ),
        ],
      ],
    ),
  );
}
