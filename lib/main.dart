import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'services/reader_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final settingsService = ReaderSettingsService();
  final favoriteService = FavoriteService();
  await settingsService.load();
  await favoriteService.load();
  runApp(App(
    apiService: apiService,
    settingsService: settingsService,
    favoriteService: favoriteService,
  ));
}
