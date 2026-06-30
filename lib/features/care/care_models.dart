// Care feature models.

class CareCardDef {
  final String title;
  final String imageAsset; // drawable name, e.g. care_behavior_procrastination
  final String articleKey; // key into careArticles
  final String titleFusha;
  const CareCardDef(this.title, this.imageAsset, this.articleKey,
      {this.titleFusha = ''});
}

class CareSectionDef {
  final String title;
  final List<CareCardDef> cards;
  final double cardW;
  final double cardH;
  final String titleFusha;
  const CareSectionDef(this.title, this.cards, this.cardW, this.cardH,
      {this.titleFusha = ''});
}

class CareArticleSection {
  final String heading;
  final String body;
  final String headingFusha;
  final String bodyFusha;
  const CareArticleSection(this.heading, this.body,
      {this.headingFusha = '', this.bodyFusha = ''});
}

class CareArticle {
  final String intro;
  final List<CareArticleSection> sections;
  final String introFusha;
  const CareArticle(this.intro, this.sections, {this.introFusha = ''});
}
