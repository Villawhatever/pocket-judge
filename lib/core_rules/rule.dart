class RuleModel {
  final String number;
  final String text;

  const RuleModel({required this.number, required this.text});

  factory RuleModel.fromJson(Map<String, dynamic> json) {
    return RuleModel(
        number: json['ruleNumber'] as String, text: json['text'] as String);
  }
}
