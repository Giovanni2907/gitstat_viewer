import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/theme/providers/theme_provider.dart';
import 'package:gitstat_viewer/features/forms/authentification_form.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'GitStat Viewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child:Text('GitStats - Viewer',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'Times New Roman',
              ),
            ),  
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.outline,
        body: Center(
          child: SizedBox(
            height: 300,
            width: 500,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.white70],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  ),
              ),
              child: AuthentificationForm(),
              ),
            ),
          ),
      ),
    );
  }
}