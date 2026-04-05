import 'package:flutter/material.dart';

class NextBirthdayCard extends StatelessWidget {
  const NextBirthdayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7B5E57), Color(0xFFD6A48F)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Prochain anniversaire",
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "XXXXXX XXXXXX",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Dans 2 jours • 24 Avril",
                  style: TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.cake, color: Colors.white),
        ],
      ),
    );
  }
}
