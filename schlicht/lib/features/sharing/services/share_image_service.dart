import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../shared/widgets/category_donut_chart.dart';

/// Daten fuer das Share-Bild.
class ShareData {
  final List<CategoryChartData> chartData;
  final int year;
  final int month;
  final String locale; // 'de' oder 'en'

  const ShareData({
    required this.chartData,
    required this.year,
    required this.month,
    required this.locale,
  });
}

/// Format-Optionen fuer das Share-Bild.
enum ShareFormat {
  story, // 9:16 (1080×1920)
  square, // 1:1 (1080×1080)
}

/// Rendert ein Flutter-Widget offscreen zu PNG und teilt es via Share-Sheet.
class ShareImageService {
  ShareImageService._();

  /// Rendert das [widget] offscreen zu einem PNG-Bild.
  ///
  /// [size] bestimmt die Pixel-Groesse des Bildes.
  static Future<XFile> _renderToImage(Widget widget, Size size) async {
    final repaintBoundary = RenderRepaintBoundary();

    // Pipeline: Widget → RenderObject → Bild
    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.implicitView!,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(size),
        devicePixelRatio: 1.0,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: widget,
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    // Aufraumen
    buildOwner.finalizeTree();

    final bytes = byteData!.buffer.asUint8List();

    // Temp-Datei speichern
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'schlicht_share.png'));
    await file.writeAsBytes(bytes);

    return XFile(file.path, mimeType: 'image/png');
  }

  /// Generiert ein Share-Bild im Story-Format (9:16).
  static Future<XFile> generateStoryImage(Widget widget) {
    return _renderToImage(widget, const Size(1080, 1920));
  }

  /// Generiert ein Share-Bild im Quadrat-Format (1:1).
  static Future<XFile> generateSquareImage(Widget widget) {
    return _renderToImage(widget, const Size(1080, 1080));
  }

  /// Teilt das generierte Bild ueber das System-Share-Sheet.
  static Future<void> shareImage(XFile file) async {
    await SharePlus.instance.share(ShareParams(files: [file]));
  }
}
