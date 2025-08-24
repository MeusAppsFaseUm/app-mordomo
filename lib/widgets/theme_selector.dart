import 'package:flutter/material.dart';

import '../core/themes.dart';

class ThemeSelector extends StatelessWidget {
  final int currentThemeIndex;
  final Function(int) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentThemeIndex,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(AppThemes.allThemes.length, (i) {
          final sel = i == currentThemeIndex;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: CircleAvatar(backgroundColor: AppThemes.themeColors[i]),
              title: Text(AppThemes.themeNames[i]),
              trailing: sel ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () => onThemeChanged(i),
            ),
          );
        }),
      );
}
