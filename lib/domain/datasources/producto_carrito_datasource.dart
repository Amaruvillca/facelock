import 'package:dio/dio.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';

abstract class ProductoCarritoDatasource {


Future<Response> postProductoCarrito({ProductoCarrito productoCarrito});



}