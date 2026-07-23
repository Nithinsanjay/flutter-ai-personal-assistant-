import 'package:ai_personal_asst/views/local_auth_barrier.dart';
import 'package:ai_personal_asst/views/navigation_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:provider/provider.dart';
import 'viewmodels/connectivity_viewmodel.dart';
import 'viewmodels/model_viewmodel.dart';
import 'viewmodels/workflow_viewmodel.dart';
import 'viewmodels/coach_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize(inferenceEngines: [LiteRtLmEngine()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityViewModel()),
        ChangeNotifierProvider(create: (_) => ModelViewModel()..loadModels()),
        ChangeNotifierProvider(create: (_) => WorkflowViewModel()),
        ChangeNotifierProvider(create: (_) => CoachViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Personal Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      home: const LocalAuthBarrier(child: NavigationContainer()),
    );
  }
}
