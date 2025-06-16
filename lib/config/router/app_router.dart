import 'package:go_router/go_router.dart';
import 'package:facelock/presentation/screens/screens.dart';

final appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return LoginScreen();
      },

    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomeScreen();
      },

    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return RegisterScreen();
      },

    ),
     GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final imagePath = state.extra as String; // Recibimos la ruta de la imagen
        return SearchResultsScreen(imagePath: imagePath);
      },
    ),
     GoRoute(
      path: '/welcome',
      builder: (context, state) => WelcomeScreen(
        userData: state.extra as Map<String, dynamic>,
      ),
    ),
  ],
);