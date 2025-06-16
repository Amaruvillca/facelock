
import 'package:facelock/domain/entities/producto.dart';

abstract class ProductosDatasources {

  Future <List<Producto>> getProductos({int page = 1});
  Future <List<Producto>> getRecientes({int page = 1});
  Future <List<Producto>> getMejoresCalificadas({int page =1});
  Future <List<Producto>> getSearchProducto(String busqueda);

}