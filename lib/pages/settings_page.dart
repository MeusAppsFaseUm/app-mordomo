import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/theme_selector.dart';

class SettingsPage extends StatelessWidget {
  final Function(int) onThemeChanged;
  final int currentThemeIndex;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Seleção de tema
          ThemeSelector(
            currentThemeIndex: currentThemeIndex,
            onThemeChanged: onThemeChanged,
          ),
          const SizedBox(height: 32),
          const Divider(),

          // Email de contato
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('E-mail de contato'),
            subtitle: const Text('angelofel@hotmail.com'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: 'angelofel@hotmail.com'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('E-mail copiado!')),
                );
              },
            ),
          ),
          const Divider(),

          // Pix do desenvolvedor
          ListTile(
            leading: Icon(
              Icons
                  .pix, // Se não tiver esse ícone, troque por Icons.account_balance_wallet.
              color: Colors.green,
            ),
            title: const Text('Ajude o desenvolvedor (PIX)'),
            subtitle: const Text('24642660860'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '24642660860'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chave PIX copiada!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
