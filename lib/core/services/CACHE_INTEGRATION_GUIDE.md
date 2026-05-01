# Guide d'Intégration du Cache - Étape par Étape

## ✅ Étape 1 : Vérification (DÉJÀ FAIT)

Le cache est maintenant intégré dans votre application :

- ✅ `shared_preferences: ^2.5.5` installé
- ✅ `lib/core/services/cache_service.dart` créé
- ✅ `lib/providers/cache_provider.dart` créé
- ✅ `main.dart` mise à jour avec initialisation du cache
- ✅ Extensions pour accès facile ajoutées

## ✅ Étape 2 : Vérification du Build

Lancez pour vérifier que tout compile correctement :

```powershell
cd C:\Users\nauti\Projects\kairos
flutter pub get
flutter run
```

## 🎯 Étape 3 : Utilisation Simple (Commencez ici)

### 3.1 Sauvegarder et récupérer une valeur

```dart
// Dans n'importe quel widget, n'importe quelle fonction

// Sauvegarder
await context.cacheSet('my_key', 'my_value');

// Récupérer
final value = context.cacheGet<String>('my_key');
print(value); // Output: my_value
```

### 3.2 Exemple : Préférence de thème

```dart
// Sauvegarder quand l'utilisateur change de thème
void toggleTheme(BuildContext context) {
  // ... votre logique de toggle ...
  
  // Sauvegarder la préférence
  final isDark = /* votre logique */;
  await context.cacheSet('user_theme', isDark ? 'dark' : 'light');
}

// Charger au démarrage
@override
void initState() {
  super.initState();
  final theme = context.cacheGet<String>('user_theme');
  if (theme != null) {
    // Appliquer le thème sauvegardé
  }
}
```

## 🔧 Étape 4 : Intégration avec les Providers (Avancé)

### 4.1 Intégrer avec BirthdayProvider

Ouvrez `lib/providers/birthday_provider.dart` et modifiez :

```dart
import 'package:flutter/foundation.dart';
import '../core/services/cache_service.dart';

class BirthdayProvider extends ChangeNotifier {
  late CacheService _cache;
  List<Birthday> _birthdays = [];

  List<Birthday> get birthdays => _birthdays;

  // NOUVEAU: Initialiser avec le cache
  void initializeWithCache(CacheService cache) {
    _cache = cache;
    _loadFromCache();
  }

  // NOUVEAU: Charger depuis le cache
  void _loadFromCache() {
    final cached = _cache.getList<Birthday>(
      'upcoming_birthdays',
      (json) => Birthday.fromJson(json),
    );
    if (cached != null) {
      _birthdays = cached;
      notifyListeners();
    }
  }

  // MODIFIER: Quand vous chargez les anniversaires
  Future<void> loadBirthdays() async {
    // ... votre code existant ...
    
    // AJOUTER: Mettre en cache les prochains anniversaires
    final upcoming = _birthdays
      .where((b) => b.daysUntilBirthday <= 30)
      .toList();
    
    if (upcoming.isNotEmpty) {
      await _cache.setList('upcoming_birthdays', upcoming);
    }
  }
}
```

### 4.2 Initialiser les providers avec le cache dans main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le cache
  final cacheProvider = CacheProvider();
  await cacheProvider.init();
  final cacheService = cacheProvider.cache;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await NotificationService.instance.initialize();

  // NOUVEAU: Initialiser les providers avec le cache
  final birthdayProvider = BirthdayProvider();
  birthdayProvider.initializeWithCache(cacheService);
  
  final userProvider = UserProvider();
  userProvider.initializeWithCache(cacheService);

  // ... autres initializations ...

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cacheProvider),
        ChangeNotifierProvider.value(value: birthdayProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: ThemeProvider()),
        ChangeNotifierProvider.value(value: AuthProvider()),
      ],
      child: const App(),
    ),
  );
}
```

## 📱 Étape 5 : Cas d'usage typiques pour an_ki

### Cas 1 : Anniversaires à venir (rapide accès)

```dart
// Charger depuis le cache d'abord
List<Birthday> getUpcomingBirthdays(BuildContext context) {
  // Essayer le cache d'abord (instantané)
  final cached = context.cacheGet<List<String>>('upcoming_birthdays');
  if (cached != null) {
    return cached
      .map((jsonStr) => Birthday.fromJson(jsonDecode(jsonStr)))
      .toList();
  }
  
  // Sinon, charger depuis Firestore
  return context.read<BirthdayProvider>().getUpcoming();
}
```

### Cas 2 : Dernière session utilisateur

```dart
// Sauvegarder à la connexion
void onLoginSuccess(String userId) async {
  await context.cacheSet('last_user_id', userId);
  await context.cacheSet('login_time', DateTime.now().toIso8601String());
}

// Vérifier au démarrage
void checkLastSession(BuildContext context) {
  final lastUserId = context.cacheGet<String>('last_user_id');
  if (lastUserId != null) {
    print('Utilisateur $lastUserId détecté - reconnexion auto');
    // Implémenter la reconnexion automatique
  }
}
```

### Cas 3 : Préférences utilisateur

```dart
// Sauvegarder les notifications
void updateNotificationSettings(bool enabled) async {
  await context.cacheSet('notifications_enabled', enabled);
  await context.cacheSet('last_notification_pref_change', DateTime.now().toIso8601String());
}

