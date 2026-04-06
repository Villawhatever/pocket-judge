import 'package:flutter/material.dart';

extension ExpansibleExtensions on ExpansibleController {
  void toggle() {
    isExpanded ? collapse() : expand();
  }
}
