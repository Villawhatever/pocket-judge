extension ListGetExtension<T> on List<T> {
  T? tryGet(int index) => index < 0 || index >= length ? null : this[index];

  List<T> removeEmpties() {
    removeWhere((s) => s == null || s.toString().isEmpty);
    return this;
  }
}
