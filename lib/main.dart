import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/vellum_theme.dart';
import 'data/repositories/poem_repository.dart';
import 'presentation/daily_sanctuary/daily_sanctuary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = PoemRepository();
  await repository.getAllPoems(); // Prewarm cache

  runApp(
    ProviderScope(
      child: VellumApp(repository: repository),
    ),
  );
}

class VellumApp extends StatelessWidget {
  final PoemRepository repository;
  const VellumApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vellum',
      debugShowCheckedModeBanner: false,
      theme: VellumTheme.lightTheme,
      darkTheme: VellumTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: DailySanctuaryScreen(repository: repository),
    );
  }
}
