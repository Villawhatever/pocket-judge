import 'dart:convert';
import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:pocket_judge/card_search/card.dart';
import 'package:pocket_judge/errata/erratum.dart';
import 'package:pocket_judge/utils/extensions/json_extensions.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:uuid/uuid.dart';

Future main() async {
  await scrapeCardGallery();
  final ogn = await getErrataFromSemiSaneFormatting(
    'https://riftbound.leagueoflegends.com/en-us/news/rules-and-releases/riftbound-origins-card-errata/',
    'h2',
  );
  final sfd = await getErrataFromSemiSaneFormatting(
    'https://riftbound.leagueoflegends.com/en-us/news/rules-and-releases/riftbound-spiritforged-errata/',
    'h1',
  );
  final unl = await getUnlErrata(
    'https://playriftbound.com/en-us/news/rules-and-releases/unleashed-errata-updates/',
  );
  final ven = await getErrataFromSemiSaneFormatting(
    'https://playriftbound.com/en-us/news/announcements/vendetta-errata-updates/',
    'h2',
  );
  await _write([...ogn, ...sfd, ...unl, ...ven], r'lib/assets/errata.json');
  stdout.writeln(
    'Don\'t forget to add missing type to Porobot and remove \'Basic\' type from runes.',
  );
  return;
}

Future clickAllSetsButton(Page page) async {
  ElementHandle showFilterText = await page.evaluateHandle('''() => {
    const elements = Array.from(document.querySelectorAll('button>div'));
    return elements.find(el => el.innerText.trim() === 'Show Filters');
  }''');

  ElementHandle showFilterButton = (await showFilterText.$x('..')).first;
  showFilterButton.click();

  await Future.delayed(Duration(seconds: 1));

  ElementHandle setFilterText = await page.evaluateHandle('''() => {
    const elements = Array.from(document.querySelectorAll('button>span'));
    return elements.find(el => el.innerText.trim() === 'Set');
    }''');
  ElementHandle setFilterButton = (await setFilterText.$x('..')).first;
  setFilterButton.click();

  await page.waitForFunction(
    '''[...document.querySelectorAll('button')].some((b) => b.innerText.includes('All Sets'))''',
  );

  ElementHandle allSetsButton = await page.evaluateHandle('''() => {
          const elements = Array.from(document.querySelectorAll('button'));
          return elements.find(el => el.innerText.trim() === 'All Sets');
        }''');

  await Future.delayed(Duration(seconds: 1));

  allSetsButton.click();

  await page.waitForFunction('''() => {
      let allSets = [...document.querySelectorAll('button')].find((b) => b.innerText.includes('All Sets'));
      return allSets.getAttribute('data-state') === 'checked';
    }''');

  //for troubleshooting
  //await page.type('.input-search', 'Herald of the Arcane');

  await Future.delayed(Duration(seconds: 1));
}

void printProgressBar(int current, int length) {
  int barLength = 50;
  double percent = current / (length - 1);
  int filledLength = (percent * barLength).round();
  String filled = '█' * filledLength;
  String empty = '-' * (barLength - filledLength);
  String percentText = (percent * 100).toStringAsFixed(1);
  stdout.write('\r[$filled$empty] $percentText% ($current/${length - 1})');
}

