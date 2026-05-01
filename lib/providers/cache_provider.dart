import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/cache_service.dart';

/// ChangeNotifier pour gérer le service de cache
class CacheProvider extends ChangeNotifier {
  late CacheService _cacheService;
  bool _isInitialized = false;

  CacheService get cache => _cacheService;

  bool get isInitialized => _isInitialized;

  /// Initialise le service de cache
  Future<void> init() async {
    if (_isInitialized) return;

    _cacheService = CacheService();
    await _cacheService.init();
    _isInitialized = true;
    notifyListeners();
  }

  /// Réinitialise le cache
  Future<void> reset() async {
    await _cacheService.clear();
    notifyListeners();
  }
}

/// Extension pour accéder facilement au cache depuis les widgets
extension CacheExtension on BuildContext {
  CacheService get cache {
    final provider = read<CacheProvider>();
    return provider.cache;
  }

  /// Définir une valeur en cache
  Future<void> cacheSet<T>(String key, T value) async {
    await read<CacheProvider>().cache.set(key, value);
  }

  /// Récupérer une valeur du cache
  T? cacheGet<T>(String key) {
    return read<CacheProvider>().cache.get<T>(key);
  }

  /// Vérifier si une clé existe
  bool cacheContains(String key) {
    return read<CacheProvider>().cache.contains(key);
  }

  /// Supprimer une clé
  Future<void> cacheRemove(String key) async {
    await read<CacheProvider>().cache.remove(key);
  }
}


