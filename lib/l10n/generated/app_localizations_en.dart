// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReadMeet';

  @override
  String get homeTab => 'Home';

  @override
  String get allArticlesTab => 'Articles';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get annotationsTab => 'Notes';

  @override
  String get settingsTab => 'Settings';

  @override
  String get myAnnotations => 'My Notes';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get annotationList => 'Notes';

  @override
  String get readingSettings => 'Reading';

  @override
  String get fontSize => 'Font Size';

  @override
  String get lineHeight => 'Line Height';

  @override
  String get paragraphSpacing => 'Paragraph Spacing';

  @override
  String get fontStyle => 'Font Style';

  @override
  String get readingBackground => 'Background';

  @override
  String get copy => 'Copy';

  @override
  String get selectAll => 'Select All';

  @override
  String get highlight => 'Highlight';

  @override
  String get underline => 'Underline';

  @override
  String get addNote => 'Add Note';

  @override
  String get generatePoster => 'Poster';

  @override
  String get changeColor => 'Change Color';

  @override
  String get editNote => 'Edit Note';

  @override
  String get deleteAnnotation => 'Delete';

  @override
  String get clearNotes => 'Clear Notes';

  @override
  String get note => 'Note';

  @override
  String get delete => 'Delete';

  @override
  String get savedToGallery => 'Saved';

  @override
  String get savedToGalleryMsg => 'Poster saved to gallery';

  @override
  String get saveFailed => 'Save Failed';

  @override
  String get checkPermission => 'Check gallery permission';

  @override
  String get selectColor => 'Select Color';

  @override
  String get writeNote => 'Write your thoughts...';

  @override
  String get noAnnotations => 'No notes yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noContent => 'No content';

  @override
  String get noFeatured => 'No featured articles';

  @override
  String get loading => 'Loading...';

  @override
  String get typesetting => 'Typesetting...';

  @override
  String get confirm => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get viewAll => 'View All';

  @override
  String get confirmDeleteAll => 'Delete all notes?';

  @override
  String get irreversible => 'Cannot be undone';

  @override
  String get clear => 'Clear';

  @override
  String get systemDefault => 'System';

  @override
  String get serif => 'Serif';

  @override
  String get monospace => 'Monospace';

  @override
  String get white => 'White';

  @override
  String get parchment => 'Parchment';

  @override
  String get dark => 'Dark';

  @override
  String get latestArticles => 'Latest';

  @override
  String get chineseFeatured => 'Chinese';

  @override
  String get japaneseFeatured => 'Japanese';

  @override
  String get startReading => 'Start Reading';

  @override
  String get language => 'Language';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get articleNotFound => 'Article not found';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get poster => 'Poster';

  @override
  String pageIndicator(Object current, Object total) {
    return '$current / $total';
  }
}
