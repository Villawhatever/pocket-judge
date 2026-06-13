import '../utils/extensions/json_extensions.dart';

class ErratumModel {
  final String name;
  final String set;
  final String? oldText;
  final String? newText;
  final List<FaqModel>? faqs;

  const ErratumModel({
    required this.name,
    required this.set,
    this.oldText,
    this.newText,
    this.faqs,
  });

  factory ErratumModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? faqs = json.tryGet('faqs');

    return ErratumModel(
      name: json.tryGet('name'),
      oldText: json.tryGet('oldText'),
      newText: json.tryGet('newText'),
      set: json.tryGet('set'),
      faqs: faqs
          ?.map((f) => FaqModel.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['set'] = set;
    data['oldText'] = oldText;
    data['newText'] = newText;
    data['faq'] = faqs;
    return data;
  }

  @override
  String toString() => name;
}

class FaqModel {
  final String? question;
  final String? answer;

  const FaqModel({required this.question, required this.answer});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      question: json.tryGet('question') ?? '',
      answer: json.tryGet('answer') ?? '',
    );
  }
}