// Charger au démarrage
bool getNotificationsSetting(BuildContext context) {
  return context.cacheGet<bool>('notifications_enabled') ?? true;
}
```

## 🚀 Étape 6 : Performance et Optimisation

### Mesurez la performance

```dart
import 'dart:async';

Future<void> measureCachePerformance(BuildContext context) async {
  final cache = context.cache;
  
  // Mesurer write
  final writeStart = DateTime.now();
  await cache.set('test_key', 'test_value');
  final writeDuration = DateTime.now().difference(writeStart);
  print('Write: ${writeDuration.inMilliseconds}ms');
  
  // Mesurer read
  final readStart = DateTime.now();
  cache.get<String>('test_key');
  final readDuration = DateTime.now().difference(readStart);
  print('Read: ${readDuration.inMicroseconds}µs');
}
```

### Monitorer la taille du cache

```dart
void monitorCacheSize(BuildContext context) {
  final cache = context.cache;
  final size = cache.getSize();
  print('Cache size: $size entries');
  
  if (size > 100) {
    print('⚠️ Cache is getting large, consider clearing old entries');
  }
}
```

## 🧹 Étape 7 : Maintenance

### Nettoyer le cache périodiquement

```dart
// À ajouter dans votre logout ou dans une fonction de maintenance
Future<void> clearCacheOnLogout(BuildContext context) async {
  await context.cacheRemove('last_user_id');
  await context.cacheRemove('login_time');
  await context.cacheRemove('session_token');
  // Gardez les préférences utilisateur non-sensibles
}

// Ou vider complètement
Future<void> resetAllCache(BuildContext context) async {
  await context.cache.clear();
  print('Cache completely cleared');
}
```

## 🔍 Étape 8 : Debug

### Inspecter le cache

```dart
void inspectCache(BuildContext context) {
  final cache = context.cache;
  final keys = cache.getAllKeys();
  
  print('=== CACHE CONTENT ===');
  for (final key in keys) {
    final value = cache.get(key);
    print('$key: $value (${value.runtimeType})');
  }
  print('=== TOTAL: ${keys.length} entries ===');
}
```

### Ajouter du logging

```dart
// Modifier cache_service.dart pour ajouter du logging
Future<void> set<T>(String key, T value) async {
  print('[CACHE] Setting $key = $value');
  // ... reste du code ...
}

T? get<T>(String key) {
  final value = _memoryCache[key] as T?;
  print('[CACHE] Getting $key = $value');
  return value;
}
```

## ✨ Étape 9 : Tester

### Test unitaire simple

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:an_ki/core/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cache;

    setUp(() async {
      cache = CacheService();
      await cache.init();
    });

    tearDown(() async {
      await cache.clear();
    });

    test('should store and retrieve value', () async {
      await cache.set('key', 'value');
      expect(cache.get<String>('key'), equals('value'));
    });

    test('should return default value if key not found', () {
      expect(cache.getOrDefault<String>('nonexistent', 'default'), equals('default'));
    });

    test('should check if key exists', () async {
      await cache.set('key', 'value');
      expect(cache.contains('key'), isTrue);
      expect(cache.contains('other'), isFalse);
    });
  });
}
```

## 📊 Résumé des Fichiers Créés

| Fichier | Rôle |
|---------|------|
| `lib/core/services/cache_service.dart` | Service principal du cache |
| `lib/providers/cache_provider.dart` | Provider pour intégration |
| `lib/main.dart` | Mise à jour initialisation |
| `CACHE_README.md` | Documentation complète |
| `CACHE_USAGE_EXAMPLE.dart` | Exemples d'utilisation |
| `CACHE_INTEGRATION_EXAMPLE.dart` | Exemples d'intégration |

## 🎓 Prochaines Étapes

1. ✅ **Immédiat**: Testez avec `flutter run` et utilisez `context.cacheSet/Get`
2. 🔧 **Court terme**: Intégrez avec BirthdayProvider (anniversaires à venir)
3. 📈 **Moyen terme**: Intégrez avec UserProvider (session utilisateur)
4. 🚀 **Long terme**: Optimisez les requêtes Firestore avec le cache
5. 🧪 **Maintenance**: Ajoutez des tests unitaires pour le cache

## ❓ FAQ

**Q: Le cache est-il automatiquement sauvegardé?**
R: Oui, chaque `set()` met à jour la mémoire instantanément ET sauvegarde sur le disque avec SharedPreferences.

**Q: Les données persistent après un restart?**
R: Oui, SharedPreferences persiste entre les sessions.

**Q: Puis-je cacher des données sensibles?**
R: Non recommandé - SharedPreferences n'est pas chiffré. Utilisez `flutter_secure_storage` pour les données sensibles.

**Q: Comment vider le cache?**
R: `await context.cache.clear()` pour tout, ou `await context.cacheRemove('key')` pour une clé spécifique.

**Q: Quel est la limite de taille?**
R: Environ 1MB par SharedPreferences. Pour plus, considérez une base de données locale.

---

Vous êtes prêt ! Commencez par l'étape 3 et progressez graduellement. 🚀

