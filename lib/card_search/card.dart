import '../utils/extensions/json_extensions.dart';

class CardModel {
  const CardModel(
      {required this.id,
      required this.name,
      required this.collectorNumber,
      this.realName,
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
      this.images});

  final String id;
  final String name;
  final int collectorNumber;
  final String? realName;
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
  final List<ImageData>? images;

  factory CardModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? domains = json.tryGet('domain');
    List<ImageData> imageList = [];
    imageList.add(
        ImageData(id: json.tryGet('id'), imgUrl: json.tryGet('image_url')));

    return CardModel(
        id: json.tryGet('id'),
        name: json.tryGet('name'),
        collectorNumber: json.tryGet('collector_number'),
        energy: json.tryGet('energy'),
        power: json.tryGet('power'),
        might: json.tryGet('might'),
        domain: domains?.map((d) => d.toString()).toList(),
        cardType: json.tryGet('card_type'),
        realName: json.tryGet('real_name'),
        rarity: json.tryGet('rarity'),
        cardSet: json.tryGet('card_set'),
        imageUrl: json.tryGet('image_url'),
        ability: json.tryGet('ability'),
        errataText: json.tryGet('errata_text'),
        errataOldText: json.tryGet('errata_old_text'),
        images: imageList);
  }

  @override
  String toString() {
    return name;
  }
}

class ImageData {
  ImageData({required this.id, required this.imgUrl});

  final String id;
  final String imgUrl;
}