Future<List<CardModel>> scrapeCardGallery() async {
  stdout.writeln('Scraping card gallery...');
  final browser = await puppeteer.launch(
    headless: false,
    args: ['--start-maximized'],
  );

  List<CardModel> cards = [];
  final stopwatch = Stopwatch();
  stopwatch.start();
  late String? cardName;
  try {
    final page = await browser.newPage();
    await page.setViewport(DeviceViewport(width: 1920, height: 1080));

    await page.goto(
      'https://riftbound.leagueoflegends.com/en-us/card-gallery/',
      wait: Until.domContentLoaded,
    );

    await Future.delayed(Duration(seconds: 2));
    await clickAllSetsButton(page);

    var cardButtons = await page.evaluateHandle('''() => {
      return Array.from(document.querySelectorAll('[href^="#card-gallery"]'));
    }''');

    final int length =
        await cardButtons.evaluate<int>('(arr) => arr.length') ?? 0;

    for (int i = 0; i < length; i++) {
      printProgressBar(i, length);

      await page.waitForSelector('[data-testid="frame"]', hidden: true);
      ElementHandle? cardButton = await cardButtons.evaluateHandle(
        '(arr, idx) => arr[idx];',
        args: [i],
      );
      cardButton.click();
      await page.waitForSelector('[data-testid="frame"]');

      await page.waitForFunction('''() => {
        const cardImage = document.querySelector('.main-card-image-container>.innerWrapper>img');
        return cardImage?.getAttribute('src')?.includes('.png') ?? false;
      }''');

      var cardFrame = await page.evaluate<String>('''() => {
        return document.querySelector('[data-testid="frame"]').innerHTML;
      }''');
      cardFrame = cardFrame.replaceAll('<br>', '\n');

      var bs = BeautifulSoup(cardFrame);
      cardName = bs.body!.descendants.first.descendants.first.h3!.innerHtml;
      cardName = cardName.replaceAll('’', '\'');
      cardName = cardName.replaceAll(' - ', ', ');
      final cardSetInfo = bs
          .body!
          .descendants
          .first
          .descendants
          .first
          .p!
          .innerHtml
          .replaceAll('*', '-star');
      final riotId = cardSetInfo.replaceAll(RegExp(r'[^\w]'), '-');
      final setId = riotId.split('-').first.toUpperCase();

      final cardImage = bs.body!.find('img');

      final imgUrl = cardImage
          ?.getAttrValue('src')
          ?.replaceAll(RegExp(r'(?<=\.png).+'), '');

      final images = bs.findAll('img');
      for (final img in images) {
        // turns an image with eg `whatever-rb_might` into `:rb_might:`
        // for prettiness purposes
        final rune = BeautifulSoup.newTag(
          'span',
          string: ':${img.classes.last.split('-').last}:',
        );
        img.replaceWith(rune);
      }

      final headers = bs.findAll('h6').toList();
      final Map<String, dynamic> cardAttributes = {};

      for (final header in headers) {
        final values = header.nextSibling?.findAll('p');
        if (values?.length == 1) {
          if (header.text == 'Tags' || header.text == 'Card Type') {
            cardAttributes[header.text] = values!.first.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          } else {
            cardAttributes[header.text] = values!.first.text;
          }
        } else {
          if (header.text == 'Card Type') {
            final superTypes = ['Champion', 'Signature', 'Token'];
            final superType = values
                ?.where((v) => superTypes.contains(v.text))
                .firstOrNull;
            if (superType != null) {
              values!.remove(superType);
              cardAttributes['Supertype'] = superType.text;
            }
          }
          cardAttributes[header.text] = values!.map((v) => v.text).toList();
        }
      }

      if (cardAttributes['Card Type'].contains('Legend')) {
        if ((cardAttributes['Tags'] as List<String>).contains('Kennen')) {
          cardName = 'Kennen, $cardName';
        } else {
          cardName =
              '${(cardAttributes['Tags'] as List<String>).first}, $cardName';
        }
      }

      ElementHandle? closeButton = await page.evaluateHandle('''() => {
      return document.querySelector('[data-testid="close"]');
    }''');
      closeButton.click();

      cards.add(
        CardModel(
          id: Uuid().v4(),
          name: cardName,
          riftboundId: riotId,
          tags: cardAttributes.tryGet('Tags') ?? [],
          attributes: Attributes(
            might: int.tryParse(cardAttributes.tryGet('Might') ?? ''),
            energy: int.tryParse(cardAttributes.tryGet('Energy') ?? ''),
            power: int.tryParse(cardAttributes.tryGet('Power') ?? ''),
          ),
          set: Set(setId: setId, label: cardAttributes.tryGet('Card Set')),
          text: Text(
            rich: cardAttributes.tryGet('Ability') ?? '',
            effect: cardAttributes.tryGet('Effect') ?? '',
          ),
          classification: Classification(
            type:
                cardAttributes.tryGet('Type') ??
                cardAttributes.tryGet('Card Type'),
            supertype: cardAttributes.tryGet('Supertype'),
            rarity: cardAttributes.tryGet('Rarity'),
            domain: _parseCorrectly(cardAttributes, 'Domain'),
          ),
          metadata: Metadata(updatedOn: DateTime.now().toUtc().toString()),
          media: Media(
            artist: cardAttributes.tryGet('Artist'),
            imageUrl: imgUrl,
          ),
          mightBonus: cardAttributes.tryGet('Might Bonus'),
        ),
      );
    }
    // final isar = Isar.getInstance('pocket-judge');
    // isar!.cardModels.putAll(cards);
    _write(cards, r'lib/assets/scraped_gallery.json');
    Duration duration = Duration(milliseconds: stopwatch.elapsedMilliseconds);

    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;

    stdout.writeln('\n=== Done. Took $minutes:$seconds ===');
  } catch (e) {
    stdout.writeln('Errored on $cardName: $e');
  } finally {
    stopwatch.stop();
  }

  return cards;
}

