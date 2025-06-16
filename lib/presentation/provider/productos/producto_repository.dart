import 'package:facelock/infrastructure/datasourses/productosdb_datasources.dart';
import 'package:facelock/infrastructure/repositories/productos_repositories_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productoREpositorioProvider = Provider((ref){
  return ProductosRepositoriesImpl(ProductosdbDatasources());
});
