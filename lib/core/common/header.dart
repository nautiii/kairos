import 'package:an_ki/data/models/user_model.dart';
import 'package:an_ki/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = context.watch<UserProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bonjour 👋", style: TextStyle(color: colorScheme.onSurfaceVariant)),
            user == null
                ? const Center(child: CircularProgressIndicator())
                : Text(
                  "${user.surname} ${user.name}",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Icon(Icons.cake_outlined, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
