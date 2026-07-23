import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_personal_asst/main.dart';
import 'package:ai_personal_asst/viewmodels/connectivity_viewmodel.dart';
import 'package:ai_personal_asst/viewmodels/model_viewmodel.dart';
import 'package:ai_personal_asst/viewmodels/workflow_viewmodel.dart';
import 'package:ai_personal_asst/viewmodels/coach_viewmodel.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app wrapped with MultiProvider and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityViewModel()),
          ChangeNotifierProvider(create: (_) => ModelViewModel()),
          ChangeNotifierProvider(create: (_) => WorkflowViewModel()),
          ChangeNotifierProvider(create: (_) => CoachViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the App Locked screen is present.
    expect(find.text('App Locked'), findsOneWidget);
    expect(find.text('Unlock App'), findsOneWidget);
  });
}
