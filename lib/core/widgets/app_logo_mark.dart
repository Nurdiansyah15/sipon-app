import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "IKHLAS" brand mark: a circle containing three stacked colored dots.
/// There is no image asset for this in sipon-ui — it's built purely from
/// shapes there (see AppNavbar.vue / HeroBanner.vue), so it's recreated here
/// as a widget instead of an image.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    super.key,
    this.size = 40,
    this.filled = false,
  });

  final double size;

  /// `true` renders a solid white circle (as used on the hero banner);
  /// `false` renders an outlined circle on a transparent/surface background
  /// (as used in the app bar).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.14;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.transparent,
        border: filled
            ? null
            : Border.all(color: AppColors.primary, width: size * 0.05),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(dotSize, AppColors.logoDotYellow),
            SizedBox(height: dotSize * 0.4),
            _Dot(dotSize, AppColors.logoDotTeal),
            SizedBox(height: dotSize * 0.4),
            _Dot(dotSize, AppColors.logoDotGreen),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
