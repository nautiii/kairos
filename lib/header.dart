import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Bonjour 👋", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 4),
            Text(
              "Marie",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white10,
          child: Icon(Icons.cake_outlined, color: Colors.white),
        ),
      ],
    );
  }
}
