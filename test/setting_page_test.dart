import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/pages/setting/setting_page.dart';
import 'package:readmeet/services/reader_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReaderSettingsService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ReaderSettingsService();
  });

  testWidgets('renders all setting sections', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    expect(find.text('阅读设置'), findsOneWidget);
    expect(find.text('字体大小'), findsOneWidget);
    expect(find.text('行间距'), findsOneWidget);
    expect(find.text('段落间距'), findsOneWidget);
    expect(find.text('字体样式'), findsOneWidget);
    expect(find.text('阅读背景'), findsOneWidget);
  });

  testWidgets('sliders are present', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    expect(find.byType(CupertinoSlider), findsNWidgets(3));
  });

  testWidgets('segmented controls are present', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SettingPage(settingsService: service),
      ),
    );

    expect(
      find.byType(CupertinoSlidingSegmentedControl<String>),
      findsWidgets,
    );
  });
}
