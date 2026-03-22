import '../extensions/json_extensions.dart';

class RuleModel {
  final String number;
  final String text;

  const RuleModel({required this.number, required this.text});

  factory RuleModel.fromJson(Map<String, dynamic> json) {
    return RuleModel(
      number: json.tryGet('ruleNumber'),
      text: json.tryGet('text'),
    );
  }

  @override
  String toString() {
    return '$number: $text';
  }
}
