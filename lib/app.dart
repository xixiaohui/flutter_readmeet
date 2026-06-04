import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'services/reader_settings_service.dart';
import 'pages/home/home_page.dart';
import 'pages/list/list_page.dart';
import 'pages/favorites/favorites_page.dart';
import 'pages/annotations/global_annotations_page.dart';
import 'pages/setting/setting_page.dart';

class App extends StatelessWidget {
  final ApiService apiService;
  final ReaderSettingsService settingsService;
  final FavoriteService favoriteService;

  const App({
    super.key,
    required this.apiService,
    required this.settingsService,
    required this.favoriteService,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Readmeet',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
        barBackgroundColor: CupertinoColors.white,
        scaffoldBackgroundColor: CupertinoColors.white,
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground,
            context,
          ),
          border: const Border(
            top: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
          activeColor: CupertinoColors.activeBlue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_list),
              activeIcon: Icon(CupertinoIcons.square_list_fill),
              label: '全部文章',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bookmark),
              activeIcon: Icon(CupertinoIcons.bookmark_fill),
              label: '收藏',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.pencil),
              activeIcon: Icon(CupertinoIcons.pencil),
              label: '标注',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
              label: '设置',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (_) => HomePage(
                  apiService: apiService,
                  settingsService: settingsService,
                  favoriteService: favoriteService,
                ),
              );
            case 1:
              return CupertinoTabView(
                builder: (_) => ListPage(
                  apiService: apiService,
                  settingsService: settingsService,
                  favoriteService: favoriteService,
                ),
              );
            case 2:
              return CupertinoTabView(
                builder: (_) => FavoritesPage(
                  apiService: apiService,
                  settingsService: settingsService,
                  favoriteService: favoriteService,
                ),
              );
            case 3:
              return CupertinoTabView(
                builder: (_) => GlobalAnnotationsPage(
                  apiService: apiService,
                  settingsService: settingsService,
                  favoriteService: favoriteService,
                ),
              );
            case 4:
              return CupertinoTabView(
                builder: (_) => SettingPage(settingsService: settingsService),
              );
            default:
              return CupertinoTabView(
                builder: (_) => HomePage(
                  apiService: apiService,
                  settingsService: settingsService,
                  favoriteService: favoriteService,
                ),
              );
          }
        },
      ),
    );
  }
}
