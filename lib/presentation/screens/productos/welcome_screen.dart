// 🎯 WelcomeScreen con Riverpod
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/config/service/fcm_service.dart';
import 'package:facelock/presentation/provider/cliente/cliente_provider.dart';
import 'package:facelock/presentation/provider/jwt/auth_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:facelock/domain/entities/clientes.dart';


class WelcomeScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;
  const WelcomeScreen({super.key, required this.userData});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
    late Future<Map<String, dynamic>> _defaultUserJsonFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _lottieAnimations = [
    'assets/welcome2.json',
    'assets/face.json',
    'assets/busqueda.json',
    'assets/welcome.json',
  ];

  final List<Map<String, String>> _pageContents = [
    {
      'title': '¡Registro exitoso!',
      'subtitle': 'Bienvenido/a a FaceLock',
    },
    {
      'title': 'Seguridad Avanzada',
      'subtitle': 'Protección biométrica de siguiente nivel',
    },
    {
      'title': 'Acceso sin esfuerzo',
      'subtitle': 'Tu rostro es tu llave',
    },
    {
      'title': 'Comienza ahora',
      'subtitle': 'Todo listo para usar FaceLock',
    },
  ];

  @override
  void initState() {
      super.initState();
    _defaultUserJsonFuture = _generateDefaultUserJson();
    _defaultUserJsonFuture.then((json) => _postUserData(json));
  }

  Future<Map<String, dynamic>> _generateDefaultUserJson()  async {
    String? fcmToken = await FCMService.getFCMToken();
    print('🔑 FCM Token para registro: ${fcmToken?.substring(0, 20)}...');
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return {
      "uid": widget.userData['uid'] ?? "ABC123",
      "nombres": " ",
      "ap_paterno": " ",
      "ap_materno": " ",
      "ci": " ",
      "fcm_token": fcmToken ?? " ",
      "email": widget.userData['email'] ?? "usuario@ejemplo.com",
      "password": " ",
      "celular": "00",
      "direccion": " ",
      "fecha_registro": formattedDate,
      "preferencias": " ",
      "latitud": 0.0,
      "longitud": 0.0,
      "imagen_cliente": " "
    };
  }

Future<void> _postUserData(Map<String, dynamic> userJson) async {
    final datasource = ref.read(clienteREpositorioProvider);
    
    try {
      final cliente = Clientes.fromJson(userJson);
      final success = await datasource.registrarCliente(cliente: cliente);
      
      if (success) {
        debugPrint('Registro exitoso');
        final token = ref.read(authProvider);
        if (token != null) {
          debugPrint('JWT almacenado correctamente: ${token.substring(0, 20)}...');
        }
      } else {
        debugPrint('Error en el registro');
      }
    } catch (e) {
      debugPrint('Error en registro: $e');
    }
  }

  void _skipToHome() => context.go('/home');

  void _nextPage() {
    if (_currentPage < _lottieAnimations.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
      );
    } else {
      _skipToHome();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _lottieAnimations.length - 1;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!isLast)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: _skipToHome,
                        child: const Text('SALTAR', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _lottieAnimations.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(_lottieAnimations[i], height: size.height * 0.35),
                          const SizedBox(height: 32),
                          Text(
                            _pageContents[i]['title']!,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _pageContents[i]['subtitle']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _lottieAnimations.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i ? Colors.black : Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(isLast ? 'Comenzar' : 'Siguiente'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}