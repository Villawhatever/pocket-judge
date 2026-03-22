extension JsonGetExtension<T> on Map<String, dynamic> {
  T? tryGet(String index) =>
      this[index] != null ? this[index] as T : null;
}
