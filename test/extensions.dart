import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouldly/shouldly.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

void doSetup() {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  SharedPreferences.setMockInitialValues({});
}

class TextSpanAssertions extends BaseAssertions<TextSpan, TextSpanAssertions> {
  TextSpanAssertions(super.subject);

  TextSpanAssertions haveColor(Color color) {
    if (isReversed) {
      Execute.assertion.forCondition(subject!.style!.color == color).failWith(
          '$subjectLabel should not have\n\t${subject!.style!.color!}');
    } else {
      Execute.assertion.forCondition(subject!.style!.color != color).failWith(
          '$subjectLabel should have\n\t$color\nbut had\n\t${subject!.style!.color}');
    }
    return TextSpanAssertions(subject);
  }

  TextSpanAssertions haveFontStyle(FontStyle fontStyle) {
    if (isReversed) {
      Execute.assertion
          .forCondition(subject!.style!.fontStyle == fontStyle)
          .failWith('$subjectLabel should not have\n\t$fontStyle');
    } else {
      Execute.assertion
          .forCondition(subject!.style!.fontStyle != fontStyle)
          .failWith(
              '$subjectLabel should have\n\t$fontStyle\nbut had\n\t${subject!.style!.fontStyle}');
    }
    return TextSpanAssertions(subject);
  }

  TextSpanAssertions haveFontWeight(FontWeight fontWeight) {
    if (isReversed) {
      Execute.assertion
          .forCondition(subject!.style!.fontWeight == fontWeight)
          .failWith('$subjectLabel should not be\n\t$fontWeight');
    } else {
      Execute.assertion
          .forCondition(subject!.style!.fontWeight != fontWeight)
          .failWith(
              '$subjectLabel should be\n\t$fontWeight\nbut was\n\t${subject!.style!.fontWeight}');
    }
    return TextSpanAssertions(subject);
  }

  @override
  TextSpanAssertions copy(TextSpan? subject,
      {bool isReversed = false, String? subjectLabel}) {
    throw UnimplementedError();
  }
}

extension TextSpanExtension on TextSpan {
  TextSpanAssertions get should => TextSpanAssertions(this);
}
