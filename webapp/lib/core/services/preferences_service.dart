import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/core/constants/app_constants.dart';

/// Thin wrapper around [SharedPreferences] for onboarding persistence.
class PreferencesService {
  PreferencesService._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'PreferencesService.init() must be called before use.',
      );
    }
    return prefs;
  }

  /// Returns `true` when onboarding has never been completed.
  static bool get isFirstInstall =>
      _instance.getBool(AppConstants.isFirstInstallKey) ?? true;

  static Future<void> completeOnboarding() async {
    await _instance.setBool(AppConstants.isFirstInstallKey, false);
  }
}
