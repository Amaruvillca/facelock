import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/datasources/producto_carrito_datasource.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductoCarritodbDatasources extends ProductoCarritoDatasource {
  final Dio dio = Dio(BaseOptions(baseUrl: '${Environment.urlBase}/productocarrito',
  headers: {
            "X-API-Name": Environment.xApiName,
            "X-API-Version": Environment.xApiVersion,
            "X-Developed-By": Environment.xDevelopedBy,
            "X-Code": Environment.xCode
  }));

  ProductoCarritodbDatasources();

  @override
  Future<Response> postProductoCarrito({ProductoCarrito? productoCarrito}) async {
    final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      final uid = user.uid;
    try {
      if (productoCarrito == null) {
        throw ArgumentError('El producto del carrito no puede ser nulo');
      }

      final response = await dio.post(
        '/$uid',
        
        
        data: productoCarrito.toJson(),
      );

      return response;
    } on DioException catch (e) {
      debugPrint('Error en postProductoCarrito: ${e.message}');
      if (e.response != null) {
        debugPrint('Respuesta del servidor: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('Error inesperado en postProductoCarrito: $e');
      throw Exception('Error al agregar producto al carrito: $e');
    }
  }
}