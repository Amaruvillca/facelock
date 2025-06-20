
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/domain/entities/productos_variantes.dart';

abstract class ProductosDatasources {

  Future <List<Producto>> getProductos({int page = 1});
  Future <List<Producto>> getRecientes({int page = 1});
  Future <List<Producto>> getSimilares({int page = 1});
  Future <List<Producto>> getMejoresCalificadas({int page =1});
  Future <List<Producto>> getSearchProducto(String busqueda);
  Future <ProductoVariantes> getDetalleProducto( int idProducto);

}