Future<List<ErratumModel>> getErrataFromSemiSaneFormatting(
  String url,
  String cardNameTag,
) async {
  stdout.writeln('Scraping errata from $url...');
  final browser = await puppeteer.launch(
    headless: true,
    args: ['--start-maximized'],
  );

  List<ErratumModel> errata = [];

  var cardName = '';
  try {
    final page = await browser.newPage();
    await page.setViewport(DeviceViewport(width: 1920, height: 1080));

    await page.goto(url, wait: Until.domContentLoaded);

    final pageBody = await page.evaluate<String>('''() => {
        return document.querySelector('main').innerHTML;
      }''');

    var bs = BeautifulSoup(pageBody);
    final cardNodes = bs.findAll(cardNameTag);
    for (final cardNode in cardNodes) {
      // the depths of this website design's depravity are endless
      if (cardNode.text.isEmpty ||
          cardNode.text == 'Origins Cards' ||
          cardNode.text == 'Spiritforged Cards') {
        continue;
      }
      cardName = cardNode.text;
      cardName = cardName.replaceAll('’', '\'');
      var concatenatedErrata = '';
      var node = cardNode.nextSibling;

      while (node != null && node.name != 'h4') {
        if (node.name != 'p' ||
            node.text.isEmpty ||
            node.text.contains('NEW TEXT')) {
          node = node.nextSibling;
          continue;
        }
        if (node.text.contains('▲')) {
          break;
        }
        if (concatenatedErrata.isNotEmpty) {
          concatenatedErrata += '\n';
        }
        concatenatedErrata += node.text;
        node = node.nextSibling;
      }
      if (concatenatedErrata.isNotEmpty) {
        errata.add(
          ErratumModel(name: cardName, set: '', newText: concatenatedErrata),
        );
      }
    }

    await Future.delayed(Duration(seconds: 1));
  } catch (e) {
    stdout.writeln('Error generating errata for $cardName: $e');
    rethrow;
  } finally {
    await browser.close();
  }
  return errata;
}

Future<List<ErratumModel>> getUnlErrata(String url) async {
  stdout.writeln('Scraping errata from $url...');
  final browser = await puppeteer.launch(
    headless: true,
    args: ['--start-maximized'],
  );

  List<ErratumModel> errata = [];

  var cardName = '';
  try {
    final page = await browser.newPage();
    await page.setViewport(DeviceViewport(width: 1920, height: 1080));

    await page.goto(url, wait: Until.domContentLoaded);

    final pageBody = await page.evaluate<String>('''() => {
        return document.querySelector('main').innerHTML;
      }''');

    var bs = BeautifulSoup(pageBody);
    final cardNodes = bs.findAll('h2');
    for (final cardNode in cardNodes) {
      if (cardNode.text.isEmpty ||
          cardNode.text == 'Origins Cards' ||
          cardNode.text == 'Spiritforged Cards') {
        continue;
      }
      cardName = cardNode.text;
      cardName = cardName.replaceAll('’', '\'');
      var concatenatedErrata = '';

      var node = cardNode.nextSibling?.nextSibling;
      while (node != null && node.text != '▲') {
        if (concatenatedErrata.isNotEmpty) {
          concatenatedErrata += '\n';
        }
        concatenatedErrata += node.text;
        node = node.nextSibling;
      }
      if (concatenatedErrata.isNotEmpty) {
        errata.add(
          ErratumModel(name: cardName, set: '', newText: concatenatedErrata),
        );
      }
    }

    await Future.delayed(Duration(seconds: 1));
  } catch (e) {
    stdout.writeln('Error generating errata for $cardName: $e');
    rethrow;
  } finally {
    await browser.close();
  }
  return errata;
}

List<String>? _parseCorrectly(Map<String, dynamic> cardAttributes, String key) {
  final value = cardAttributes.tryGet(key);
  List<String>? result;
  if (value == null) {
    result = null;
  } else if (value is String) {
    result = [value];
  } else {
    result = value;
  }
  return result;
}

Future _write(List<dynamic> list, String path) async {
  stdout.writeln('Writing to $path...');
  try {
    var encoded = jsonEncode(list);
    File file = File(path);
    await file.writeAsString(encoded);
    stdout.writeln('Done!');
  } catch (e) {
    stdout.writeln('Failed: $e');
  }
}
