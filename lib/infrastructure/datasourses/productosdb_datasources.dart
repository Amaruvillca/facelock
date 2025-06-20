import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/datasources/productos_datasources.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/domain/entities/productos_variantes.dart';
import 'package:facelock/infrastructure/mapper/producto_mapper.dart';
import 'package:facelock/infrastructure/models/productosresponce/producto_response.dart';

class ProductosdbDatasources extends ProductosDatasources {
  final dio = Dio(BaseOptions(baseUrl: '${Environment.urlBase}/productos'));
  List<Producto> _jsonToProducto(Map<String, dynamic> json) {
    final productoDBresponse = ProductoResponse.fromJson(json);
    final List<Producto> productos =
        productoDBresponse.data
            .map((e) => ProductoMapper.resultProducto(e))
            .toList();
    return productos;
  }

  

  @override
  Future<List<Producto>> getMejoresCalificadas({int page =1}) async {
    final response = await dio.get('/mejorescalificados');
    
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las peliculas');
    }
    return _jsonToProducto(response.data);
  }

  @override
  Future<List<Producto>> getProductos({int page = 1}) async{
    final response = await dio.get('/$page/paginacion');
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las peliculas');
    }
    return _jsonToProducto(response.data);
  }

  @override
  Future<List<Producto>> getRecientes({int page = 1}) async {
    final response = await dio.get('/recientes');
    
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las peliculas');
    }
    return _jsonToProducto(response.data);
  }

  @override
  Future<List<Producto>> getSearchProducto(String busqueda) async {
    final response = await dio.get('/buscar',
    queryParameters: {
      'busqueda': busqueda,
    }
    
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las peliculas');
    }
    return _jsonToProducto(response.data);
  }

  @override
  Future<ProductoVariantes> getDetalleProducto(int idProducto) async {
    try {
      final response = await dio.get('/todo/$idProducto');
      final data = response.data['data'];
      if (response.statusCode != 200) {
        throw Exception('Error al cargar las peliculas');
      }
      return ProductoVariantes.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener el detalle del producto: $e');
    }
  }
  
  @override
  Future<List<Producto>> getSimilares({int page = 1}) async {
    final response = await dio.get('/$page/similares');
    
    if (response.statusCode != 200) {
      throw Exception('Error al cargar las peliculas');
    }
    return _jsonToProducto(response.data);
  }
}
