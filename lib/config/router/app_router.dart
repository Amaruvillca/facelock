import 'package:go_router/go_router.dart';
import 'package:facelock/presentation/screens/screens.dart';

final appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const HomeScreen();
      },
      routes: [
        // Ruta hija de home (será accesible como /home/profile)
        GoRoute(
          path: 'profile', // Nota: no lleva '/' al inicio porque es ruta hija
          builder: (context, state) => const RegistroBiometricoScreen(),
        ),
        GoRoute(
          path: 'registrarbio', // Nota: no lleva '/' al inicio porque es ruta hija
          builder: (context, state) => const RegistrarBiometria(),
        ),
        GoRoute(
          path: 'detalleproducto/:idProducto', // Ruta hija sin '/'
          builder: (context, state) {
            final idProducto = state.pathParameters['idProducto']!; // Operador ! para evitar null
            return DetalleProductoScreen(idProducto: int.parse(idProducto));
          },
        ),
        GoRoute(
          path: 'mapa', // Nota: no lleva '/' al inicio porque es ruta hija
          builder: (context, state) => const MapaScreen(),
        ),
        // Otras rutas hijas de home pueden ir aquí
      ],
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final imagePath =
            state.extra as String; // Recibimos la ruta de la imagen
        return SearchResultsScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/welcome',
      builder:
          (context, state) =>
              WelcomeScreen(userData: state.extra as Map<String, dynamic>),
    ),
  ],
);
