// Corrigiendo el nombre del repositorio
import 'package:facelock/infrastructure/datasourses/producto_carritodb_datasourses.dart';
import 'package:facelock/infrastructure/repositories/producto_carrito_repositories_imp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productoCarritoRepositorioProvider = Provider((ref) {
  return ProductoCarritoRepositoriesImp(ProductoCarritodbDatasources());
});