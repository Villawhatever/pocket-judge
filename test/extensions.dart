import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouldly/shouldly.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

const String input = 'input';
const String expected = 'expected';

void doSetup() {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          // Return a mock path when the specific method is called
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return '.'; // Returns the current directory as a mock path
          }
          return null;
        },
      );

  SharedPreferences.setMockInitialValues({});
}

class TextSpanAssertions extends BaseAssertions<TextSpan, TextSpanAssertions> {
  TextSpanAssertions(super.subject);

  TextSpanAssertions haveColor(Color color) {
    if (isReversed) {
      Execute.assertion
          .forCondition(subject!.style!.color == color)
          .failWith(
            '$subjectLabel should not have\n\t${subject!.style!.color!}',
          );
    } else {
      Execute.assertion
          .forCondition(subject!.style!.color != color)
          .failWith(
            '$subjectLabel should have\n\t$color\nbut had\n\t${subject!.style!.color}',
          );
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
            '$subjectLabel should have\n\t$fontStyle\nbut had\n\t${subject!.style!.fontStyle}',
          );
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
            '$subjectLabel should be\n\t$fontWeight\nbut was\n\t${subject!.style!.fontWeight}',
          );
    }
    return TextSpanAssertions(subject);
  }

  @override
  TextSpanAssertions copy(
    TextSpan? subject, {
    bool isReversed = false,
    String? subjectLabel,
  }) {
    throw UnimplementedError();
  }
}

extension TextSpanExtension on TextSpan {
  TextSpanAssertions get should => TextSpanAssertions(this);
}

class ContainerAssertions
    extends BaseAssertions<Container, ContainerAssertions> {
  ContainerAssertions(super.subject);

  ContainerAssertions haveColor(Color color) {
    if (isReversed) {
      Execute.assertion
          .forCondition(subject!.color == color)
          .failWith('$subjectLabel should not have\n\t${subject!.color!}');
    } else {
      Execute.assertion
          .forCondition(subject!.color != color)
          .failWith(
            '$subjectLabel should have\n\t$color\nbut had\n\t${subject!.color}',
          );
    }
    return ContainerAssertions(subject);
  }

  @override
  ContainerAssertions copy(
    Container? subject, {
    bool isReversed = false,
    String? subjectLabel,
  }) {
    throw UnimplementedError();
  }
}

extension ContainerExtension on Container {
  ContainerAssertions get should => ContainerAssertions(this);
}

// class Assertions<T> extends BaseAssertions<T, Assertions<T>> {
//   Assertions(super.subject);
//
//   @override
//   Assertions<T> copy(
//     T? subject, {
//     bool isReversed = false,
//     String? subjectLabel,
//   }) {
//     throw UnimplementedError();
//   }
// }
//
// extension AssertionsExtension<T> on T {
//   Assertions<T> get should => Assertions<T>(this);
// }
