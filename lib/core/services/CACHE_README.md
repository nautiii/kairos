# Cache Service - Documentation

## Vue d'ensemble

Le **CacheService** fournit un système de cache instantané et persistant pour l'application an_ki. Il combine :

- 🚀 **Cache mémoire instantané** : accès immédiat aux données sans latence
- 💾 **Stockage persistant** : données sauvegardées avec SharedPreferences
- 📦 **Supports multiples types** : String, int, double, bool, List, et objets JSON
- 🎯 **API simple** : accès facile via extension `context.cache*`

## Architecture

```
┌─────────────────────────────────────────────┐
│         Application (Widgets)               │
├─────────────────────────────────────────────┤
│  CacheProvider (ChangeNotifier)             │
│  - Gère l'état du cache                     │
│  - Accessible via context.read/watch        │
├─────────────────────────────────────────────┤
│  CacheService (Logique métier)              │
│  - Sync mémoire + SharedPreferences         │
│  - Opérations CRUD                          │
│  - Sérialisation JSON                       │
├─────────────────────────────────────────────┤
│  SharedPreferences (Stockage persistant)    │
│  - Données persistantes entre sessions      │
│  - Format clé-valeur                        │
└─────────────────────────────────────────────┘
```

## Utilisation

### 1. Accès les plus simples via Extension

```dart
// Dans un widget avec context
// Sauvegarder
await context.cacheSet('user_theme', 'dark');

// Récupérer
final theme = context.cacheGet<String>('user_theme');

// Vérifier l'existence
if (context.cacheContains('user_theme')) {
  print('Theme trouvé');
}

// Supprimer
await context.cacheRemove('user_theme');
```

### 2. Accès direct au CacheService

```dart
final cacheService = context.cache;

// Mêmes opérations
await cacheService.set('key', 'value');
final value = cacheService.get<String>('key');
final withDefault = cacheService.getOrDefault('key', 'default_value');
```

### 3. Travailler avec des objets

```dart
class Birthday {
  final String name;
  final DateTime date;
  
  Birthday({required this.name, required this.date});
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
  };
  
  factory Birthday.fromJson(Map<String, dynamic> json) {
    return Birthday(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

// Sauvegarder un objet
final birthday = Birthday(name: 'Alice', date: DateTime(1990, 5, 15));
await context.cache.setObject('favorite_birthday', birthday);

// Récupérer
final cached = context.cache.getObject<Birthday>(
  'favorite_birthday',
  (json) => Birthday.fromJson(json),
);
```

### 4. Travailler avec des listes

```dart
// Sauvegarder une liste
final birthdays = [
  Birthday(name: 'Alice', date: DateTime(1990, 5, 15)),
  Birthday(name: 'Bob', date: DateTime(1995, 10, 20)),
];
await context.cache.setList('all_birthdays', birthdays);

// Récupérer
final cached = context.cache.getList<Birthday>(
  'all_birthdays',
  (json) => Birthday.fromJson(json),
);
```

## Cas d'usage pour an_ki

### Préférences utilisateur
```dart
// Au démarrage, charger les préférences depuis le cache
class SettingsWidget extends StatefulWidget {
  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();
    // Récupérer du cache ou utiliser une valeur par défaut
    notificationsEnabled = context.cacheGet<bool>('notifications_enabled') ?? true;
  }

  void toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
    // Sauvegarder le changement
    context.cacheSet('notifications_enabled', notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: notificationsEnabled,
      onChanged: (_) => toggleNotifications(),
    );
  }
}
```

### Session utilisateur
```dart
// Après connexion
void handleLoginSuccess(String userId) async {
  await context.cacheSet('current_user_id', userId);
  await context.cacheSet('session_started', DateTime.now().toIso8601String());
}

// Au démarrage
void checkExistingSession() {
  final userId = context.cacheGet<String>('current_user_id');
  if (userId != null) {
    // Reconnecter automatiquement
    authProvider.autoLogin(userId);
  }
}
```

### Cache des anniversaires fréquemment consultés
```dart
// Après chargement depuis Firestore
void cacheImportantBirthdays(List<Birthday> birthdays) async {
  final important = birthdays
    .where((b) => b.daysUntilBirthday <= 30)
    .toList();
  
  await context.cache.setList('upcoming_birthdays', important);
}

// Accès rapide sans requête Firestore
List<Birthday>? getUpcomingBirthdaysFromCache() {
  return context.cache.getList<Birthday>(
    'upcoming_birthdays',
    (json) => Birthday.fromJson(json),
  );
}
```

## API Complète

### Opérations de base

```dart
// Sauvegarder (type automatiquement détecté)
await cache.set('key', value);

// Récupérer
final value = cache.get<String>('key');

// Récupérer avec valeur par défaut
final value = cache.getOrDefault<String>('key', 'default');

// Vérifier l'existence
bool exists = cache.contains('key');

// Supprimer
await cache.remove('key');

// Vider complètement
await cache.clear();
```

### Opérations avancées

```dart
// Tous les types supports
cache.set<String>('key', 'value');
cache.set<int>('age', 25);
cache.set<double>('height', 1.75);
cache.set<bool>('active', true);
cache.set<List<String>>('tags', ['flutter', 'cache']);

// Objets sérialisés
await cache.setObject<User>('user', user);
final user = cache.getObject<User>('user', User.fromJson);

// Listes d'objets
await cache.setList<Birthday>('birthdays', birthdays);
final birthdays = cache.getList<Birthday>('birthdays', Birthday.fromJson);

// Gestion du cache
final keys = cache.getAllKeys();
final size = cache.getSize();
```

## Bonnes pratiques

✅ **À faire:**
- Utiliser `context.cacheSet` / `context.cacheGet` dans les widgets
- Initialiser le cache dans `main()` (déjà fait)
- Sauvegarder les préférences utilisateur côté client
- Mettre en cache les données fréquemment consultées
- Supprimer les données sensibles avec `cache.remove()` après logout

❌ **À éviter:**
- Ne pas sauvegarder de données sensibles (tokens) en cache simple
- Ne pas supposer que le cache est persistant entre les mises à jour d'app
- Ne pas bloquer l'UI lors de la sauvegarde en cache (async/await)
- Ne pas modifier les objets après les avoir mis en cache

## Limitations

- Les données sont sérialisées en JSON (utiliser `toJson`/`fromJson`)
- Limite de taille : environ 1MB par SharedPreferences
- Les données ne sont pas chiffrées (ne pas stocker de données sensibles)
- Destruction du cache après suppression de l'application

## Performance

- **Set**: ~1ms (mémoire) + asynchrone pour SharedPreferences
- **Get**: <0.5ms (accès mémoire direct)
- **Init**: ~5ms (charge initiale depuis SharedPreferences)

## Fichiers créés

1. **`lib/core/services/cache_service.dart`** - Service de cache avec logique
2. **`lib/providers/cache_provider.dart`** - Provider pour intégration avec Provider
3. **`lib/main.dart`** - Mis à jour pour initialiser le cache
4. **`CACHE_USAGE_EXAMPLE.dart`** - Exemples d'utilisation
5. **`CACHE_README.md`** - Cette documentation

