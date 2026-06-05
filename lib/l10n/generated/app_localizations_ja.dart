// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ReadMeet';

  @override
  String get homeTab => 'ホーム';

  @override
  String get allArticlesTab => 'すべての記事';

  @override
  String get favoritesTab => 'お気に入り';

  @override
  String get annotationsTab => '注釈';

  @override
  String get settingsTab => '設定';

  @override
  String get myAnnotations => 'マイ注釈';

  @override
  String get myFavorites => 'お気に入り';

  @override
  String get annotationList => '注釈リスト';

  @override
  String get readingSettings => '読書設定';

  @override
  String get fontSize => 'フォントサイズ';

  @override
  String get lineHeight => '行間';

  @override
  String get paragraphSpacing => '段落間隔';

  @override
  String get fontStyle => 'フォントスタイル';

  @override
  String get readingBackground => '読書背景';

  @override
  String get copy => 'コピー';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get highlight => 'ハイライト';

  @override
  String get underline => '下線';

  @override
  String get addNote => 'メモ追加';

  @override
  String get generatePoster => 'ポスター生成';

  @override
  String get changeColor => '色変更';

  @override
  String get editNote => 'メモ編集';

  @override
  String get deleteAnnotation => '注釈削除';

  @override
  String get clearNotes => 'メモ消去';

  @override
  String get note => 'メモ';

  @override
  String get delete => '削除';

  @override
  String get savedToGallery => '保存完了';

  @override
  String get savedToGalleryMsg => 'ポスターをギャラリーに保存しました';

  @override
  String get saveFailed => '保存失敗';

  @override
  String get checkPermission => 'ギャラリー権限を確認してください';

  @override
  String get selectColor => '色を選択';

  @override
  String get writeNote => '考えを書いてください...';

  @override
  String get noAnnotations => '注釈なし';

  @override
  String get noFavorites => 'お気に入りなし';

  @override
  String get noContent => 'コンテンツなし';

  @override
  String get noFeatured => 'おすすめ記事なし';

  @override
  String get loading => '読み込み中...';

  @override
  String get typesetting => '組版中...';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get back => '戻る';

  @override
  String get viewAll => 'すべて見る';

  @override
  String get confirmDeleteAll => 'すべての注釈を消去';

  @override
  String get irreversible => 'この操作は取り消せません';

  @override
  String get clear => '消去';

  @override
  String get systemDefault => 'システム既定';

  @override
  String get serif => '明朝体';

  @override
  String get monospace => '等幅';

  @override
  String get white => '白';

  @override
  String get parchment => '生成り';

  @override
  String get dark => 'ダーク';

  @override
  String get latestArticles => '最新記事';

  @override
  String get chineseFeatured => '中国語おすすめ';

  @override
  String get japaneseFeatured => '日本語おすすめ';

  @override
  String get startReading => '読み始める';

  @override
  String get language => '言語';

  @override
  String get requestFailed => 'リクエスト失敗';

  @override
  String get articleNotFound => '記事が見つかりません';

  @override
  String get searchFailed => '検索失敗';

  @override
  String get poster => 'ポスター';

  @override
  String get retry => '再試行';

  @override
  String get unknownAuthor => '不明な著者';

  @override
  String get enterSearchKeyword => '検索キーワードを入力してください';

  @override
  String get closeButton => '閉じる';

  @override
  String get searchArticleHint => '記事を検索...';

  @override
  String get noSearchResults => '該当する結果がありません';

  @override
  String get noArticles => '記事がありません';

  @override
  String get followSystem => 'システムに従う';

  @override
  String get chineseSimplified => '簡体字中国語';

  @override
  String get chineseTraditional => '繁体字中国語';

  @override
  String get japaneseLang => '日本語';

  @override
  String get posterTitlePrefix => '—— ';

  @override
  String get reset => 'リセット';

  @override
  String get typography => 'タイポグラフィ';

  @override
  String get appearance => '外観';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get resetSettingsMsg => 'すべての設定がデフォルトに戻ります。';

  @override
  String pageIndicator(Object current, Object total) {
    return '$current / $total';
  }
}
