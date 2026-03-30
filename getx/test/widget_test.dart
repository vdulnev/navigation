import 'package:flutter_test/flutter_test.dart';

import 'package:getx/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Shop'), findsWidgets);
  });
}
