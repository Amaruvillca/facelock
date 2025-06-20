import 'package:facelock/config/constants/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';        // ← nuevo

class WelcomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const WelcomeScreen({super.key, required this.userData});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final Map<String, dynamic> _defaultUserJson;
  final Dio _dio = Dio();            // Reutilizamos la misma instancia

  @override
  void initState() {
    super.initState();

    // Generamos el JSON una sola vez
    _defaultUserJson = _generateDefaultUserJson();

    // Lanzamos la petición en cuanto se entra a la pantalla
    _postUserData();
  }

  /// Construye el JSON con valores por defecto
  Map<String, dynamic> _generateDefaultUserJson() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return {
      "uid": widget.userData['uid'] ?? "ABC123",
      "nombres": " ",
      "ap_paterno": " ",
      "ap_materno": " ",
      "ci": " ",
      "fcm_token": " ",
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

  /// Envía el JSON al endpoint
  Future<void> _postUserData() async {
    // ⚠️ Si pruebas en un emulador Android usa http://10.0.2.2:8000
    final url = '${Environment.urlBase}/clientes/';

    try {
      final response = await _dio.post(url, data: _defaultUserJson);
      debugPrint('POST $url → ${response.statusCode}');
      debugPrint('Respuesta: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Error Dio: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded, size: 100, color: colors.primary),
              const SizedBox(height: 32),
              Text('¡Bienvenido/a!', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Tu cuenta con ${widget.userData['email']} ha sido creada exitosamente',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),

              // Sección de depuración (puedes ocultarla en producción)
              const SizedBox(height: 32),
              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos técnicos (debug):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('UID: ${widget.userData['uid'] ?? "No proporcionado"}',
                          style: const TextStyle(fontFamily: 'monospace')),
                      const SizedBox(height: 8),
                      const Text('JSON generado:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_defaultUserJson.toString(),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Comenzar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
