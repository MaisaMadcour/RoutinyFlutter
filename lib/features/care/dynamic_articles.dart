import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/lang_notifier.dart';
import '../../theme/app_colors.dart';

// Maps the short section key the admin app saves → the full title used in
// careSections so that articles from the admin always land in the right row.
const _adminKeyToTitle = <String, String>{
  'behavior': 'سلوكياتك ونفسيتك',
  'routine':  'استمري في روتينك',
  'day':      'يومك بيحكي',
  'grow':     'طوري ذاتك',
  'beauty':   'جمالك بدون تعقيد',
  'life':     'روتين وحياة',
  'other':    'اخرى',
};

// ─── Model ───────────────────────────────────────────────────────────────────

class DynamicArticle {
  final String id;
  final String section; // must match CareSectionDef.title
  final String titleMasri;
  final String titleFusha;
  final String contentMasri;
  final String contentFusha;
  final Uint8List? imageBytes;

  const DynamicArticle({
    required this.id,
    required this.section,
    required this.titleMasri,
    required this.titleFusha,
    required this.contentMasri,
    required this.contentFusha,
    this.imageBytes,
  });

  String get title {
    final lang = LangNotifier.instance.value;
    return lang == 'masri' ? titleMasri : titleFusha;
  }

  String get content {
    final lang = LangNotifier.instance.value;
    return lang == 'masri' ? contentMasri : contentFusha;
  }

  static DynamicArticle? fromDoc(DocumentSnapshot doc) {
    try {
      final d = doc.data() as Map<String, dynamic>;
      Uint8List? bytes;
      final b64 = d['imageBase64'] as String?;
      if (b64 != null && b64.isNotEmpty) {
        bytes = base64Decode(b64);
      }
      final rawSection = (d['section'] as String?) ?? '';
      return DynamicArticle(
        id: doc.id,
        section: _adminKeyToTitle[rawSection] ?? rawSection,
        titleMasri: (d['title_masri'] as String?) ?? (d['title'] as String?) ?? '',
        titleFusha: (d['title_fusha'] as String?) ?? (d['title'] as String?) ?? '',
        contentMasri: (d['content_masri'] as String?) ?? (d['content'] as String?) ?? '',
        contentFusha: (d['content_fusha'] as String?) ?? (d['content'] as String?) ?? '',
        imageBytes: bytes,
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Stream ───────────────────────────────────────────────────────────────────

/// Streams admin-authored articles from Firestore, newest first.
/// Drafts (published == false) are hidden.
Stream<List<DynamicArticle>> dynamicArticlesStream() {
  return FirebaseFirestore.instance
      .collection('articles')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .where((d) => d.data()['published'] != false)
          .map(DynamicArticle.fromDoc)
          .whereType<DynamicArticle>()
          .toList());
}

// ─── Article screen ───────────────────────────────────────────────────────────

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
    final pageBg = Color.lerp(accent, Colors.white, 0.88)!;
    final headingColor = Color.lerp(accent, Colors.black, 0.35)!;

    return Scaffold(
      backgroundColor: pageBg,
      body: CustomScrollView(
        slivers: [
          // ── Cover image ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: accent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: article.imageBytes != null
                  ? Image.memory(
                      article.imageBytes!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: accent,
                      child: const Icon(Icons.article,
                          size: 80, color: Colors.white38),
                    ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
              child: ValueListenableBuilder<String>(
                valueListenable: LangNotifier.instance,
                builder: (_, __, ___) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      article.title,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: headingColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // content paragraphs
                    ...article.content
                        .split('\n')
                        .where((p) => p.trim().isNotEmpty)
                        .map(
                          (para) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(
                              para.trim(),
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 15,
                                height: 1.75,
                                color: AppColors.deepChocolate,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
