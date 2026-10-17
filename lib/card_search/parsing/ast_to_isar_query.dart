import 'package:isar_community/isar.dart';

import '../../constants.dart';
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
      final value = _extractValue(node.value) as String;
      FilterOperation? filterCondition = switch (node.propertyName) {
        'name' => FilterCondition.contains(
          property: node.propertyName,
          value: value,
          caseSensitive: false,
        ),
        'watcher' => ObjectFilter(
          property: 'text',
          filter: FilterCondition.contains(
            property: 'rich',
            value: value,
            caseSensitive: false,
          ),
        ),
        'set' => ObjectFilter(
          property: 'set',
          filter: FilterGroup.or([
            FilterCondition.equalTo(
              property: 'setId',
              value: value,
              caseSensitive: false,
            ),
            FilterCondition.equalTo(
              property: 'label',
              value: value,
              caseSensitive: false,
            ),
          ]),
        ),
        'has' || 'is' => _handleNonCardProperty(value),
        'format' => _handleFormatQuery(value),
        _ => FilterCondition.contains(
          property: node.propertyName,
          value: value,
          caseSensitive: false,
        ),
      };
      return filterCondition;
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
    final List<String> returnableDomains = [];
    if (domains.values.contains(value)) {
      returnableDomains.add(value);
    } else {
      for (final shorthand in value.split('')) {
        if (domains.keys.contains(shorthand)) {
          returnableDomains.add(domains[shorthand]!);
        }
      }
    }
    return returnableDomains;
  }

  static FilterOperation? _handleFormatQuery(String value) {
    if (formats.keys.contains(value)) {
      return ObjectFilter(
        property: 'legalities',
        filter: FilterCondition.equalTo(
          property: formats[value]!,
          value: 'legal',
        ),
      );
    } else {
      return ObjectFilter(
        property: 'legalities',
        filter: FilterCondition.equalTo(property: value, value: 'legal'),
      );
    }
  }

  static FilterOperation? _handleNonCardProperty(String value) {
    if (['banned', 'ban', 'bans', 'b'].contains(value.toLowerCase())) {
      return ObjectFilter(
        property: 'legalities',
        filter: FilterGroup.or([
          ...formats.values.map(
            (fmt) => FilterCondition.equalTo(property: fmt, value: 'banned'),
          ),
        ]),
      );
    }
    if (['erratum', 'errata', 'err', 'e'].contains(value.toLowerCase())) {
      return FilterCondition.equalTo(property: 'hasErrata', value: true);
    }
    return null;
  }
}
