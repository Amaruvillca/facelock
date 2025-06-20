import 'package:flutter_riverpod/flutter_riverpod.dart';

final estadoAutenticacionProvider = StateNotifierProvider<EstadoAutenticacionNotifier, bool>((ref) {
  return EstadoAutenticacionNotifier();
});

class EstadoAutenticacionNotifier extends StateNotifier<bool> {
  EstadoAutenticacionNotifier() : super(false);

  Future<void> verificarEstadoBiometrico(String userId) async {
    try {
      // Aquí iría la lógica real para verificar con tu backend
      // Simulamos una verificación exitosa después de 1 segundo
      await Future.delayed(const Duration(seconds: 1));
      state = true; // Cambiar a false para simular no registrado
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}