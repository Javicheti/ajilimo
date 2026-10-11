import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';

import 'router.dart';

class AjilimoApp extends StatelessWidget {
  const AjilimoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AjíLimo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
