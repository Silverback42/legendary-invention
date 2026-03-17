import 'package:flutter/material.dart';

/// Animated shimmer skeleton for loading states.
///
/// Wraps any child with a moving gradient highlight.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const SkeletonShimmer({required this.child, super.key});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                (_ctrl.value - 0.3).clamp(0.0, 1.0),
                _ctrl.value,
                (_ctrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Rounded skeleton placeholder box.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    required this.width, required this.height, super.key,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Circular skeleton placeholder.
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton that mimics the dashboard layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 14),
            SizedBox(height: 16),
            // Spending card
            SkeletonBox(width: double.infinity, height: 120, borderRadius: 16),
            SizedBox(height: 12),
            // Chart card
            SkeletonBox(width: double.infinity, height: 200, borderRadius: 16),
            SizedBox(height: 12),
            // Two small cards
            Row(
              children: [
                Expanded(child: SkeletonBox(width: double.infinity, height: 100, borderRadius: 16)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(width: double.infinity, height: 100, borderRadius: 16)),
              ],
            ),
            SizedBox(height: 12),
            // Budget card
            SkeletonBox(width: double.infinity, height: 150, borderRadius: 16),
            SizedBox(height: 12),
            // Recent transactions
            SkeletonBox(width: 140, height: 14),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 200, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// Skeleton that mimics the history screen layout.
class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 100, borderRadius: 16),
            SizedBox(height: 16),
            SkeletonBox(width: 150, height: 14),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 200, borderRadius: 16),
            SizedBox(height: 16),
            SkeletonBox(width: double.infinity, height: 40),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 40),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 40),
          ],
        ),
      ),
    );
  }
}
