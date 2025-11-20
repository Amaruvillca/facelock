import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/datasources/clientes_datasources.dart';
import 'package:facelock/domain/entities/clientes.dart';
import 'package:facelock/presentation/provider/jwt/auth_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientesdbDatasourses extends ClientesDatasources {
  final Ref ref;
  final dio = Dio(BaseOptions(baseUrl: '${Environment.urlBase}/clientes',
      headers: {
            "X-API-Name": Environment.xApiName,
            "X-API-Version": Environment.xApiVersion,
            "X-Developed-By": Environment.xDevelopedBy,
            "X-Code": Environment.xCode
  },));

  ClientesdbDatasourses(this.ref);

  @override
  Future<bool> getEstadoAutentificacion({String uid = ''}) async {
    try {
    final response = await dio.get('/verificar-biometria/$uid');

    if (response.statusCode != 200) {
      throw Exception('Error al verificar la biometría');
    }

    return response.data['biometria_registrada'] ?? false;
  } catch (e) {
    // Opcional: manejar errores y retornar false si falla la consulta
    debugPrint('Error en getEstadoAutentificacion: $e');
    return false;
  }
  }

  @override
  Future<bool> iniciarSesion({required String email}) {
   
    throw UnimplementedError();
  }

  @override
  Future<bool> registrarCliente({required Clientes cliente}) async{
    
    try {
      final response = await dio.post('/', data: cliente.toJson(),);

      if (response.statusCode == 200) {
        final authNotifier = ref.read(authProvider.notifier);
          await authNotifier.setToken(response.data['access_token']);
        return true;
      } else {
        throw Exception('Error al registrar cliente ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en registrarCliente: $e');
      return false;
    }
  }

}