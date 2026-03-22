import '../extensions/json_extensions.dart';

class CardModel {
  final String id;
  final String name;
  final int collectorNumber;
  final int? energy;
  final int? power;
  final int? might;
  final List<String>? domain;
  final String cardType;
  final String rarity;
  final String cardSet;
  final String imageUrl;
  final String? ability;
  final String? errataText;
  final String? errataOldText;

  const CardModel({
    required this.id,
    required this.name,
    required this.collectorNumber,
    this.energy,
    this.power,
    this.might,
    this.domain,
    required this.cardType,
    required this.rarity,
    required this.cardSet,
    required this.imageUrl,
    required this.ability,
    this.errataText,
    this.errataOldText,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? domains = json.tryGet('domain');

    return CardModel(
      id: json.tryGet('id'),
      name: json.tryGet('name'),
      collectorNumber: json.tryGet('collector_number'),
      energy: json.tryGet('energy'),
      power: json.tryGet('power'),
      might: json.tryGet('might'),
      domain: domains?.map((d) => d.toString()).toList(),
      cardType: json.tryGet('card_type'),
      rarity: json.tryGet('rarity'),
      cardSet: json.tryGet('card_set'),
      imageUrl: json.tryGet('image_url'),
      ability: json.tryGet('ability'),
      errataText: json.tryGet('errata_text'),
      errataOldText: json.tryGet('errata_old_text'),
    );
  }

  @override
  String toString() {
    return name;
  }
}
