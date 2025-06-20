import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/datasources/clientes_datasources.dart';
import 'package:flutter/material.dart';

class ClientesdbDatasourses extends ClientesDatasources {
  final dio = Dio(BaseOptions(baseUrl: '${Environment.urlBase}/clientes'));
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

}