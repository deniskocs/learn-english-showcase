class WordDefinitionDTO {
  String word;
  String translation;
  int? meaningId;
  int? progress;
  String? nextReview;

  WordDefinitionDTO({
    required this.word,
    required this.translation,
    this.meaningId,
    this.progress,
    this.nextReview,
  });

  factory WordDefinitionDTO.fromJson(dynamic json1) {
    var json = json1 as Map<String, dynamic>;
    return WordDefinitionDTO(
      word: json['word'],
      translation: json['translation'],
      meaningId: json['meaningId'],
      progress: json['progress'],
      nextReview: json['nextReview'],
    );
  }
}
