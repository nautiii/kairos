import 'package:an_ki/core/app_initializer.dart';
import 'package:an_ki/data/models/birthday_model.dart';
import 'package:an_ki/data/models/create_birthday_input.dart';
import 'package:an_ki/data/models/user_model.dart';
import 'package:an_ki/data/repositories/birthday_repository.dart';
import 'package:an_ki/data/repositories/user_repository.dart';
import 'package:an_ki/features/birthday/home_page.dart';
import 'package:an_ki/providers/birthday_provider.dart';
import 'package:an_ki/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'HomePage opens the create birthday page from the floating button',
    (WidgetTester tester) async {
      final FakeBirthdayRepository repository = FakeBirthdayRepository();

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_TestApp(repository: repository));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Nouvel anniversaire'), findsOneWidget);
    },
  );

  testWidgets('Create birthday flow submits a new birthday to the provider', (
    WidgetTester tester,
  ) async {
    final FakeBirthdayRepository repository = FakeBirthdayRepository();

    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_TestApp(repository: repository));
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Thomas');
    await tester.enterText(find.byType(TextFormField).last, 'Leroy');

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(repository.createdInputs, hasLength(1));
    expect(repository.createdInputs.single.name, 'Thomas');
    expect(repository.createdInputs.single.surname, 'Leroy');
    expect(repository.createdInputs.single.category, BirthdayCategory.friend);
    expect(find.text('Nouvel anniversaire'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.repository});

  final FakeBirthdayRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<BirthdayProvider>(
          create: (_) => BirthdayProvider(repository),
        ),
      ],
      child: const MaterialApp(home: AppInitializer(child: HomePage())),
    );
  }
}

class FakeBirthdayRepository extends BirthdayRepository {
  final List<CreateBirthdayInput> createdInputs = <CreateBirthdayInput>[];

  @override
  Stream<List<BirthdayModel>> watchBirthdays() {
    return Stream<List<BirthdayModel>>.value(const <BirthdayModel>[]);
  }

  @override
  Future<void> createBirthday(CreateBirthdayInput input) async {
    createdInputs.add(input);
  }
}

class FakeUserRepository extends UserRepository {
  @override
  Future<UserModel?> fetchUser({
    required String name,
    required String surname,
  }) async {
    return const UserModel(id: '1', name: 'Marie', surname: 'Martin');
  }
}
