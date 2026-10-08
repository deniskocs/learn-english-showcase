import '../../../model/word_definition.dart';

/// Ответ от сервера со списком активных слов пользователя
/// Активные слова - это слова, которые находятся в процессе изучения
class GetActiveWordsResponse {
  /// Список определений активных слов
  /// Каждое определение содержит информацию о слове, его переводе, прогрессе изучения и следующей дате повторения
  final List<WordDefinitionDTO> definitions;

  /// Общее количество страниц с активными словами
  /// Используется для пагинации при отображении списка слов
  final int pagesCount;

  GetActiveWordsResponse({
    required this.definitions,
    required this.pagesCount,
  });

  factory GetActiveWordsResponse.fromJson(Map<String, dynamic> json) {
    final definitions = json['definitions'] as List<dynamic>;
    return GetActiveWordsResponse(
      definitions: definitions.map((e) => WordDefinitionDTO.fromJson(e)).toList(),
      pagesCount: json['pagesCount'] as int,
    );
  }
}
