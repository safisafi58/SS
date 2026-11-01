import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AiPromptApp());
}

class AiPromptApp extends StatelessWidget {
  const AiPromptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI PROMPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkPremium,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
