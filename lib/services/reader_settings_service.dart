import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettingsService extends ChangeNotifier {
  // Storage keys
  static const _keyFontSize = 'reader_font_size';
  static const _keyLineHeight = 'reader_line_height';
  static const _keyParagraphSpacing = 'reader_paragraph_spacing';
  static const _keyFontFamily = 'reader_font_family';
  static const _keyBackgroundColor = 'reader_background_color';
  static const _keyLocale = 'reader_locale';

  // Defaults matching existing AppText / AppSpacing design tokens
  static const double defaultFontSize = 17.0;
  static const double defaultLineHeight = 1.8;
  static const double defaultParagraphSpacing = 17.0;
  static const String defaultBackgroundColor = 'parchment';

  double _fontSize = defaultFontSize;
  double _lineHeight = defaultLineHeight;
  double _paragraphSpacing = defaultParagraphSpacing;
  String? _fontFamily; // null = system default
  String _backgroundColor = defaultBackgroundColor;
  String? _localeCode; // null = follow system

  // Getters
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  double get paragraphSpacing => _paragraphSpacing;
  String? get fontFamily => _fontFamily;
  String get backgroundColor => _backgroundColor;
  String? get localeCode => _localeCode;

  /// Load persisted settings (or use defaults on first run / error).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontSize = prefs.getDouble(_keyFontSize) ?? defaultFontSize;
      _lineHeight = prefs.getDouble(_keyLineHeight) ?? defaultLineHeight;
      _paragraphSpacing =
          prefs.getDouble(_keyParagraphSpacing) ?? defaultParagraphSpacing;
      _fontFamily = prefs.getString(_keyFontFamily);
      _backgroundColor =
          prefs.getString(_keyBackgroundColor) ?? defaultBackgroundColor;
      _localeCode = prefs.getString(_keyLocale);
      notifyListeners();
    } catch (_) {
      // Fall back to defaults silently
    }
  }

  // --- Setters (persist + notify) ---

  Future<void> setFontSize(double value) async {
    if (value == _fontSize) return;
    _fontSize = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLineHeight(double value) async {
    if (value == _lineHeight) return;
    _lineHeight = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setParagraphSpacing(double value) async {
    if (value == _paragraphSpacing) return;
    _paragraphSpacing = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setFontFamily(String? value) async {
    if (value == _fontFamily) return;
    _fontFamily = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLocale(String? code) async {
    if (code == _localeCode) return;
    _localeCode = code;
    notifyListeners();
    await _persist();
  }

  Future<void> setBackgroundColor(String value) async {
    if (value == _backgroundColor) return;
    _backgroundColor = value;
    notifyListeners();
    await _persist();
  }

  /// Reset all settings to their default values.
  Future<void> resetToDefaults() async {
    _fontSize = defaultFontSize;
    _lineHeight = defaultLineHeight;
    _paragraphSpacing = defaultParagraphSpacing;
    _fontFamily = null;
    _backgroundColor = defaultBackgroundColor;
    _localeCode = null;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFontSize, _fontSize);
      await prefs.setDouble(_keyLineHeight, _lineHeight);
      await prefs.setDouble(_keyParagraphSpacing, _paragraphSpacing);
      if (_fontFamily != null) {
        await prefs.setString(_keyFontFamily, _fontFamily!);
      } else {
        await prefs.remove(_keyFontFamily);
      }
      await prefs.setString(_keyBackgroundColor, _backgroundColor);
      if (_localeCode != null) {
        await prefs.setString(_keyLocale, _localeCode!);
      } else {
        await prefs.remove(_keyLocale);
      }
    } catch (_) {
      // Silently ignore persistence failures
    }
  }
}
