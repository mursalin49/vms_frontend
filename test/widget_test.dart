import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/app/app.dart';

void main() {
  testWidgets('VmsApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VmsApp()));
    await tester.pump();
    expect(find.byType(VmsApp), findsOneWidget);
  });
}
