import 'dart:core';

abstract class AstNode {}

class Comparison {
  static const ge = '>=';
  static const gt = '>';
  static const lt = '<';
  static const le = '<=';
  static const eq = '=';
}

class ValueNode extends AstNode {
  final String text;
  final bool isPhrase;
  ValueNode(this.text, {this.isPhrase = false});

  @override
  String toString() => isPhrase ? '"$text"' : text;
}

class BinaryOpNode extends AstNode {
  final String operator;
  final AstNode left;
  final AstNode right;
  BinaryOpNode(this.operator, this.left, this.right);
  @override
  String toString() => '($left $operator $right)';
}

class ComparisonNode extends AstNode {
  final String propertyName;
  final String operator;
  final AstNode value;
  ComparisonNode(this.propertyName, this.operator, this.value);

  @override
  String toString() => '$propertyName$operator$value';
}

class AttributeNode extends ComparisonNode {
  AttributeNode(super.propertyName, super.operator, super.value);
}

class ClassificationNode extends ComparisonNode {
  ClassificationNode(super.propertyName, super.operator, super.value);
}

class PropertyNode extends AstNode {
  final String propertyName;
  final AstNode value;
  PropertyNode(this.propertyName, this.value);

  @override
  String toString() => '$propertyName:$value';
}

class GroupNode extends AstNode {
  final List<AstNode> children;
  GroupNode(this.children);

  @override
  String toString() => 'Group(${children.join(', ')})';
}
