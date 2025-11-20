import 'package:facelock/domain/entities/clientes.dart';
import 'package:facelock/domain/repositories/clientes_repositorie.dart';
import 'package:facelock/infrastructure/datasourses/clientesdb_datasourses.dart';
import 'package:facelock/infrastructure/repositories/clientes_repositorie_imp.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final clienteREpositorioProvider = Provider<ClientesRepositorie>((ref) {
  return ClientesRepositorieImp(ClientesdbDatasourses(ref));
});

final resgistroCliente = StateNotifierProvider<RegistroClienteNotifier, bool>((ref) {
  final repositorio = ref.watch(clienteREpositorioProvider);
  return RegistroClienteNotifier(repositorio);
});

class RegistroClienteNotifier extends StateNotifier<bool> {
  final ClientesRepositorie _repositorio;

  RegistroClienteNotifier(this._repositorio) : super(false);

  Future<void> registrarCliente(Clientes cliente) async {
    try {
      final exito = await _repositorio.registrarCliente(cliente: cliente);
      state = exito;
    } catch (e) {
      // Manejo de errores
      state = false;
      rethrow;
    }
  }
}

