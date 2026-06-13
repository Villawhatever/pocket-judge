import 'package:isar_community/isar.dart';

import '../utils/hashing.dart';

part 'card.g.dart';

@embedded
class ImageData {
  ImageData({this.id, this.imgUrl});

  final String? id;
  final String? imgUrl;
}

@collection
class CardModel {
  late Id isarId;
  @Index(unique: true)
  late String id;
  late String name;
  String? riftboundId;
  String? tcgplayerId;
  int? collectorNumber;
  Attributes attributes = Attributes();
  Classification classification = Classification();
  Text text = Text();
  Set set = Set();
  Media media = Media();
  List<String>? tags;
  String? orientation;
  Metadata metadata = Metadata();
  List<ImageData>? images;
  String? mightBonus;

  CardModel({
    required this.id,
    required this.name,
    this.riftboundId,
    this.tcgplayerId,
    this.collectorNumber,
    required this.attributes,
    required this.classification,
    required this.text,
    required this.set,
    required this.media,
    this.tags,
    this.orientation,
    required this.metadata,
    this.mightBonus,
  });

  CardModel.fromJson(Map<String, dynamic> json) {
    List<ImageData> imageList = [];

    id = json['id'];
    isarId = fastHash(id);
    name = json['name'].replaceAllMapped(RegExp(r'\s\(.+'), (match) {
      return '';
    });
    riftboundId = json['riftbound_id'];
    tcgplayerId = json['tcgplayer_id'];
    collectorNumber = json['collector_number'];
    attributes = Attributes.fromJson(json['attributes']);
    classification = Classification.fromJson(json['classification']);
    text = Text.fromJson(json['text']);
    set = Set.fromJson(json['set']);
    media = Media.fromJson(json['media']);
    tags = json['tags'].cast<String>();
    orientation = json['orientation'];
    metadata = Metadata.fromJson(json['metadata']);
    mightBonus = json['might_bonus'];

    imageList.add(ImageData(id: riftboundId, imgUrl: media.imageUrl));
    images = imageList;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['riftbound_id'] = riftboundId;
    data['tcgplayer_id'] = tcgplayerId;
    data['collector_number'] = collectorNumber;
    data['attributes'] = attributes.toJson();
    data['classification'] = classification.toJson();
    data['text'] = text.toJson();
    data['set'] = set.toJson();
    data['media'] = media.toJson();
    data['tags'] = tags;
    data['orientation'] = orientation;
    data['metadata'] = metadata.toJson();
    data['might_bonus'] = mightBonus;
    return data;
  }

  @override
  String toString() => name;
}

@embedded
class Attributes {
  int? energy;
  int? might;
  int? power;

  Attributes({this.energy, this.might, this.power});

  Attributes.fromJson(Map<String, dynamic> json) {
    energy = json['energy'];
    might = json['might'];
    power = json['power'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['energy'] = energy;
    data['might'] = might;
    data['power'] = power;
    return data;
  }
}

@embedded
class Classification {
  String? type;
  String? supertype;
  String? rarity;
  List<String>? domain;

  Classification({this.type, this.supertype, this.rarity, this.domain});

  Classification.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    supertype = json['supertype'];
    rarity = json['rarity'];
    domain = json['domain'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['supertype'] = supertype;
    data['rarity'] = rarity;
    data['domain'] = domain;
    return data;
  }
}

@embedded
class Text {
  String? rich;
  String? plain;
  String? effect;
  String? flavour;

  Text({this.rich, this.plain, this.effect, this.flavour});

  Text.fromJson(Map<String, dynamic> json) {
    var richText = json['rich'] as String;
    richText = richText.replaceAll('<br />', '\n');
    richText = richText.replaceAll(RegExp(r'<.+?>'), '');
    richText = richText.replaceAll('&quot;', '"');
    rich = richText;
    plain = json['plain'];
    effect = json['effect'];
    flavour = json['flavour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rich'] = rich;
    data['plain'] = plain;
    data['effect'] = effect;
    data['flavour'] = flavour;
    return data;
  }
}

@embedded
class Set {
  String? setId;
  String? label;

  Set({this.setId, this.label});

  Set.fromJson(Map<String, dynamic> json) {
    setId = json['set_id'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['set_id'] = setId;
    data['label'] = label;
    return data;
  }
}

@embedded
class Media {
  String? imageUrl;
  String? artist;
  String? accessibilityText;

  Media({this.imageUrl, this.artist, this.accessibilityText});

  Media.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
    artist = json['artist'];
    accessibilityText = json['accessibility_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_url'] = imageUrl;
    data['artist'] = artist;
    data['accessibility_text'] = accessibilityText;
    return data;
  }
}

@embedded
class Metadata {
  String? cleanName;
  String? updatedOn;
  bool? alternateArt;
  bool? overnumbered;
  bool? signature;

  Metadata({
    this.cleanName,
    this.updatedOn,
    this.alternateArt,
    this.overnumbered,
    this.signature,
  });

  Metadata.fromJson(Map<String, dynamic> json) {
    cleanName = json['clean_name'];
    updatedOn = json['updated_on'];
    alternateArt = json['alternate_art'];
    overnumbered = json['overnumbered'];
    signature = json['signature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clean_name'] = cleanName;
    data['updated_on'] = updatedOn;
    data['alternate_art'] = alternateArt;
    data['overnumbered'] = overnumbered;
    data['signature'] = signature;
    return data;
  }
}
