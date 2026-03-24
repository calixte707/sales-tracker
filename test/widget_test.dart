import 'package:flutter_test/flutter_test.dart';
import 'package:sales_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SalesTrackerApp());
    expect(find.byType(SalesTrackerApp), findsOneWidget);
  });
}
