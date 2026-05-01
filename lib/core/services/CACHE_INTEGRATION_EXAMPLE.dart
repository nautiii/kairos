/// INTÉGRATION DU CACHE AVEC LES PROVIDERS EXISTANTS
///
/// Ce fichier montre comment intégrer le CacheService avec vos providers
/// existants (BirthdayProvider, UserProvider, ThemeProvider, etc.)
///
/// ============================================================================
///
/// EXEMPLE 1: INTÉGRER AVEC ThemeProvider
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:provider/provider.dart';
///
/// class ThemeProvider extends ChangeNotifier {
///   late CacheService _cache;
///   ThemeMode _themeMode = ThemeMode.system;
///
///   ThemeMode get themeMode => _themeMode;
///   bool get isDark => _themeMode == ThemeMode.dark;
///
///   /// Initialiser avec le cache
///   void initializeWithCache(CacheService cache) {
///     _cache = cache;
///     // Charger la préférence de thème du cache
///     final savedTheme = _cache.get<String>('theme_mode');
///     if (savedTheme != null) {
///       _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
///     }
///   }
///
///   void toggle(BuildContext context) {
///     final currentlyDark =
///         _themeMode == ThemeMode.dark ||
///         (_themeMode == ThemeMode.system &&
///             MediaQuery.platformBrightnessOf(context) == Brightness.dark);
///
///     _themeMode = currentlyDark ? ThemeMode.light : ThemeMode.dark;
///
///     // Sauvegarder le choix
///     _cache.set('theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
///
///     notifyListeners();
///   }
/// }
/// ```
///
/// ============================================================================
///
/// EXEMPLE 2: INTÉGRER AVEC BirthdayProvider
///
/// ```dart
/// import 'package:flutter/foundation.dart';
///
/// class BirthdayProvider extends ChangeNotifier {
///   late CacheService _cache;
///   List<Birthday> _birthdays = [];
///   static const String _cacheKey = 'upcoming_birthdays';
///
///   List<Birthday> get birthdays => _birthdays;
///
///   /// Initialiser avec le cache
///   void initializeWithCache(CacheService cache) {
///     _cache = cache;
///     _loadFromCache();
///   }
///
///   /// Charger les anniversaires du cache
///   void _loadFromCache() {
///     final cached = _cache.getList<Birthday>(
///       _cacheKey,
///       (json) => Birthday.fromJson(json),
///     );
///
///     if (cached != null && cached.isNotEmpty) {
///       _birthdays = cached;
///       notifyListeners();
///     }
///   }
///
///   /// Ajouter un anniversaire
///   Future<void> addBirthday(Birthday birthday) async {
///     _birthdays.add(birthday);
///
///     // Mettre en cache les 30 prochains jours
///     final upcoming = _birthdays
///       .where((b) => b.daysUntilBirthday <= 30)
///       .toList();
///
///     if (upcoming.isNotEmpty) {
///       await _cache.setList(_cacheKey, upcoming);
///     }
///
///     notifyListeners();
///   }
///
///   /// Récupérer les anniversaires à venir (du cache si possible)
///   List<Birthday> getUpcomingBirthdays() {
///     final cached = _cache.getList<Birthday>(
///       _cacheKey,
///       (json) => Birthday.fromJson(json),
///     );
///
///     return cached ?? _birthdays
///       .where((b) => b.daysUntilBirthday <= 30)
///       .toList();
///   }
///
///   /// Vider le cache lors de la suppression d'un anniversaire
///   Future<void> removeBirthday(String id) async {
///     _birthdays.removeWhere((b) => b.id == id);
///     await _cache.remove(_cacheKey);
///     notifyListeners();
///   }
///
///   /// Forcer la mise en cache des données
///   Future<void> refreshCache() async {
///     final upcoming = _birthdays
///       .where((b) => b.daysUntilBirthday <= 30)
///       .toList();
///
///     if (upcoming.isNotEmpty) {
///       await _cache.setList(_cacheKey, upcoming);
///     } else {
///       await _cache.remove(_cacheKey);
///     }
///   }
/// }
/// ```
///
/// ============================================================================
///
/// EXEMPLE 3: INTÉGRER AVEC UserProvider
///
/// ```dart
/// import 'package:flutter/foundation.dart';
///
/// class UserProvider extends ChangeNotifier {
///   late CacheService _cache;
///   User? _currentUser;
///
///   User? get currentUser => _currentUser;
///
///   /// Initialiser avec le cache
///   void initializeWithCache(CacheService cache) {
///     _cache = cache;
///     _loadUserFromCache();
///   }
///
///   /// Charger l'utilisateur depuis le cache
///   void _loadUserFromCache() {
///     final cached = _cache.getObject<User>(
///       'current_user',
///       (json) => User.fromJson(json),
///     );
///
///     if (cached != null) {
///       _currentUser = cached;
///       notifyListeners();
///     }
///   }
///
///   /// Définir l'utilisateur courant
///   Future<void> setCurrentUser(User user) async {
///     _currentUser = user;
///
///     // Sauvegarder l'utilisateur en cache
///     await _cache.setObject('current_user', user);
///
///     notifyListeners();
///   }
///
///   /// Supprimer l'utilisateur du cache (logout)
///   Future<void> logout() async {
///     _currentUser = null;
///     await _cache.remove('current_user');
///     await _cache.remove('session_token');
///     notifyListeners();
///   }
///
///   /// Sauvegarder le token de session
///   Future<void> saveSessionToken(String token) async {
///     await _cache.set('session_token', token);
///   }
///
///   /// Récupérer le token de session
///   String? getSessionToken() {
///     return _cache.get<String>('session_token');
///   }
/// }
/// ```
///
/// ============================================================================
///
/// EXEMPLE 4: INITIALISER TOUS LES PROVIDERS AVEC LE CACHE
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialiser le cache
///   final cacheProvider = CacheProvider();
///   await cacheProvider.init();
///   final cacheService = cacheProvider.cache;
///
///   await Firebase.initializeApp(
///     options: DefaultFirebaseOptions.currentPlatform,
///   );
///
///   await NotificationService.instance.initialize();
///
///   // Créer les providers
///   final themeProvider = ThemeProvider();
///   final userProvider = UserProvider();
///   final birthdayProvider = BirthdayProvider();
///   final authProvider = AuthProvider();
///
///   // Initialiser avec le cache
///   themeProvider.initializeWithCache(cacheService);
///   userProvider.initializeWithCache(cacheService);
///   birthdayProvider.initializeWithCache(cacheService);
///   // authProvider.initializeWithCache(cacheService); // Si applicable
///
///   runApp(
///     MultiProvider(
///       providers: [
///         ChangeNotifierProvider.value(value: cacheProvider),
///         ChangeNotifierProvider.value(value: themeProvider),
///         ChangeNotifierProvider.value(value: userProvider),
///         ChangeNotifierProvider.value(value: birthdayProvider),
///         ChangeNotifierProvider.value(value: authProvider),
///       ],
///       child: const App(),
///     ),
///   );
/// }
/// ```
///
/// ============================================================================
///
/// CLÉS DE CACHE RECOMMANDÉES
///
/// ```dart
/// // Préférences
/// 'theme_mode'                    // 'dark' ou 'light'
/// 'language'                      // Code de langue
/// 'notifications_enabled'         // bool
///
/// // Utilisateur
/// 'current_user'                  // User object
/// 'session_token'                 // String
/// 'last_user_id'                  // String
///
/// // Anniversaires
/// 'upcoming_birthdays'            // List<Birthday>
/// 'favorite_birthdays'            // List<Birthday>
/// 'recent_birthdays'              // List<Birthday>
///
/// // Session
/// 'session_started'               // ISO 8601 DateTime
/// 'last_sync_time'                // ISO 8601 DateTime
/// ```
///
/// ============================================================================
///
/// BONNES PRATIQUES D'INTÉGRATION
///
/// 1. Initialiser le cache AVANT les providers
/// 2. Passer le cacheService aux providers lors de leur création
/// 3. Charger les données mises en cache au démarrage
/// 4. Mettre à jour le cache quand les données changent
/// 5. Nettoyer le cache lors de l'expiration des sessions
/// 6. Utiliser des clés cohérentes et bien nommées
/// 7. Documenter les données cachées dans chaque provider
/// 8. Tester la mise en cache avec des tests unitaires
///
/// ============================================================================

