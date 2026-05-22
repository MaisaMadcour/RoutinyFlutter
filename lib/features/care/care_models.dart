// Care feature models.

class CareCardDef {
  final String title;
  final String imageAsset; // drawable name, e.g. care_behavior_procrastination
  final String articleKey; // key into careArticles
  const CareCardDef(this.title, this.imageAsset, this.articleKey);
}

class CareSectionDef {
  final String title;
  final List<CareCardDef> cards;
  final double cardW;
  final double cardH;
  const CareSectionDef(this.title, this.cards, this.cardW, this.cardH);
}

class CareArticleSection {
  final String heading;
  final String body;
  const CareArticleSection(this.heading, this.body);
}

class CareArticle {
  final String intro;
  final List<CareArticleSection> sections;
  const CareArticle(this.intro, this.sections);
}
