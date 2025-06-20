import 'package:facelock/domain/repositories/clientes_repositorie.dart';
import 'package:facelock/infrastructure/datasourses/clientesdb_datasourses.dart';
import 'package:facelock/infrastructure/repositories/clientes_repositorie_imp.dart';
import 'package:facelock/presentation/provider/cliente/cliente_repositorie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clienteREpositorioProvider = Provider<ClientesRepositorie>((ref) {
  return ClientesRepositorieImp(ClientesdbDatasourses());
});

final estadoAutenticacionProvider = StateNotifierProvider<EstadoAutenticacionNotifier, bool>((ref) {
  final repositorio = ref.watch(clienteREpositorioProvider);
  return EstadoAutenticacionNotifier(repositorio);
});

class EstadoAutenticacionNotifier extends StateNotifier<bool> {
  final ClientesRepositorie _repositorio;

  EstadoAutenticacionNotifier(this._repositorio) : super(false);

  Future<void> verificarEstadoBiometrico(String uid) async {
    if (uid.isEmpty) {
      state = false;
      return;
    }

    try {
      final tieneBiometria = await _repositorio.getEstadoAutentificacion(uid: uid);
      state = tieneBiometria;
    } catch (e) {
      // Manejo de errores
      state = false;
      rethrow;
    }
  }
}

