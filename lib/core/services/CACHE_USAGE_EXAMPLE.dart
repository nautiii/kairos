/// EXEMPLE D'UTILISATION DU CACHE SERVICE
///
/// Le CacheService offre un cache instantané en mémoire + stockage persistant
/// avec SharedPreferences.
///
/// ============================================================================
///
/// 1. ACCÈS AU CACHE DEPUIS UN WIDGET
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Utiliser l'extension pour accéder simplement au cache
///     return ElevatedButton(
///       onPressed: () async {
///         // Sauvegarder une valeur
///         await context.cacheSet('my_key', 'my_value');
///
///         // Récupérer une valeur
///         final value = context.cacheGet<String>('my_key');
///
///         // Vérifier si une clé existe
///         if (context.cacheContains('my_key')) {
///           print('La clé existe');
///         }
///
///         // Supprimer une valeur
///         await context.cacheRemove('my_key');
///       },
///       child: const Text('Utiliser le cache'),
///     );
///   }
/// }
/// ```
///
/// ============================================================================
///
/// 2. SAUVEGARDER DIFFÉRENTS TYPES DE DONNÉES
///
/// ```dart
/// // String
/// await cache.set('username', 'john_doe');
///
/// // Nombre entier
/// await cache.set('user_age', 25);
///
/// // Nombre décimal
/// await cache.set('height', 1.75);
///
/// // Booléen
/// await cache.set('notifications_enabled', true);
///
/// // Liste de strings
/// await cache.set('favorite_colors', ['red', 'blue', 'green']);
///
/// // Objet personnalisé (sérialisé en JSON)
/// class User {
///   String name;
///   int age;
///   User({required this.name, required this.age});
///   Map<String, dynamic> toJson() => {'name': name, 'age': age};
/// }
/// await cache.setObject('user', User(name: 'John', age: 25));
/// final user = cache.getObject<User>('user', (json) =>
///   User(name: json['name'], age: json['age'])
/// );
/// ```
///
/// ============================================================================
///
/// 3. UTILISER AVEC SHARED PREFERENCES
///
/// ```dart
/// // À la place de context.cache, vous pouvez aussi récupérer
/// // directement le provider:
/// final cacheProvider = context.read<CacheProvider>();
/// final cacheService = cacheProvider.cache;
///
/// // Puis utiliser exactement comme ci-dessus:
/// await cacheService.set('key', 'value');
/// final value = cacheService.get<String>('key');
/// ```
///
/// ============================================================================
///
/// 4. GESTION DU CACHE COMPLET
///
/// ```dart
/// // Récupérer toutes les clés
/// final keys = cache.getAllKeys();
///
/// // Obtenir la taille du cache
/// final size = cache.getSize();
///
/// // Vider complètement le cache
/// await cache.clear();
/// ```
///
/// ============================================================================
///
/// 5. CAS D'USAGE PRATIQUES POUR VOTRE APP (an_ki - Anniversaires)
///
/// a) Mettre en cache les préférences utilisateur:
///
/// ```dart
/// // Sauvegarder quand l'utilisateur change de paramètre
/// await context.cacheSet('theme_mode', 'dark');
/// await context.cacheSet('notifications_enabled', true);
/// await context.cacheSet('language', 'fr');
/// ```
///
/// b) Cache des anniversaires récents:
///
/// ```dart
/// class Birthday {
///   String name;
///   DateTime date;
///   Birthday({required this.name, required this.date});
///   Map<String, dynamic> toJson() => {
///     'name': name,
///     'date': date.toIso8601String(),
///   };
/// }
///
/// // Sauvegarder plusieurs anniversaires
/// final birthdays = [
///   Birthday(name: 'Alice', date: DateTime(1990, 5, 15)),
///   Birthday(name: 'Bob', date: DateTime(1995, 10, 20)),
/// ];
/// await cache.setList('birthdays', birthdays);
///
/// // Récupérer
/// final cached = cache.getList<Birthday>(
///   'birthdays',
///   (json) => Birthday(
///     name: json['name'],
///     date: DateTime.parse(json['date']),
///   ),
/// );
/// ```
///
/// c) Cache du dernier utilisateur connecté:
///
/// ```dart
/// // Après login réussi
/// await context.cacheSet('last_user_id', userId);
///
/// // Au démarrage, vérifier s'il y a un utilisateur en cache
/// final lastUserId = context.cacheGet<String>('last_user_id');
/// if (lastUserId != null) {
///   // Connecter automatiquement l'utilisateur
/// }
/// ```
///
/// ============================================================================
///
/// 6. CARACTÉRISTIQUES IMPORTANTES
///
/// ✅ Cache instantané en mémoire (aucune latence)
/// ✅ Stockage persistant avec SharedPreferences
/// ✅ Support de types simples (String, int, double, bool)
/// ✅ Support de listes et objets complexes (sérialisés en JSON)
/// ✅ Initialisation automatique au démarrage de l'app
/// ✅ Accès facile via extension (context.cacheGet, context.cacheSet, etc.)
/// ✅ Gestion complète (clear, contains, getSize, etc.)
///
/// ============================================================================

