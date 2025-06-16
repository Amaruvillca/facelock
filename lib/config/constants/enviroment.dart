 import 'package:flutter_dotenv/flutter_dotenv.dart';
 class Environment{
  static String urlBase =dotenv.env['URL_BASE'] ?? 'no url';

 }
