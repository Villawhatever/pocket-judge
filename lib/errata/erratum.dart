class ErratumModel {
  final String name;
  final String set;
  final String? oldText;
  final String? newText;
  final List<FaqModel>? faqs;

  const ErratumModel(
      {required this.name,
      required this.set,
      this.oldText,
      this.newText,
      this.faqs});

  factory ErratumModel.fromJson(Map<String, dynamic> json) {
    var faqs = json['faqs'] != null ? json['faqs'] as List<dynamic> : null;

    return ErratumModel(
        name: json['name'] as String,
        oldText: json['oldText'] != null ? json['oldText'] as String : null,
        newText: json['newText'] != null ? json['newText'] as String : null,
        set: json['set'] as String,
        faqs: faqs
            ?.map((f) => FaqModel.fromJson(f as Map<String, dynamic>))
            .toList());
  }
}

class FaqModel {
  final String question;
  final String answer;

  const FaqModel({required this.question, required this.answer});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
        question: json['question'] as String, answer: json['answer'] as String);
  }
}
