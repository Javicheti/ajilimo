import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';

import 'router.dart';

class KornApp extends StatelessWidget {
  const KornApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AjíLimo KORN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: kornRouter,
    );
  }
}
