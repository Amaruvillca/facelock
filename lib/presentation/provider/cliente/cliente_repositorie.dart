import 'package:facelock/infrastructure/datasourses/clientesdb_datasourses.dart';
import 'package:facelock/infrastructure/repositories/clientes_repositorie_imp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clienteREpositorioProvider = Provider((ref){
  return ClientesRepositorieImp(ClientesdbDatasourses(ref));
});