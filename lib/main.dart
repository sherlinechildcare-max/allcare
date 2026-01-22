import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env/supabase_env.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseEnv.supabaseUrl,
    anonKey: SupabaseEnv.supabaseAnonKey,
  );

  runApp(const AllCareApp());
}

class AllCareApp extends StatelessWidget {
  const AllCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRouter.router,
    );
  }
}
