import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/image_palette.dart';
import '../../theme/app_colors.dart';

/// Shows a preview of a 9:16 (story-size) result card and lets the user share
/// it as an image to Snap/Instagram/WhatsApp — a free viral-growth loop.
///
/// Pass [coverAsset] for test results (shows the cover image), or [emoji] for
/// the reflection result (shows a big mood emoji instead of an image).
Future<void> showShareResultSheet(
  BuildContext context, {
  required String headline, // small line above the result, e.g. نتيجتي في "..."
  required String resultTitle,
  required String details,
  required Color edge,
  required String shareText,
  String coverAsset = '',
  String emoji = '',
}) async {
  final cardKey = GlobalKey();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('شاركي نتيجتك 📸',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 4),
            const Text('انشريها في الستوري وخلّي صحابك يجرّبوا 🌸',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    color: AppColors.secondaryText)),
            const SizedBox(height: 14),
            // scaled preview; the boundary still renders at full logical size
            SizedBox(
              height: 460,
              child: FittedBox(
                child: RepaintBoundary(
                  key: cardKey,
                  child: _StoryCard(
                    headline: headline,
                    resultTitle: resultTitle,
                    details: details,
                    coverAsset: coverAsset,
                    emoji: emoji,
                    edge: edge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _captureAndShare(cardKey, shareText),
              child: Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ImagePalette.darken(edge, 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('مشاركة في الستوري',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _captureAndShare(GlobalKey key, String text) async {
  try {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.7); // 400×711 → 1080×1920
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/routiny_result.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path)], text: text);
  } catch (_) {
    await Share.share(text); // fallback to plain text
  }
}

/// The shareable 9:16 card. Logical size 400×711 (captured ×2.7 → ~1080×1920).
class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.headline,
    required this.resultTitle,
    required this.details,
    required this.coverAsset,
    required this.emoji,
    required this.edge,
  });

  final String headline;
  final String resultTitle;
  final String details;
  final String coverAsset;
  final String emoji;
  final Color edge;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF3E2818);
    const body = Color(0xFF5C4A3E);
    const muted = Color(0xFF8E7366);
    final accent = ImagePalette.darken(edge, 0.08);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 400,
        height: 711,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ImagePalette.lighten(edge, 0.55),
              ImagePalette.lighten(edge, 0.82),
            ],
          ),
        ),
        child: Column(
          children: [
            // ── brand ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('روتيني',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ink)),
                SizedBox(width: 6),
                Text('🌸', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 2),
            const Text('اختبري نفسك واكتشفيها',
                style:
                    TextStyle(fontFamily: 'Raleway', fontSize: 13, color: muted)),
            const Spacer(),

            // ── result ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 18,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // cover image (full, uncropped) OR a big mood emoji
                  if (coverAsset.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset('assets/images/$coverAsset.jpg',
                          width: double.infinity, fit: BoxFit.fitWidth),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ImagePalette.lighten(edge, 0.55),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(emoji.isEmpty ? '🌸' : emoji,
                          style: const TextStyle(fontSize: 92)),
                    ),
                  const SizedBox(height: 14),
                  Text(headline,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Raleway', fontSize: 13, color: muted)),
                  const SizedBox(height: 6),
                  Text(resultTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: accent)),
                  const SizedBox(height: 8),
                  Text(details,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          height: 1.5,
                          color: body)),
                ],
              ),
            ),
            const Spacer(),

            // ── download CTA (link, no QR) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('حمّلي روتيني 📲',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: ink)),
                  SizedBox(height: 6),
                  Text('متاح الآن على Google Play',
                      style: TextStyle(
                          fontFamily: 'Raleway', fontSize: 13, color: muted)),
                  SizedBox(height: 8),
                  Text('play.google.com/store/apps/details?id=com.routiny.app',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7745F))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
