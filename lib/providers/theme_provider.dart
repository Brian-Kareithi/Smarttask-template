import 'package:flutter/material.dart';
import '../services/preference_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferenceService _preferenceService = PreferenceService();

  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  void initialize(String uid) {
    _preferenceService.streamPreferences(uid).listen((prefs) {
      _isDarkMode = prefs.darkMode;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleDarkMode(String uid, bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _preferenceService.setPreference(uid, 'darkMode', value);
  }
}
