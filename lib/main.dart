import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/community_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RecipeRushApp());
}

class RecipeRushApp extends StatelessWidget {
  const RecipeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppText.appName,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.cream,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.tomato,
          ),
          useMaterial3: true,
          fontFamily: 'Arial',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.cream,
            foregroundColor: AppColors.cocoa,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: AppColors.cocoa,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}