import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/home/home_page.dart';
import 'pages/list/list_page.dart';

class App extends StatelessWidget {
  final ApiService apiService;

  const App({super.key, required this.apiService});

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
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (_) => HomePage(apiService: apiService),
              );
            case 1:
              return CupertinoTabView(
                builder: (_) => ListPage(apiService: apiService),
              );
            default:
              return CupertinoTabView(
                builder: (_) => HomePage(apiService: apiService),
              );
          }
        },
      ),
    );
  }
}
