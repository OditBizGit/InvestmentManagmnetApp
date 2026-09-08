import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/main.dart';

void main() {
  testWidgets('MyApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
