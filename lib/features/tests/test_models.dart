// Mental-health test models — mirror Android MentalTestData.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class TestQuestion {
  final String text;
  final List<String> options;
  final String emoji;
  final String textFusha;
  final List<String> optionsFusha;
  const TestQuestion(this.text, this.options,
      {this.emoji = '', this.textFusha = '', this.optionsFusha = const []});
}

class TestResultTier {
  final String title;
  final String titleFusha;
  final String details;
  final String detailsFusha;
  final List<String> traits;
  final List<String> traitsFusha;
  final List<String> strengths;
  final List<String> strengthsFusha;
  final List<String> weaknesses;
  final List<String> weaknessesFusha;
  final String imageAsset; // local asset name (hardcoded tests)
  final Uint8List? imageBytes; // base64-decoded (Firestore tests)
  final List<String> routine;
  final List<String> routineFusha;
  const TestResultTier({
    required this.title,
    this.titleFusha = '',
    required this.details,
    this.detailsFusha = '',
    this.traits = const [],
    this.traitsFusha = const [],
    this.strengths = const [],
    this.strengthsFusha = const [],
    this.weaknesses = const [],
    this.weaknessesFusha = const [],
    this.imageAsset = '',
    this.imageBytes,
    this.routine = const [],
    this.routineFusha = const [],
  });

  factory TestResultTier.fromFirestore(Map<String, dynamic> d) {
    Uint8List? bytes;
    final b64 = d['imageBase64'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      try {
        bytes = base64Decode(b64);
      } catch (_) {}
    }
    List<String> toList(dynamic v) {
      if (v is List) return v.cast<String>();
      if (v is String && v.isNotEmpty) return [v];
      return [];
    }
    return TestResultTier(
      title: (d['title'] as String?) ?? '',
      titleFusha: (d['title_fusha'] as String?) ?? '',
      details: (d['details'] as String?) ?? '',
      detailsFusha: (d['details_fusha'] as String?) ?? '',
      traits: toList(d['traits']),
      traitsFusha: toList(d['traits_fusha']),
      strengths: toList(d['strengths']),
      strengthsFusha: toList(d['strengths_fusha']),
      weaknesses: toList(d['weaknesses']),
      weaknessesFusha: toList(d['weaknesses_fusha']),
      imageBytes: bytes,
      routine: toList(d['routine']),
      routineFusha: toList(d['routine_fusha']),
    );
  }
}

class MentalTest {
  final String id;
  final String title;
  final String titleFusha;
  final String coverAsset; // local asset name (hardcoded tests)
  final Uint8List? coverBytes; // base64-decoded (Firestore tests)
  final String cardBgColor;
  final String cardTextColor;
  final String description;
  final String descriptionFusha;
  final String stripDescription;
  final List<TestQuestion> questions;
  final String outcome;
  final List<TestResultTier> resultTiers;
  final List<String> levelLabels;
  const MentalTest({
    required this.id,
    required this.title,
    this.titleFusha = '',
    required this.coverAsset,
    this.coverBytes,
    required this.cardBgColor,
    required this.cardTextColor,
    required this.description,
    this.descriptionFusha = '',
    this.stripDescription = '',
    required this.questions,
    this.outcome =
        'هذا التقييم يساعدكِ على استكشاف ذاتكِ بعمق وفهم مشاعركِ وسلوككِ بشكل أوضح، بدون أحكام، فقط لمحة لطيفة لمساعدتكِ على التطور.',
    required this.resultTiers,
    required this.levelLabels,
  });

  factory MentalTest.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    Uint8List? coverBytes;
    final cb64 = d['coverBase64'] as String?;
    if (cb64 != null && cb64.isNotEmpty) {
      try {
        coverBytes = base64Decode(cb64);
      } catch (_) {}
    }

    final tiersRaw = (d['tiers'] as List?) ?? [];
    final tiers = tiersRaw
        .map((t) => TestResultTier.fromFirestore(t as Map<String, dynamic>))
        .toList();

    final qsRaw = (d['questions'] as List?) ?? [];
    final questions = qsRaw.map((q) {
      final opts = ((q['options'] as List?) ?? [])
          .map((o) => (o['text'] as String?) ?? '')
          .toList();
      return TestQuestion(
        (q['text'] as String?) ?? '',
        opts,
        optionsFusha: opts,
      );
    }).toList();

    return MentalTest(
      id: doc.id,
      title: (d['title'] as String?) ?? '',
      titleFusha: (d['title_fusha'] as String?) ?? '',
      coverAsset: '',
      coverBytes: coverBytes,
      cardBgColor: (d['cardBgColor'] as String?) ?? '#C8956C',
      cardTextColor: (d['cardTextColor'] as String?) ?? '#FFFFFF',
      description: (d['description'] as String?) ?? '',
      descriptionFusha: (d['description_fusha'] as String?) ?? '',
      stripDescription: (d['stripDescription'] as String?) ?? '',
      questions: questions,
      outcome: (d['outcome'] as String?) ??
          'هذا التقييم يساعدكِ على استكشاف ذاتكِ بعمق وفهم مشاعركِ وسلوككِ بشكل أوضح، بدون أحكام، فقط لمحة لطيفة لمساعدتكِ على التطور.',
      resultTiers: tiers,
      levelLabels: (d['levelLabels'] as List?)?.cast<String>() ?? [],
    );
  }
}

// ── Firestore stream ──────────────────────────────────────────────────────────

Stream<List<MentalTest>> firestoreTestsStream() {
  return FirebaseFirestore.instance
      .collection('tests')
      .where('published', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(MentalTest.fromFirestore).toList());
}
