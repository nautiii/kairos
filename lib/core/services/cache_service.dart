import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache générique utilisant SharedPreferences
/// Permet un cache instantané en mémoire et stockage persistant
class CacheService {
  static const String _cachePrefix = 'an_ki_cache_';
  late SharedPreferences _prefs;
  final Map<String, dynamic> _memoryCache = {};

  /// Initialise le service de cache
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAllFromStorage();
  }

  /// Charge tous les éléments du stockage dans le cache mémoire
  Future<void> _loadAllFromStorage() async {
    _memoryCache.clear();
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        final cleanKey = _removePrefix(key);
        _memoryCache[cleanKey] = _prefs.get(key);
      }
    }
  }

  /// Ajoute la clé au cache (mémoire et stockage)
  String _addPrefix(String key) => '$_cachePrefix$key';

  /// Supprime la clé du cache
  String _removePrefix(String key) => key.replaceFirst(_cachePrefix, '');

  /// Sauvegarde une valeur (instantanée en mémoire, persistante en stockage)
  Future<void> set<T>(String key, T value) async {
    // Cache mémoire instantané
    _memoryCache[key] = value;

    // Sauvegarde persistante
    final prefixedKey = _addPrefix(key);
    if (value is String) {
      await _prefs.setString(prefixedKey, value);
    } else if (value is int) {
      await _prefs.setInt(prefixedKey, value);
    } else if (value is double) {
      await _prefs.setDouble(prefixedKey, value);
    } else if (value is bool) {
      await _prefs.setBool(prefixedKey, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(prefixedKey, value);
    } else {
      // Pour les objets complexes, sérialiser en JSON
      await _prefs.setString(prefixedKey, jsonEncode(value));
    }
  }

  /// Récupère une valeur du cache (instantané)
  T? get<T>(String key) {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as T?;
    }
    return null;
  }

  /// Récupère une valeur avec valeur par défaut
  T getOrDefault<T>(String key, T defaultValue) {
    return get<T>(key) ?? defaultValue;
  }

  /// Vérifie si une clé existe dans le cache
  bool contains(String key) {
    return _memoryCache.containsKey(key);
  }

  /// Supprime une valeur du cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs.remove(_addPrefix(key));
  }

  /// Vide complètement le cache
  Future<void> clear() async {
    _memoryCache.clear();
    await _prefs.clear();
  }

  /// Obtient toutes les clés du cache
  List<String> getAllKeys() {
    return _memoryCache.keys.toList();
  }

  /// Obtient la taille du cache (en nombre d'éléments)
  int getSize() {
    return _memoryCache.length;
  }

  /// Sauvegarde une liste d'objets sérialisés
  Future<void> setList<T>(String key, List<T> items) async {
    final encoded = items.map((item) => jsonEncode(item)).toList();
    await set<List<String>>(key, encoded);
  }

  /// Récupère une liste d'objets sérialisés
  List<T>? getList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final encoded = get<List<String>>(key);
    if (encoded == null) return null;

    try {
      return encoded
          .map((item) => fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde un objet sérialisé
  Future<void> setObject<T>(String key, T object) async {
    await set<String>(key, jsonEncode(object));
  }

  /// Récupère un objet sérialisé
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final json = get<String>(key);
    if (json == null) return null;

    try {
      return fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}

