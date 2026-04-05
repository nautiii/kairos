import 'dart:async';

import 'package:an_ki/core/app_initializer.dart';
import 'package:an_ki/data/models/user_model.dart';
import 'package:an_ki/data/repositories/user_repository.dart';
import 'package:an_ki/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AppInitializer loads the user after the first frame', (
    WidgetTester tester,
  ) async {
    final FakeUserRepository repository = FakeUserRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>(
        create: (_) => UserProvider(),
        child: const MaterialApp(home: AppInitializer(child: TestChild())),
      ),
    );

    expect(find.text('Child ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pump();

    expect(repository.receivedName, 'Maillard');
    expect(repository.receivedSurname, 'Quentin');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Child ready'), findsNothing);
    expect(tester.takeException(), isNull);

    repository.complete();
    await tester.pump();

    expect(find.text('Child ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class FakeUserRepository extends UserRepository {
  final Completer<UserModel?> _completer = Completer<UserModel?>();

  String? receivedName;
  String? receivedSurname;

  @override
  Future<UserModel?> fetchUser({
    required String name,
    required String surname,
  }) {
    receivedName = name;
    receivedSurname = surname;
    return _completer.future;
  }

  void complete([UserModel? user]) {
    if (!_completer.isCompleted) {
      _completer.complete(user);
    }
  }
}

class TestChild extends StatelessWidget {
  const TestChild({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Child ready')));
  }
}
