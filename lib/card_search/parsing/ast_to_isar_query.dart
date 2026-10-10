import 'package:isar_community/isar.dart';

import 'ast_node.dart';

class IsarQueryBuilder {
  static Query<T> buildQuery<T>(IsarCollection<T> collection, AstNode ast) {
    final filterTree = _convertNode(ast);

    // ignore: experimental_member_use
    return collection.buildQuery<T>(filter: filterTree);
  }

  static FilterOperation? _convertNode(AstNode node) {
    if (node is BinaryOpNode) {
      final leftFilter = _convertNode(node.left);
      final rightFilter = _convertNode(node.right);

      final filters = <FilterOperation>[];
      if (leftFilter != null) filters.add(leftFilter);
      if (rightFilter != null) filters.add(rightFilter);

      if (filters.isEmpty) return null;

      return FilterGroup(
        filters: filters,
        type: node.operator == 'OR' ? FilterGroupType.or : FilterGroupType.and,
      );
    }

    if (node is PropertyNode) {
      final valueText = _extractValue(node.value);
      return FilterCondition.equalTo(
        property: node.propertyName,
        value: valueText,
        caseSensitive: false,
      );
    }

    if (node is AttributeNode) {
      final property = node.propertyName;
      final rawValue = _extractValue(node.value);
      return _handleAttributeNode(property, node.operator, rawValue);
    }
    if (node is ComparisonNode) {
      final property = node.propertyName;
      final rawValue = _extractValue(node.value);
      return _handleClassificationNode(property, node.operator, rawValue);
    }

    if (node is ValueNode) {
      return FilterCondition.contains(
        property: 'name',
        value: node.text,
        caseSensitive: false,
      );
    }

    return null;
  }

  static FilterGroup _handleAttributeNode(
    String property,
    String op,
    Object value,
  ) {
    final filter = _buildComparisonFilter(property, op, value);
    return FilterGroup.and([
      ObjectFilter(
        property: 'attributes',
        filter: FilterCondition.isNotNull(property: property),
      ),
      ObjectFilter(property: 'attributes', filter: filter),
    ]);
  }

  static FilterGroup _handleClassificationNode(
    String property,
    String op,
    Object value,
  ) {
    List<String> filterableDomains = [];
    if (property == 'domain') {
      filterableDomains = _handleDomainsQuery(value as String);
    }

    return FilterGroup.and([
      ObjectFilter(
        property: 'classification',
        filter: FilterCondition.isNotNull(property: property),
      ),
      if (filterableDomains.isNotEmpty)
        ...filterableDomains.map(
          (d) => ObjectFilter(
            property: 'classification',
            filter: FilterCondition.contains(
              property: property,
              value: d,
              caseSensitive: false,
            ),
          ),
        )
      else
        ObjectFilter(
          property: 'classification',
          filter: FilterCondition.contains(
            property: property,
            value: value as String,
            caseSensitive: false,
          ),
        ),
    ]);
  }

  static FilterCondition _buildComparisonFilter(
    String property,
    String op,
    Object value,
  ) {
    return switch (op) {
      Comparison.eq => FilterCondition.equalTo(
        property: property,
        value: value,
      ),
      Comparison.gt => FilterCondition.greaterThan(
        property: property,
        value: value,
        include: false,
      ),
      Comparison.ge => FilterCondition.greaterThan(
        property: property,
        value: value,
        include: true,
      ),
      Comparison.lt => FilterCondition.lessThan(
        property: property,
        value: value,
        include: false,
      ),
      Comparison.le => FilterCondition.lessThan(
        property: property,
        value: value,
        include: true,
      ),
      _ => FilterCondition.equalTo(property: property, value: value),
    };
  }

  static Object _extractValue(AstNode node) {
    if (node is ValueNode) {
      if (!node.isPhrase) {
        final asInt = int.tryParse(node.text);
        if (asInt != null) return asInt;
        final asDouble = double.tryParse(node.text);
        if (asDouble != null) return asDouble;
      }
      return node.text;
    }
    return node.toString();
  }

  static List<String> _handleDomainsQuery(String value) {
    final List<String> domains = [];
    if (_domains.values.contains(value)) {
      domains.add(value);
    } else {
      for (final shorthand in value.split('')) {
        if (_domains.keys.contains(shorthand)) {
          domains.add(_domains[shorthand]!);
        }
      }
    }
    return domains;
  }

  static final Map<String, String> _domains = {
    'r': 'fury',
    'g': 'calm',
    'b': 'mind',
    'o': 'body',
    'p': 'chaos',
    'y': 'order',
  };
}
