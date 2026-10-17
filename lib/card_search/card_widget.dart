import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pasteboard/pasteboard.dart';

import '../constants.dart';
import '../utils/extensions/context_extensions.dart';
import '../utils/formatting.dart';
import '../widgets/expansible_header.dart';
import 'card.dart' hide Text;

class CardWidget extends StatefulWidget {
  const CardWidget({
    super.key,
    required this.model,
    required this.expansibleController,
  });

  final CardModel model;
  final ExpansibleController expansibleController;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  late final ExpansibleController _expansibleController;
  final _carouselSliderController = CarouselSliderController();
  int _currentImage = 0;

  Future copyImage(String imgUrl) async {
    try {
      final imageFile = await DefaultCacheManager().getSingleFile(imgUrl);

      final Uint8List imageBytes = await imageFile.readAsBytes();

      await Pasteboard.writeImage(imageBytes);
    } catch (e) {
      dev.log('$e', level: 3);
    }
  }

  void _handleUnreleasedLegality() {
    if (widget.model.set.setId == "RAD" &&
        DateTime.now().isBefore(DateTime.parse("2026-10-23"))) {
      widget.model.legalities.constructed_2v2 = "not_legal";
      widget.model.legalities.constructed = "not_legal";
    }
  }

  @override
  initState() {
    _expansibleController = widget.expansibleController;
    super.initState();
    _handleUnreleasedLegality();
  }

  Widget _buildCardInfo(String title, dynamic value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (value is Widget)
            value
          else
            Text(_stringify(value), style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _stringify(dynamic input) {
    if (input is List<String>) {
      return input.join(', ');
    } else {
      return input.toString();
    }
  }

  String _toNormalCase(String str) {
    return str
        .split('_')
        .map((word) {
          if (word.isEmpty) {
            return '';
          }
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    var relevantText = widget.model.text.rich ?? '';

    var prettifiedAbility = formatCardText(relevantText, context);
    List<InlineSpan> prettifiedEffect = [];
    if (widget.model.text.effect?.isNotEmpty ?? false) {
      prettifiedEffect = formatCardText(widget.model.text.effect!, context);
    }

    final copiableCardText =
        '${relevantText.isNotEmpty ? '**Ability**\n$relevantText' : ''}'
        '${prettifiedEffect.isNotEmpty ? '\n\n**Effect**\n${widget.model.text.effect}' : ''}';

    List<GestureDetector> getImages() {
      if (widget.model.images?.isEmpty ?? true) {
        return [];
      }
      final imageData = widget.model.images!;
      final List<GestureDetector> images = [];

      for (final image in imageData) {
        images.add(
          GestureDetector(
            onLongPress: () {
              copyImage(image.imgUrl!);
              HapticFeedback.vibrate();
            },
            child: CachedNetworkImage(
              imageUrl: image.imgUrl!,
              placeholder: (context, url) => CircularProgressIndicator(
                constraints: BoxConstraints(
                  maxHeight: 100,
                  minHeight: 100,
                  minWidth: 100,
                  maxWidth: 100,
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error, size: 45),
            ),
          ),
        );
      }
      return images;
    }

    List<Widget> buildCarousel() {
      if (widget.model.images?.isEmpty ?? true) {
        return [];
      }

      if (widget.model.images?.length == 1) {
        var img = getImages().first;
        return [
          Padding(
            padding: EdgeInsetsGeometry.only(top: 12),
            child: Center(child: img),
          ),
        ];
      }

      return [
        Padding(
          padding: EdgeInsetsGeometry.only(top: 12),
          child: CarouselSlider(
            items: getImages(),
            carouselController: _carouselSliderController,
            options: CarouselOptions(
              height: 400,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImage = index;
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getImages().asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselSliderController.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (_currentImage == entry.key
                              ? context.colorScheme.secondary
                              : context.colorScheme.primary)
                          .withValues(
                            alpha: _currentImage == entry.key ? 1.0 : 0.5,
                          ),
                ),
              ),
            );
          }).toList(),
        ),
      ];
    }

    Color getLegalityColor(String legality) {
      return switch (legality) {
        'legal' => greenish,
        'banned' => reddish,
        _ => context.colorScheme.primary,
      };
    }

    return Expansible(
      headerBuilder: (context, animation) => ExpansibleHeader(
        title: widget.model.name,
        context: context,
        animation: animation,
        hasErrata: widget.model.hasErrata,
        legalities: widget.model.legalities,
        expansibleController: _expansibleController,
      ),
      bodyBuilder: (context, animation) {
        return Padding(
          padding: EdgeInsetsGeometry.only(left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...buildCarousel(),
              Table(
                children: [
                  TableRow(
                    children: [
                      _buildCardInfo(
                        'Domain(s)',
                        widget.model.classification.domain?.join(', '),
                        context,
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildCardInfo(
                        'Card Type',
                        widget.model.classification.type,
                        context,
                      ),
                      widget.model.classification.type
                                  ?.map((t) => t.toLowerCase())
                                  .contains('unit') ??
                              false
                          ? _buildCardInfo(
                              'Might',
                              widget.model.attributes.might,
                              context,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  TableRow(
                    children: [
                      widget.model.attributes.energy == null
                          ? SizedBox.shrink()
                          : _buildCardInfo(
                              'Energy',
                              widget.model.attributes.energy,
                              context,
                            ),
                      widget.model.attributes.power == null
                          ? SizedBox.shrink()
                          : _buildCardInfo(
                              'Power',
                              widget.model.attributes.power,
                              context,
                            ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: copiableCardText));
                  HapticFeedback.vibrate();
                },
                child: _buildCardInfo(
                  'Ability',
                  RichText(
                    text: TextSpan(
                      style: context.textTheme.bodyMedium,
                      children: prettifiedAbility,
                    ),
                  ),
                  context,
                ),
              ),
              if (prettifiedEffect.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: copiableCardText));
                    HapticFeedback.vibrate();
                  },
                  child: _buildCardInfo(
                    'Effect',
                    RichText(
                      text: TextSpan(
                        style: context.textTheme.bodyMedium,
                        children: prettifiedEffect,
                      ),
                    ),
                    context,
                  ),
                ),
              if (widget.model.mightBonus?.isNotEmpty ?? false)
                _buildCardInfo('Might Bonus', widget.model.mightBonus, context),
              Text(
                'Legalities',
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (var (format, legality) in widget.model.legalities.formats)
                Text.rich(
                  TextSpan(
                    text: legality.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: getLegalityColor(legality),
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: ' in ${_toNormalCase(format)}.',
                        style: TextStyle(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      controller: _expansibleController,
      expansibleBuilder: (context, header, body, animation) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, body],
      ),
    );
  }
}
