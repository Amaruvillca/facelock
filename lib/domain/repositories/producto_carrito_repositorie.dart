import 'package:dio/dio.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';

abstract class ProductoCarritoRepositorie {
  Future<Response> postProductoCarrito({ProductoCarrito productoCarrito});
}