part of 'parser.dart';

extension AttributeGrammar on SearchParserDefinition {
  Parser<AstNode> attributeComparison() =>
      (ref0(attributeIdentifier).map(convertShorthandToFullPropertyName) &
              ref0(comparisonOperator) &
              ref0(primary))
          .map<AstNode>((each) {
            return AttributeNode(
              each[0] as String,
              each[1] as String,
              each[2] as AstNode,
            );
          });

  static const _attributes = ['energy', 'might', 'power'];

  Parser<String> attributeIdentifier() => [
    ChoiceParser<String>(_attributes.map((w) => string(w, ignoreCase: true))),
    pattern('emp', ignoreCase: true).flatten(),
  ].toChoiceParser().flatten();
}
