// frontend/lib/presentation/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Map<String, dynamic> _settings = {};

  SettingsProvider(this._prefs) {
    loadSettings();
  }

  /// Cargar configuraciones desde almacenamiento local
  Future<void> loadSettings() async {
    _settings['darkMode'] = _prefs.getBool('darkMode') ?? false;
    _settings['language'] = _prefs.getString('language') ?? 'Español';
    _settings['emailNotifications'] =
        _prefs.getBool('emailNotifications') ?? true;
    _settings['pushNotifications'] =
        _prefs.getBool('pushNotifications') ?? true;
    _settings['shareData'] = _prefs.getBool('shareData') ?? false;
    notifyListeners();
  }

  /// Obtener valor de una configuración
  dynamic getSetting(String key) {
    return _settings[key];
  }

  /// Actualizar configuración y guardar en almacenamiento local
  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
    notifyListeners();
  }

  /// Resetear todas las configuraciones a valores predeterminados
  Future<void> resetSettings() async {
    await _prefs.clear();
    _settings.clear();
    // Reestablecer valores predeterminados
    _settings['darkMode'] = false;
    _settings['language'] = 'Español';
    _settings['emailNotifications'] = true;
    _settings['pushNotifications'] = true;
    _settings['shareData'] = false;
    notifyListeners();
  }

  /// Función de cierre de sesión
  Future<void> logout() async {
    // Implementa aquí la lógica de cierre de sesión, como eliminar tokens, limpiar datos, etc.
    await resetSettings();
    // Otros pasos necesarios para cerrar sesión
  }
}
