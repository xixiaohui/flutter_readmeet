import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'ReadMeet'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeTab;

  /// No description provided for @allArticlesTab.
  ///
  /// In zh, this message translates to:
  /// **'全部文章'**
  String get allArticlesTab;

  /// No description provided for @favoritesTab.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get favoritesTab;

  /// No description provided for @annotationsTab.
  ///
  /// In zh, this message translates to:
  /// **'标注'**
  String get annotationsTab;

  /// No description provided for @settingsTab.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTab;

  /// No description provided for @myAnnotations.
  ///
  /// In zh, this message translates to:
  /// **'我的标注'**
  String get myAnnotations;

  /// No description provided for @myFavorites.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get myFavorites;

  /// No description provided for @annotationList.
  ///
  /// In zh, this message translates to:
  /// **'标注列表'**
  String get annotationList;

  /// No description provided for @readingSettings.
  ///
  /// In zh, this message translates to:
  /// **'阅读设置'**
  String get readingSettings;

  /// No description provided for @fontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get fontSize;

  /// No description provided for @lineHeight.
  ///
  /// In zh, this message translates to:
  /// **'行间距'**
  String get lineHeight;

  /// No description provided for @paragraphSpacing.
  ///
  /// In zh, this message translates to:
  /// **'段落间距'**
  String get paragraphSpacing;

  /// No description provided for @fontStyle.
  ///
  /// In zh, this message translates to:
  /// **'字体样式'**
  String get fontStyle;

  /// No description provided for @readingBackground.
  ///
  /// In zh, this message translates to:
  /// **'阅读背景'**
  String get readingBackground;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @highlight.
  ///
  /// In zh, this message translates to:
  /// **'高亮标记'**
  String get highlight;

  /// No description provided for @underline.
  ///
  /// In zh, this message translates to:
  /// **'下划线'**
  String get underline;

  /// No description provided for @addNote.
  ///
  /// In zh, this message translates to:
  /// **'添加笔记'**
  String get addNote;

  /// No description provided for @generatePoster.
  ///
  /// In zh, this message translates to:
  /// **'生成海报'**
  String get generatePoster;

  /// No description provided for @changeColor.
  ///
  /// In zh, this message translates to:
  /// **'更换颜色'**
  String get changeColor;

  /// No description provided for @editNote.
  ///
  /// In zh, this message translates to:
  /// **'编辑笔记'**
  String get editNote;

  /// No description provided for @deleteAnnotation.
  ///
  /// In zh, this message translates to:
  /// **'删除标记'**
  String get deleteAnnotation;

  /// No description provided for @clearNotes.
  ///
  /// In zh, this message translates to:
  /// **'清空笔记'**
  String get clearNotes;

  /// No description provided for @note.
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get note;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @savedToGallery.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get savedToGallery;

  /// No description provided for @savedToGalleryMsg.
  ///
  /// In zh, this message translates to:
  /// **'海报已保存到相册'**
  String get savedToGalleryMsg;

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get saveFailed;

  /// No description provided for @checkPermission.
  ///
  /// In zh, this message translates to:
  /// **'请检查相册权限'**
  String get checkPermission;

  /// No description provided for @selectColor.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get selectColor;

  /// No description provided for @writeNote.
  ///
  /// In zh, this message translates to:
  /// **'写下你的想法...'**
  String get writeNote;

  /// No description provided for @noAnnotations.
  ///
  /// In zh, this message translates to:
  /// **'暂无标注'**
  String get noAnnotations;

  /// No description provided for @noFavorites.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏'**
  String get noFavorites;

  /// No description provided for @noContent.
  ///
  /// In zh, this message translates to:
  /// **'暂无内容'**
  String get noContent;

  /// No description provided for @noFeatured.
  ///
  /// In zh, this message translates to:
  /// **'暂无精选内容'**
  String get noFeatured;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @typesetting.
  ///
  /// In zh, this message translates to:
  /// **'排版中...'**
  String get typesetting;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In zh, this message translates to:
  /// **'清空所有标注'**
  String get confirmDeleteAll;

  /// No description provided for @irreversible.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可撤销'**
  String get irreversible;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @systemDefault.
  ///
  /// In zh, this message translates to:
  /// **'系统默认'**
  String get systemDefault;

  /// No description provided for @serif.
  ///
  /// In zh, this message translates to:
  /// **'宋体'**
  String get serif;

  /// No description provided for @monospace.
  ///
  /// In zh, this message translates to:
  /// **'等宽'**
  String get monospace;

  /// No description provided for @white.
  ///
  /// In zh, this message translates to:
  /// **'白色'**
  String get white;

  /// No description provided for @parchment.
  ///
  /// In zh, this message translates to:
  /// **'米色'**
  String get parchment;

  /// No description provided for @dark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  /// No description provided for @latestArticles.
  ///
  /// In zh, this message translates to:
  /// **'最新文章'**
  String get latestArticles;

  /// No description provided for @chineseFeatured.
  ///
  /// In zh, this message translates to:
  /// **'中文精选'**
  String get chineseFeatured;

  /// No description provided for @japaneseFeatured.
  ///
  /// In zh, this message translates to:
  /// **'日文精选'**
  String get japaneseFeatured;

  /// No description provided for @startReading.
  ///
  /// In zh, this message translates to:
  /// **'开始阅读'**
  String get startReading;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @requestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败'**
  String get requestFailed;

  /// No description provided for @articleNotFound.
  ///
  /// In zh, this message translates to:
  /// **'文章不存在'**
  String get articleNotFound;

  /// No description provided for @searchFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败'**
  String get searchFailed;

  /// No description provided for @poster.
  ///
  /// In zh, this message translates to:
  /// **'海报'**
  String get poster;

  /// No description provided for @pageIndicator.
  ///
  /// In zh, this message translates to:
  /// **'{current} / {total}'**
  String pageIndicator(Object current, Object total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
