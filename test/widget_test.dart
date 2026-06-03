import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/app.dart';
import 'package:readmeet/services/api_service.dart';

void main() {
  testWidgets('App renders tab navigation', (WidgetTester tester) async {
    final apiService = ApiService();
    await tester.pumpWidget(App(apiService: apiService));

    // Verify the two tabs exist
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('全部文章'), findsOneWidget);
  });
}
