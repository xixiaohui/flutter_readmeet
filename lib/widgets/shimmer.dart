import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

/// Shimmer loading placeholder with animated gradient sweep.
class Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const Shimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 12,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final gradient = LinearGradient(
          begin: Alignment(-1.5 + _controller.value * 3.0, 0),
          end: Alignment(-0.5 + _controller.value * 3.0, 0),
          colors: const [
            Color(0xFFE8E8E8),
            Color(0xFFF5F5F5),
            Color(0xFFE8E8E8),
          ],
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

/// Shimmer skeleton for hero carousel placeholder.
class ShimmerHero extends StatelessWidget {
  final double height;
  const ShimmerHero({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppColors.surfaceTile1,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(color: AppColors.onDark, radius: 14),
            const SizedBox(height: 16),
            Shimmer(width: 280, height: 24, radius: 6),
            const SizedBox(height: 12),
            Shimmer(width: 160, height: 16, radius: 6),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a single grid card.
class ShimmerGridCard extends StatelessWidget {
  const ShimmerGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Shimmer(height: 120, radius: 12),
        const SizedBox(height: 10),
        const Shimmer(height: 16, width: double.infinity, radius: 6),
        const SizedBox(height: 6),
        const Shimmer(height: 12, width: 100, radius: 6),
      ],
    );
  }
}

/// Shimmer skeleton for a single horizontal card.
class ShimmerHorizontalCard extends StatelessWidget {
  const ShimmerHorizontalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Shimmer(width: 160, height: 140, radius: 12),
          const SizedBox(height: 8),
          const Shimmer(width: 140, height: 14, radius: 6),
          const SizedBox(height: 6),
          Row(
            children: [
              const Shimmer(width: 28, height: 28, radius: 14),
              const SizedBox(width: 8),
              const Shimmer(width: 80, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
