// Mental-health test models — mirror Android MentalTestData.

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
  final String details;
  final List<String> traits;
  final List<String> strengths;
  final List<String> weaknesses;
  final String imageAsset; // e.g. ei_result_high
  final List<String> routine;
  const TestResultTier({
    required this.title,
    required this.details,
    this.traits = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.imageAsset = '',
    this.routine = const [],
  });
}

class MentalTest {
  final String id;
  final String title;
  final String coverAsset; // e.g. cover_adhd
  final String cardBgColor;
  final String cardTextColor;
  final String description;
  final List<TestQuestion> questions;
  final String outcome;
  final List<TestResultTier> resultTiers;
  final List<String> levelLabels;
  final String titleFusha;
  final String descriptionFusha;
  const MentalTest({
    required this.id,
    required this.title,
    required this.coverAsset,
    required this.cardBgColor,
    required this.cardTextColor,
    required this.description,
    required this.questions,
    this.outcome =
        'هذا التقييم يساعدكِ على استكشاف ذاتكِ بعمق وفهم مشاعركِ وسلوككِ بشكل أوضح، بدون أحكام، فقط لمحة لطيفة لمساعدتكِ على التطور.',
    required this.resultTiers,
    required this.levelLabels,
    this.titleFusha = '',
    this.descriptionFusha = '',
  });
}
