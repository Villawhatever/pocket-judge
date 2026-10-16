extension JsonGetExtension<T> on Map<String, T> {
  T? tryGet(String index) => this[index] != null ? this[index] as T : null;
}
