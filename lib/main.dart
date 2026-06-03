import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/reader_settings_service.dart';

void main() {
  final apiService = ApiService();
  final settingsService = ReaderSettingsService();
  settingsService.load(); // Pre-load saved preferences before first frame
  runApp(App(apiService: apiService, settingsService: settingsService));
}
