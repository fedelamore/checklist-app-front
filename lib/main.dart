import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/checklist_provider.dart';
import 'screens/checklists_screen.dart';
import 'screens/create_checklist_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChecklistProvider()..loadChecklists(),
      child: MaterialApp(
        title: 'Checklist App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          CreateChecklistScreen.routeName: (_) => const CreateChecklistScreen(),
          ChecklistsScreen.routeName: (_) => const ChecklistsScreen(),
        },
      ),
    );
  }
}
