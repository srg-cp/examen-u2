import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/presentation/widgets/startup_reveal.dart';
import 'router.dart';

class EntreHuellasApp extends ConsumerWidget {
  const EntreHuellasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Entre Huellas',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    builder: (context, child) => StartupReveal(child: child!),
    routerConfig: ref.watch(routerProvider),
  );
}
