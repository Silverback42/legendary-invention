import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/category_donut_chart.dart';
import '../services/share_image_service.dart';

/// Visuelles Layout des Share-Bildes.
///
/// Zeigt Kategorie-Verteilung in Prozent (keine Betraege!),
/// Monats-Header und Schlicht-Branding.
class ShareImageWidget extends StatelessWidget {
  final ShareData data;
  final ShareFormat format;

  const ShareImageWidget({
    super.key,
    required this.data,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return format == ShareFormat.story
        ? _StoryLayout(data: data)
        : _SquareLayout(data: data);
  }
}

// --- Farben (konsistent mit AppTheme) ---
const _bgColor = Color(0xFFFFFFFF);
const _primaryColor = Color(0xFF1A1A2E);
const _subtleColor = Color(0xFF8A8AA8);
const _surfaceColor = Color(0xFFFAFAFA);

/// 9:16 Story-Layout (1080×1920)
class _StoryLayout extends StatelessWidget {
  final ShareData data;
  const _StoryLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 80),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Monats-Header
          _MonthHeader(data: data, fontSize: 42),
          const SizedBox(height: 16),
          Text(
            'Schlicht',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _subtleColor,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(flex: 1),
          // Donut-Chart
          _ShareDonutChart(data: data, size: 340),
          const SizedBox(height: 56),
          // Legende
          _CategoryLegend(data: data, fontSize: 28),
          const Spacer(flex: 2),
          // Branding-Footer
          const _BrandingFooter(fontSize: 20),
        ],
      ),
    );
  }
}

/// 1:1 Quadrat-Layout (1080×1080)
class _SquareLayout extends StatelessWidget {
  final ShareData data;
  const _SquareLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.all(56),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Monats-Header
          _MonthHeader(data: data, fontSize: 36),
          const SizedBox(height: 8),
          Text(
            'Schlicht',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _subtleColor,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(flex: 1),
          // Chart + Legende nebeneinander
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _ShareDonutChart(data: data, size: 280),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 4,
                child: _CategoryLegend(data: data, fontSize: 24),
              ),
            ],
          ),
          const Spacer(flex: 1),
          // Branding-Footer
          const _BrandingFooter(fontSize: 18),
        ],
      ),
    );
  }
}

// --- Shared Components ---

class _MonthHeader extends StatelessWidget {
  final ShareData data;
  final double fontSize;

  const _MonthHeader({required this.data, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final locale = data.locale == 'de' ? 'de_DE' : 'en_US';
    final date = DateTime(data.year, data.month);
    final label = DateFormat.yMMMM(locale).format(date);

    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: _primaryColor,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _ShareDonutChart extends StatelessWidget {
  final ShareData data;
  final double size;

  const _ShareDonutChart({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(data: data.chartData),
      ),
    );
  }
}

/// Zeichnet einen einfachen Donut-Chart ohne fl_chart-Abhaengigkeit.
/// (fl_chart braucht einen BuildContext mit MediaQuery, was offscreen
/// nicht zuverlaessig funktioniert — daher Custom Paint.)
class _DonutPainter extends CustomPainter {
  final List<CategoryChartData> data;
  _DonutPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.35;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -math.pi / 2; // 12 Uhr

    for (final item in data) {
      final sweepAngle = (item.percentage / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      // Prozent-Label in der Mitte des Segments
      if (item.percentage >= 5) {
        final labelAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius - strokeWidth / 2;
        final labelCenter = Offset(
          center.dx + labelRadius * math.cos(labelAngle),
          center.dy + labelRadius * math.sin(labelAngle),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${item.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: strokeWidth * 0.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            labelCenter.dx - textPainter.width / 2,
            labelCenter.dy - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.data != data;
}

class _CategoryLegend extends StatelessWidget {
  final ShareData data;
  final double fontSize;

  const _CategoryLegend({required this.data, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in data.chartData)
          Padding(
            padding: EdgeInsets.symmetric(vertical: fontSize * 0.25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: fontSize * 0.6,
                  height: fontSize * 0.6,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: fontSize * 0.4),
                Flexible(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: _primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: fontSize * 0.3),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BrandingFooter extends StatelessWidget {
  final double fontSize;
  const _BrandingFooter({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: _surfaceColor,
          margin: EdgeInsets.only(bottom: fontSize * 0.8),
        ),
        Text(
          'Schlicht – Budgeting, plain and simple.',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: _subtleColor,
          ),
        ),
      ],
    );
  }
}
