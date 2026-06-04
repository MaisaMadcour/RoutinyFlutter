import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/ads/interstitial_manager.dart';
import '../../core/image_palette.dart';
import '../../theme/app_colors.dart';
import 'care_data.dart';
import 'care_models.dart';

class CareArticleScreen extends StatefulWidget {
  const CareArticleScreen({
    super.key,
    required this.card,
    required this.accent,
    this.related = const [],
    this.cardAspect = 1.0,
  });

  final CareCardDef card;
  final Color accent;
  final List<CareCardDef> related;
  final double cardAspect;

  @override
  State<CareArticleScreen> createState() => _CareArticleScreenState();
}

class _CareArticleScreenState extends State<CareArticleScreen> {
  final ScrollController _scroll = ScrollController();
  double _offset = 0;
  double? _imgAspect; // width / height of the cover image

  late Color _edge;

  CareCardDef get card => widget.card;
  Color get accent => widget.accent;
  List<CareCardDef> get related => widget.related;

  Color get _pageBg        => ImagePalette.lighten(_edge, 0.86);
  Color get _headingBg     => ImagePalette.lighten(_edge, 0.55);
  Color get _headingAccent => ImagePalette.darken(_edge, 0.20);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (mounted) setState(() => _offset = _scroll.offset);
    });
    // resolve the cover image's natural aspect ratio so it shows in full
    AssetImage('assets/images/${widget.card.imageAsset}.jpg')
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, _) {
      if (mounted) {
        setState(() =>
            _imgAspect = info.image.width / info.image.height);
      }
    }));
    _edge = Color.lerp(widget.accent, Colors.white, 0.2)!;
    ImagePalette.from(
      'assets/images/${widget.card.imageAsset}.jpg',
      fallback: _edge,
    ).then((c) { if (mounted) setState(() => _edge = c); });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = careArticleFor(card.articleKey);
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top;
    // full image: height follows the natural aspect, capped so portrait
    // images stay reasonable (the cap letterboxes via BoxFit.contain)
    final imageHeight = _imgAspect == null
        ? 300.0
        : (mq.size.width / _imgAspect!).clamp(180.0, mq.size.height * 0.6);

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          // ── scrolling content — slides UNDER the image ───────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.only(top: imageHeight),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _pageBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
                  child: Column(
                    children: [
                      Text(card.title,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 26,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3D2817))),
                      const SizedBox(height: 18),
                      Text(article.intro,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 18,
                              height: 1.5,
                              color: AppColors.deepChocolate)),
                      for (final s in article.sections) ...[
                        const SizedBox(height: 22),
                        _sectionHeading(s.heading),
                        const SizedBox(height: 12),
                        Text(s.body,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 17,
                                height: 1.6,
                                color: AppColors.deepChocolate)),
                      ],
                      if (related.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        // related heading + share button on the same row
                        Row(
                          children: [
                            _sectionHeading('مقالات ذات صلة'),
                            const Spacer(),
                            _shareButton(article),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _relatedList(),
                      ] else ...[
                        const SizedBox(height: 24),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _shareButton(article),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── rounded image header with scroll parallax ────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // moves up at ~40% of the scroll speed → parallax; stretches a
            // little when the user over-scrolls (pulls down past the top).
            child: Transform.translate(
              offset: Offset(0, -_offset * 0.4),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
                child: Container(
                  color: _pageBg,
                  height: _offset < 0
                      ? imageHeight - _offset // stretch on over-scroll
                      : imageHeight,
                  width: double.infinity,
                  // contain → the whole image with all its details is shown
                  child: Image.asset(
                    'assets/images/${card.imageAsset}.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ── back button — no background, reversed arrow ──────────────────
          Positioned(
            top: topInset + 8,
            right: 16,
            child: GestureDetector(
              onTap: _closeWithAd,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(color: Color(0x80000000), blurRadius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── related cards — sized to the image aspect so nothing is cropped ─────────
  Widget _relatedList() {
    const h = 180.0;
    final w = (h * widget.cardAspect).clamp(150.0, 300.0);
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        clipBehavior: Clip.none,
        itemCount: related.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final r = related[i];
          return GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CareArticleScreen(
                  card: r,
                  accent: accent,
                  cardAspect: widget.cardAspect,
                  related: related
                      .where((c) => c.articleKey != r.articleKey)
                      .toList(),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/${r.imageAsset}.jpg',
                width: w,
                height: h,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── shared section heading — light shade of the image colour ────────────────
  Widget _sectionHeading(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _headingBg,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          right: BorderSide(color: _headingAccent, width: 3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 14, color: _headingAccent),
          const SizedBox(width: 8),
          Text(
            text,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate),
          ),
        ],
      ),
    );
  }

  Widget _shareButton(CareArticle article) {
    return GestureDetector(
      onTap: () => _share(article),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _headingBg,
          shape: BoxShape.circle,
          border: Border.all(color: _headingAccent, width: 1.5),
        ),
        child: Icon(Icons.share, size: 18, color: _headingAccent),
      ),
    );
  }

  void _share(CareArticle article) {
    final text = '${card.title}\n\n${article.intro}\n\n— من تطبيق Routiny 🤍';
    Share.share(text, subject: card.title);
  }

  // interstitial on article close (cap 3 min), then pop
  void _closeWithAd() {
    InterstitialManager.instance.showIfReady(
      InterstitialManager.ctxArticleClose,
      onDone: () {
        if (mounted) Navigator.pop(context);
      },
    );
  }
}
