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
  ],
);