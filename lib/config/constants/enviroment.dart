 import 'package:flutter_dotenv/flutter_dotenv.dart';
 class Environment{
  static String urlBase =dotenv.env['URL_BASE'] ?? 'no url';
  static String xApiName = dotenv.env['X_API_Name'] ?? 'no x';
  static String xApiVersion = dotenv.env['X_API_Version'] ?? 'no xVersion';
  static String xDevelopedBy = dotenv.env['X_Developed_By'] ?? 'no xDevelopedBy';
  static String xCode = dotenv.env['X_Code'] ?? 'no xCode';

    // DebugMode con inicialización segura y tipado fuerte
  static bool get debugMode {
    // Si está definido en .env
    if (dotenv.env['DEBUG_MODE'] != null) {
      return dotenv.env['DEBUG_MODE']!.toLowerCase() == 'true';
    }
    // Valor por defecto basado en el modo de compilación
    return bool.fromEnvironment('dart.vm.product') ? false : true;
  }

  // Método para inicializar (llamar en main())
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
    urlBase = dotenv.env['URL_BASE'] ?? 'https://default.api.url';
  xApiName = dotenv.env['X_API_Name'] ?? 'DefaultAPIName';
  xApiVersion = dotenv.env['X_API_Version'] ?? '1.0';
  xDevelopedBy = dotenv.env['X_Developed_By'] ?? 'DefaultDeveloper';
  xCode = dotenv.env['X_Code'] ?? '00000';
  }

 }
