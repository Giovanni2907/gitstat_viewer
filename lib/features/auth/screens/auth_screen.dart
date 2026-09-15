import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/theme/providers/theme_provider.dart';
import 'package:gitstat_viewer/features/auth/forms/authentification_form.dart';

class AuthScreen extends ConsumerWidget {

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('GitStats', style: TextStyle(fontSize: 12)),
            )
          ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.light_mode, size: 16.0),
            onPressed: (){ref.read(themeModeProvider.notifier).state = ThemeMode.light;},
            label: const Text('Light')
            ),
          const SizedBox(width: 8,),
          ElevatedButton.icon(
            icon: const Icon(Icons.dark_mode),
            onPressed: (){ref.read(themeModeProvider.notifier).state = ThemeMode.dark;},
            label: const Text('Dark'),
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12.0)),
                const Text('To the', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 12.0)),
                const Text('Gitstats Viewer', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 20.0)),
              ],
            ),
          ), 
          const Expanded(
            flex: 2,
            child: AuthentificationForm(),
          ),
        ],  
      ),
    );
  }
}