import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/app.dart';
import 'package:readmeet/services/api_service.dart';
import 'package:readmeet/services/reader_settings_service.dart';

void main() {
  testWidgets('App renders tab navigation', (WidgetTester tester) async {
    final apiService = ApiService();
    final settingsService = ReaderSettingsService();
    await tester.pumpWidget(App(
      apiService: apiService,
      settingsService: settingsService,
    ));

    // Verify the four tabs exist
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('全部文章'), findsOneWidget);
    expect(find.text('标注'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
