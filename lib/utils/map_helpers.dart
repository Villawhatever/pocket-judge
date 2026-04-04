Map<K, V> createMultiKeyMap<K, V>(Map<List<K>, V> input) {
  final result = <K, V>{};
  for (var entry in input.entries) {
    for (var key in entry.key) {
      result[key] = entry.value;
    }
  }
  return result;
}
