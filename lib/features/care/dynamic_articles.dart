import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../theme/app_colors.dart';

/// An article authored in the admin app and stored in Firestore.
/// Bilingual (masri/fusha); resolves to the user's current language with a
/// graceful fallback to the other language.
class DynamicArticle {
  DynamicArticle({
    required this.id,
    required this.section,
    required this.title,
    required this.content,
    required this.imageBytes,
  });

  final String id;
  final String section;
  final String title;
  final String content;
  final Uint8List? imageBytes;

  static String _pick(Map<String, dynamic> m, String masriKey, String fushaKey) {
    final masri = (m[masriKey] ?? '').toString().trim();
    final fusha = (m[fushaKey] ?? '').toString().trim();
    if (S.isFusha) return fusha.isNotEmpty ? fusha : masri;
    return masri.isNotEmpty ? masri : fusha;
  }

  static DynamicArticle? fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final title = _pick(m, 'title_masri', 'title_fusha');
    final content = _pick(m, 'content_masri', 'content_fusha');
    if (title.isEmpty && content.isEmpty) return null;
    Uint8List? img;
    final b64 = (m['imageBase64'] ?? '').toString();
    if (b64.isNotEmpty) {
      try {
        img = base64Decode(b64);
      } catch (_) {}
    }
    return DynamicArticle(
      id: d.id,
      section: (m['section'] ?? '').toString(),
      title: title,
      content: content,
      imageBytes: img,
    );
  }
}

/// Streams admin-authored articles from Firestore, newest first.
Stream<List<DynamicArticle>> dynamicArticlesStream() {
  return FirebaseFirestore.instance
      .collection('articles')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map(DynamicArticle.fromDoc).whereType<DynamicArticle>().toList());
}

/// A horizontal strip of the latest admin articles, shown above the built-in
/// care sections. Renders nothing while loading, on error, or when empty — so
/// the care page is completely unaffected if Firestore is unreachable.
class DynamicArticlesSection extends StatelessWidget {
  const DynamicArticlesSection({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DynamicArticle>>(
      stream: dynamicArticlesStream(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final articles = snap.data!;
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDD5C8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16,
                          color: AppColors.deepChocolate),
                      SizedBox(width: 8),
                      Text('جديد ✨',
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepChocolate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _card(context, articles[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, DynamicArticle a) {
    const w = 280.0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DynamicArticleScreen(article: a, accent: accent)),
      ),
      child: SizedBox(
        width: w,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: a.imageBytes != null
                  ? Image.memory(a.imageBytes!,
                      width: w, height: 230, fit: BoxFit.cover)
                  : Container(
                      width: w,
                      height: 230,
                      color: accent.withValues(alpha: 0.3),
                      alignment: Alignment.center,
                      child: const Icon(Icons.spa,
                          size: 48, color: Colors.white)),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  a.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen view of a dynamic (admin-authored) article.
class DynamicArticleScreen extends StatelessWidget {
  const DynamicArticleScreen({
    super.key,
    required this.article,
    required this.accent,
  });

  final DynamicArticle article;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: article.imageBytes != null ? 260 : 90,
            pinned: true,
            backgroundColor: accent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: article.imageBytes != null
                ? FlexibleSpaceBar(
                    background: Image.memory(article.imageBytes!,
                        fit: BoxFit.cover))
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    article.title,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 25,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3D2817)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.content,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        height: 1.7,
                        color: AppColors.deepChocolate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
