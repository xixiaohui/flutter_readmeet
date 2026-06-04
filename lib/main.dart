import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/reader_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final settingsService = ReaderSettingsService();
  await settingsService.load(); // Ensure settings loaded before first frame
  runApp(App(apiService: apiService, settingsService: settingsService));
}
