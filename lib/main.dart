import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('MAIN STEP 1: binding initialized');

  try {
    debugPrint('MAIN STEP 2: DI start');
    await DependencyInjection.init();
    debugPrint('MAIN STEP 3: DI completed');

    debugPrint('MAIN STEP 4: theme load start');
    await AppThemeController.instance.load();
    debugPrint('MAIN STEP 5: theme load completed');
  } catch (e, st) {
    debugPrint('MAIN STARTUP ERROR: $e');
    debugPrint('$st');
  }

  debugPrint('MAIN STEP 6: runApp');
  runApp(const App());
}
