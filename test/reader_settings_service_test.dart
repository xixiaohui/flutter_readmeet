import 'package:flutter_test/flutter_test.dart';
import 'package:readmeet/services/reader_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default values are correct', () async {
    final service = ReaderSettingsService();
    expect(service.fontSize, ReaderSettingsService.defaultFontSize);
    expect(service.lineHeight, ReaderSettingsService.defaultLineHeight);
    expect(service.paragraphSpacing, ReaderSettingsService.defaultParagraphSpacing);
    expect(service.fontFamily, isNull);
    expect(service.backgroundColor, ReaderSettingsService.defaultBackgroundColor);
  });

  test('setFontSize notifies and persists', () async {
    final service = ReaderSettingsService();
    bool notified = false;
    service.addListener(() => notified = true);

    await service.setFontSize(20.0);
    expect(notified, isTrue);
    expect(service.fontSize, 20.0);

    final service2 = ReaderSettingsService();
    await service2.load();
    expect(service2.fontSize, 20.0);
  });

  test('setFontFamily null works', () async {
    final service = ReaderSettingsService();
    await service.setFontFamily('serif');
    expect(service.fontFamily, 'serif');

    await service.setFontFamily(null);
    expect(service.fontFamily, isNull);
  });

  test('setBackgroundColor works', () async {
    final service = ReaderSettingsService();
    await service.setBackgroundColor('dark');
    expect(service.backgroundColor, 'dark');
  });

  test('setLineHeight notifies and persists', () async {
    final service = ReaderSettingsService();
    bool notified = false;
    service.addListener(() => notified = true);

    await service.setLineHeight(2.0);
    expect(notified, isTrue);
    expect(service.lineHeight, 2.0);

    final service2 = ReaderSettingsService();
    await service2.load();
    expect(service2.lineHeight, 2.0);
  });

  test('setParagraphSpacing notifies and persists', () async {
    final service = ReaderSettingsService();
    bool notified = false;
    service.addListener(() => notified = true);

    await service.setParagraphSpacing(24.0);
    expect(notified, isTrue);
    expect(service.paragraphSpacing, 24.0);

    final service2 = ReaderSettingsService();
    await service2.load();
    expect(service2.paragraphSpacing, 24.0);
  });
}
