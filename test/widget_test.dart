import 'package:flutter_test/flutter_test.dart';
import 'package:cat_tinder/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Используйте правильное имя класса
    await tester.pumpWidget(const MyApp());
    expect(find.text('Cat Tinder'), findsOneWidget);
  });
}
