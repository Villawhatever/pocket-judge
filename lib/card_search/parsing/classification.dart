part of 'parser.dart';

extension ClassificationGrammar on SearchParserDefinition {
  Parser<AstNode> classificationComparison() =>
      (ref0(classificationIdentifier).map(convertShorthandToFullPropertyName) &
              ref0(comparisonOperator) &
              ref0(primary))
          .map<AstNode>((each) {
            return ClassificationNode(
              each[0] as String,
              each[1] as String,
              each[2] as AstNode,
            );
          });

  static const _classifications = ['type', 'domain'];

  Parser<String> classificationIdentifier() => [
    ChoiceParser<String>(
      _classifications.map((w) => string(w, ignoreCase: true)),
    ),
    pattern('td', ignoreCase: true).flatten(),
  ].toChoiceParser().flatten();
}
