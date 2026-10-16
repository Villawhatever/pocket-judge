import 'package:petitparser/petitparser.dart';

import 'ast_node.dart';

part 'attribute.dart';
part 'classification.dart';

String convertShorthandToFullPropertyName(String value) {
  return switch (value.toLowerCase()) {
    'd' => 'domain',
    'e' => 'energy',
    'f' => 'format',
    'm' => 'might',
    'n' => 'name',
    'p' => 'power',
    's' => 'set',
    't' => 'type',
    'w' => 'watcher',
    _ => value,
  };
}

class SearchParserDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(expression).end();

  Parser expression() => ref0(orExpression);

  Parser orExpression() => ref0(
    andExpression,
  ).plusSeparated(ref0(orOperator)).map((each) => _buildBinaryTree('OR', each));

  Parser andExpression() => ref0(implicitAndExpression)
      .plusSeparated(ref0(andOperator))
      .map((each) => _buildBinaryTree('AND', each));

  Parser implicitAndExpression() => ref0(element)
      .plusSeparated(whitespace().plus().notFollowedByKeyword())
      .map((each) => _buildBinaryTree('AND', each));

  Parser element() => [
    ref0(fieldScoped),
    ref0(attributeComparison),
    ref0(classificationComparison),
    ref0(primary),
  ].toChoiceParser().trim();

  Parser<AstNode> primary() =>
      [ref0(parenPhrase), ref0(quotePhrase), ref0(word)].toChoiceParser();

  Parser<AstNode> fieldScoped() =>
      (ref0(identifier).map(convertShorthandToFullPropertyName) &
              char(':').or(char('=')) &
              ref0(primary))
          .map<AstNode>((each) {
            return PropertyNode(each[0] as String, each[2] as AstNode);
          });

  Parser<String> comparisonOperator() => <Parser>[
    string(Comparison.ge),
    char(Comparison.gt),
    string(Comparison.le),
    char(Comparison.lt),
    char(Comparison.eq),
    char(':'),
  ].toChoiceParser().flatten();

  Parser<AstNode> parenPhrase() => (char('(') & ref0(expression) & char(')'))
      .map<AstNode>((each) => each[1] as AstNode);

  Parser<AstNode> quotePhrase() =>
      (char('"') & any().starLazy(char('"')).flatten() & char('"'))
          .map<AstNode>((each) => ValueNode(each[1] as String, isPhrase: true));

  Parser<AstNode> word() =>
      (string(
                'AND',
                ignoreCase: true,
              ).or(string('OR', ignoreCase: true)).trim().not() &
              pattern('a-zA-Z0-9_\\.').plus().flatten())
          .map<AstNode>((each) => ValueNode(each[1] as String));

  static const _fullWordProperties = [
    'format',
    'has',
    'is',
    'name',
    'set',
    'watcher',
  ];

  Parser<String> identifier() => [
    ChoiceParser<String>(
      _fullWordProperties.map((w) => string(w, ignoreCase: true)),
    ),
    pattern('fnsw', ignoreCase: true).flatten(),
  ].toChoiceParser().flatten();

  Parser orOperator() => string('OR', ignoreCase: true).trim();
  Parser andOperator() => string('AND', ignoreCase: true).trim();

  AstNode _buildBinaryTree(String defaultOp, dynamic separatedList) {
    final elements = separatedList.elements.cast<AstNode>().toList();
    if (elements.length == 1) return elements.first as AstNode;

    AstNode result = elements[0];
    for (var i = 1; i < elements.length; i++) {
      result = BinaryOpNode(defaultOp, result, elements[i]);
    }
    return result;
  }
}

extension on Parser {
  Parser notFollowedByKeyword() => seq(
    string('AND', ignoreCase: true).or(string('OR', ignoreCase: true)),
  ).not();
}
