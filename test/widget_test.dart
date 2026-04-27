import 'package:flutter_test/flutter_test.dart';
import 'package:app_finanzas/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AppFinanzas());
    expect(find.byType(AppFinanzas), findsOneWidget);
  });
}
