import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import '../utils/formatters.dart';
import '../widgets/expansible_header.dart';
import 'card.dart';

class CardWidget extends StatefulWidget {
  const CardWidget(
      {super.key, required this.model, required this.expansibleController});

  final CardModel model;
  final ExpansibleController expansibleController;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  late final ExpansibleController _expansibleController;
  final _carouselSliderController = CarouselSliderController();
  int _currentImage = 0;

  @override
  initState() {
    _expansibleController = widget.expansibleController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var relevantText = widget.model.errataText ?? widget.model.ability ?? '';

    var prettified = formatCardText(relevantText, context);

    Widget buildCardInfo(String title, dynamic value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(value.toString(), style: context.textTheme.bodyMedium),
              ]));
    }

    List<CachedNetworkImage> getImages() {
      if (widget.model.images?.isEmpty ?? true) {
        return [];
      }
      final imageData = widget.model.images!;
      final List<CachedNetworkImage> images = [];
      for (final datum in imageData) {
        images.add(CachedNetworkImage(
          imageUrl: datum.imgUrl,
          placeholder: (context, url) => CircularProgressIndicator(
              constraints: BoxConstraints(
                  maxHeight: 100,
                  minHeight: 100,
                  minWidth: 100,
                  maxWidth: 100)),
          errorWidget: (context, url, error) => Icon(Icons.error, size: 45),
        ));
      }
      return images;
    }

    List<Widget> buildCarousel() {
      if (widget.model.images?.isEmpty ?? true) {
        return [];
      }

      if (widget.model.images!.length == 1) {
        var img = getImages().first;
        return [
          Padding(
              padding: EdgeInsetsGeometry.only(top: 12),
              child: Center(child: img))
        ];
      }

      return [
        Padding(
          padding: EdgeInsetsGeometry.only(top: 12),
          child: Container(
              color: Colors.grey,
              child: CarouselSlider(
                  items: getImages(),
                  carouselController: _carouselSliderController,
                  options: CarouselOptions(
                      height: 400,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImage = index;
                        });
                      }))),
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
                      color: (_currentImage == entry.key
                              ? context.colorScheme.secondary
                              : context.colorScheme.primary)
                          .withValues(
                              alpha: _currentImage == entry.key ? 1.0 : 0.5)),
                ),
              );
            }).toList())
      ];
    }

    return Expansible(
      headerBuilder: (context, animation) => ExpansibleHeader(
          title: widget.model.name,
          context: context,
          animation: animation,
          expansibleController: _expansibleController),
      bodyBuilder: (context, animation) {
        return Padding(
            padding: EdgeInsetsGeometry.only(left: 5, right: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...buildCarousel(),
                  Table(children: [
                    TableRow(children: [
                      buildCardInfo(
                          'Domain(s)', widget.model.domain?.join(', ')),
                      SizedBox.shrink()
                    ]),
                    TableRow(children: [
                      buildCardInfo('Card Type', widget.model.cardType),
                      widget.model.cardType.toLowerCase() == 'unit'
                          ? buildCardInfo('Might', widget.model.might)
                          : SizedBox.shrink(),
                    ]),
                    TableRow(children: [
                      widget.model.energy == null
                          ? SizedBox.shrink()
                          : buildCardInfo('Energy', widget.model.energy),
                      widget.model.power == null
                          ? SizedBox.shrink()
                          : buildCardInfo('Power', widget.model.power),
                    ])
                  ]),
                  RichText(
                    text: TextSpan(
                        style: context.textTheme.bodyMedium,
                        children: prettified),
                  ),
                ]));
      },
      controller: _expansibleController,
      expansibleBuilder: (
        context,
        header,
        body,
        animation,
      ) =>
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, body]),
    );
  }
}
