// A minimal smoke test so `flutter test` and `flutter analyze` pass.
// The default template test references MyApp which no longer exists.
import 'package:ai_prompt/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app constructs without crashing', () {
    const app = AiPromptApp();
    expect(app, isA<AiPromptApp>());
  });
}
