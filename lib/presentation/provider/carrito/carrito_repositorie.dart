import 'package:facelock/infrastructure/datasourses/carritodb_datasourses.dart';
import 'package:facelock/infrastructure/repositories/carrito_repositories_imp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carritoREpositorioProvider = Provider((ref){
  return CarritoRepositoriesImp(CarritodbDatasourses());
});