import 'package:facelock/domain/entities/producto.dart';

abstract class ProductosRepositories {
    Future <List<Producto>> getProductos({int page = 1});
  Future <List<Producto>> getRecientes({int page =1});
  Future <List<Producto>> getMejoresCalificadas();
  Future <List<Producto>> getSearchProducto(String busqueda);
}