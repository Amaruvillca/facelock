import 'package:facelock/domain/datasources/productos_datasources.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/domain/entities/productos_variantes.dart';
import 'package:facelock/domain/repositories/productos_repositories.dart';

class ProductosRepositoriesImpl extends ProductosRepositories {
  final ProductosDatasources datasources;

  ProductosRepositoriesImpl(this.datasources);
  @override
  Future<List<Producto>> getMejoresCalificadas({int page =1}) {
    
    return datasources.getMejoresCalificadas(page: page);
  }


  @override
  Future<List<Producto>> getProductos({int page = 1}) {
    
    return datasources.getProductos(page: page);
  }

  @override
  Future<List<Producto>> getRecientes({int page = 1}) {
    
    return datasources.getRecientes(page: page);
  }

  @override
  Future<List<Producto>> getSearchProducto(String busqueda) {
    
    return datasources.getSearchProducto(busqueda);
  
  }

  @override
  Future<ProductoVariantes> getDetalleProducto(int idProducto) {
    
    return datasources.getDetalleProducto(idProducto);
  }
  
  @override
  Future<List<Producto>> getSimilares({int page = 1}) {
    
    return datasources.getSimilares(page: page);
  }


}