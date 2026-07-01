import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Samples the uniform background colour of test cover images by averaging
/// the four corner pixels — a 1:1 port of the Android `TestColorUtils`.
/// All test images share one flat background colour, so the corner sample
/// is exact (palette extraction was inaccurate; this is not).
class ImagePalette {
  ImagePalette._();

  static final Map<String, Color> _cache = {};

  /// Average of the four corner pixels of [assetPath].
  /// Returns [fallback] while loading or on failure; result is cached.
  static Future<Color> from(
    String assetPath, {
    Color fallback = const Color(0xFFF5E6DD),
  }) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath]!;
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 120, // small for speed; corners stay representative
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return fallback;

      final w = image.width;
      final h = image.height;
      if (w < 4 || h < 4) return fallback;

      final pixels = byteData.buffer.asUint8List();
      final corners = [
        _pixel(pixels, w, 2, 2),
        _pixel(pixels, w, w - 3, 2),
        _pixel(pixels, w, 2, h - 3),
        _pixel(pixels, w, w - 3, h - 3),
      ];
      var r = 0, g = 0, b = 0;
      for (final c in corners) {
        r += c.$1;
        g += c.$2;
        b += c.$3;
      }
      final color = Color.fromARGB(
        255,
        (r / corners.length).round(),
        (g / corners.length).round(),
        (b / corners.length).round(),
      );
      _cache[assetPath] = color;
      image.dispose();
      return color;
    } catch (_) {
      return fallback;
    }
  }

  static (int, int, int) _pixel(Uint8List px, int width, int x, int y) {
    final i = (y * width + x) * 4;
    return (px[i], px[i + 1], px[i + 2]);
  }

  static Color? cached(String assetPath) => _cache[assetPath];

  /// Same corner-pixel extraction but from raw bytes (e.g. base64-decoded
  /// Firestore images). Not cached — bytes are transient.
  static Future<Color> fromBytes(
    Uint8List bytes, {
    Color fallback = const Color(0xFFF5E6DD),
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 120);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return fallback;
      final w = image.width;
      final h = image.height;
      if (w < 4 || h < 4) return fallback;
      final pixels = byteData.buffer.asUint8List();
      final corners = [
        _pixel(pixels, w, 2, 2),
        _pixel(pixels, w, w - 3, 2),
        _pixel(pixels, w, 2, h - 3),
        _pixel(pixels, w, w - 3, h - 3),
      ];
      var r = 0, g = 0, b = 0;
      for (final c in corners) {
        r += c.$1;
        g += c.$2;
        b += c.$3;
      }
      image.dispose();
      return Color.fromARGB(
        255,
        (r / corners.length).round(),
        (g / corners.length).round(),
        (b / corners.length).round(),
      );
    } catch (_) {
      return fallback;
    }
  }

  /// Mix [color] toward white. factor 0 = same, 1 = white. (Android `lighten`)
  static Color lighten(Color color, double factor) {
    final f = factor.clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (color.r * 255 + (255 - color.r * 255) * f).round(),
      (color.g * 255 + (255 - color.g * 255) * f).round(),
      (color.b * 255 + (255 - color.b * 255) * f).round(),
    );
  }

  /// Mix [color] toward black. factor 0 = same, 1 = black. (Android `darken`)
  static Color darken(Color color, double factor) {
    final f = factor.clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (color.r * 255 * (1 - f)).round(),
      (color.g * 255 * (1 - f)).round(),
      (color.b * 255 * (1 - f)).round(),
    );
  }

  /// Luminance-based dark check (Android `isColorDark`, threshold 0.6).
  static bool isDark(Color c) {
    final lum =
        (0.299 * c.r * 255 + 0.587 * c.g * 255 + 0.114 * c.b * 255) / 255;
    return lum < 0.6;
  }
}
