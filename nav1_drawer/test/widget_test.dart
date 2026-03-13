import 'package:flutter_test/flutter_test.dart';
import 'package:nav1_drawer/app.dart';

void main() {
  testWidgets('App renders ShopScreen smoke test', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Shop'), findsWidgets);
  });
}
