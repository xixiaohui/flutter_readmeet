import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/api_service.dart';
import 'services/favorite_service.dart';
import 'services/reader_settings_service.dart';
import 'pages/home/home_page.dart';
import 'pages/list/list_page.dart';
import 'pages/favorites/favorites_page.dart';
import 'pages/annotations/global_annotations_page.dart';
import 'pages/setting/setting_page.dart';

class App extends StatefulWidget {
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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _syncLocale();
    widget.settingsService.addListener(_syncLocale);
  }

  @override
  void dispose() {
    widget.settingsService.removeListener(_syncLocale);
    super.dispose();
  }

  void _syncLocale() {
    final code = widget.settingsService.localeCode;
    if (code == null) {
      setState(() => _locale = null);
    } else {
      setState(() => _locale = Locale(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ReadMeet',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('zh', 'Hant'),
        Locale('ja'),
        Locale('en'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) return _locale;
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.house_fill),
              activeIcon: const Icon(CupertinoIcons.house_fill),
              label: AppLocalizations.of(context)?.homeTab ?? '首页',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.square_list),
              activeIcon: const Icon(CupertinoIcons.square_list_fill),
              label: AppLocalizations.of(context)?.allArticlesTab ?? '全部文章',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.bookmark),
              activeIcon: const Icon(CupertinoIcons.bookmark_fill),
              label: AppLocalizations.of(context)?.favoritesTab ?? '收藏',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.pencil),
              activeIcon: const Icon(CupertinoIcons.pencil),
              label: AppLocalizations.of(context)?.annotationsTab ?? '标注',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.settings),
              activeIcon: const Icon(CupertinoIcons.settings_solid),
              label: AppLocalizations.of(context)?.settingsTab ?? '设置',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (_) => HomePage(
                  apiService: widget.apiService,
                  settingsService: widget.settingsService,
                  favoriteService: widget.favoriteService,
                ),
              );
            case 1:
              return CupertinoTabView(
                builder: (_) => ListPage(
                  apiService: widget.apiService,
                  settingsService: widget.settingsService,
                  favoriteService: widget.favoriteService,
                ),
              );
            case 2:
              return CupertinoTabView(
                builder: (_) => FavoritesPage(
                  apiService: widget.apiService,
                  settingsService: widget.settingsService,
                  favoriteService: widget.favoriteService,
                ),
              );
            case 3:
              return CupertinoTabView(
                builder: (_) => GlobalAnnotationsPage(
                  apiService: widget.apiService,
                  settingsService: widget.settingsService,
                  favoriteService: widget.favoriteService,
                ),
              );
            case 4:
              return CupertinoTabView(
                builder: (_) => SettingPage(
                    settingsService: widget.settingsService),
              );
            default:
              return CupertinoTabView(
                builder: (_) => HomePage(
                  apiService: widget.apiService,
                  settingsService: widget.settingsService,
                  favoriteService: widget.favoriteService,
                ),
              );
          }
        },
      ),
    );
  }
}
