import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('app root widget renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CommunityBookExchangeApp());
    await tester.pump();

    expect(find.byType(CommunityBookExchangeApp), findsOneWidget);
  });
}
