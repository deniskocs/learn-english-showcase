enum QuizType {
  meaningToEnglish("meaning-to-english"),
  englishToRussian("english-to-russian"),
  russianToEnglish("russian-to-english");

  final String lessonName;

  const QuizType(this.lessonName);
}
