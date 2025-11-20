import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';

import 'package:facelock/domain/datasources/carrito_datasource.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:flutter/material.dart';

class CarritodbDatasourses extends CarritoDatasource {
  final dio = Dio(BaseOptions(baseUrl: '${Environment.urlBase}/productocarrito',
  headers: {
            "X-API-Name": Environment.xApiName,
            "X-API-Version": Environment.xApiVersion,
            "X-Developed-By": Environment.xDevelopedBy,
            "X-Code": Environment.xCode
  }),
  );

  @override
  Future<List<ProductoCarrito>> getProductosCarritoActivos({required String uid}) async {
    try {
    final response = await dio.get(
      '/$uid/productoscarrito',
    );

      if (response.statusCode != 200) {
        throw Exception('Error al obtener los productos del carrito');
      }

      final data = response.data['data'] as List;
      return data.map((item) => ProductoCarrito.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error en getProductosCarritoActivos: $e');
      return []; // Retorna lista vacía en caso de error
    }
  }
}
