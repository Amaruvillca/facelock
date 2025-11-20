import 'package:facelock/config/router/app_router.dart';
import 'package:facelock/config/service/fcm_service.dart';
import 'package:facelock/config/theme/app_theme.dart';
import 'package:facelock/presentation/provider/jwt/auth_notifier_provider.dart';
 // Importa tu auth provider
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Creamos un ProviderContainer global para inicializar antes del runApp
final providerContainer = ProviderContainer();

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FCMService.initializeFCM();
  //FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  // Cargar el token almacenado al iniciar la app
  await FCMService.checkBackgroundCapabilities();
  await providerContainer.read(authProvider.notifier).loadToken();
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Usamos el container que ya inicializamos
      parent: providerContainer,
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'FaceLock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(),
      ),
    );
  }
}