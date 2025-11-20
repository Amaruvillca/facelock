import 'package:dio/dio.dart';
import 'package:facelock/domain/datasources/producto_carrito_datasource.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/domain/repositories/producto_carrito_repositorie.dart';

class ProductoCarritoRepositoriesImp  extends ProductoCarritoRepositorie{
  final ProductoCarritoDatasource datasources;

  ProductoCarritoRepositoriesImp(this.datasources);
  
  @override
  Future<Response> postProductoCarrito({ProductoCarrito? productoCarrito}) {
    // TODO: implement postProductoCarrito
    if (productoCarrito == null) {
      throw ArgumentError('productoCarrito cannot be null');
    }
    return datasources.postProductoCarrito(productoCarrito: productoCarrito);
  }
  
   
}