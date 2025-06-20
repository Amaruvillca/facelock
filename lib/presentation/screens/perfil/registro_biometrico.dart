import 'package:facelock/presentation/provider/cliente/cliente_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RegistroBiometricoScreen extends ConsumerStatefulWidget {
  const RegistroBiometricoScreen({super.key});

  @override
  ConsumerState<RegistroBiometricoScreen> createState() => _RegistroBiometricoScreenState();
}

class _RegistroBiometricoScreenState extends ConsumerState<RegistroBiometricoScreen> {
  bool _isLoading = false;
  String? _userUid;
  bool _hasCheckedInitialState = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar estado al volver de otra pantalla
    _checkBiometricState();
  }

  Future<void> _getCurrentUserUid() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => _userUid = user.uid);
        await _checkBiometricState();
      }
    } catch (e) {
      _mostrarSnackBar('Error al obtener información del usuario', color: Colors.red);
    }
  }

  Future<void> _checkBiometricState() async {
    if (_userUid == null || _isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(estadoAutenticacionProvider.notifier).verificarEstadoBiometrico(_userUid!);
    } catch (e) {
      _mostrarSnackBar('Error al verificar estado biométrico', color: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasCheckedInitialState = true;
        });
      }
    }
  }

  Future<void> _navigateToRegisterFace() async {
    if (_userUid == null) {
      _mostrarSnackBar('No se pudo identificar al usuario', color: Colors.red);
      return;
    }

    // Navegar a la pantalla de registro facial
    final result = await context.push<bool>('/home/registrarbio');
    
    // Verificar el estado nuevamente al volver
    if (result == true && mounted) {
      await _checkBiometricState();
    }
  }

  Future<void> _cambiarRegistro() async {
    if (_userUid == null) return;

    setState(() => _isLoading = true);
    
    try {
      // Navegar a pantalla de cambio de registro
      final result = await context.push<bool>('/home/registrarbio');
      
      // Verificar el estado nuevamente al volver
      if (result == true && mounted) {
        await _checkBiometricState();
      }
    } catch (e) {
      _mostrarSnackBar('Error al actualizar el registro', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFacePay(bool value) {
    // Aquí iría la lógica para actualizar en Firestore
    _mostrarSnackBar(
      value ? 'Face Pay activado' : 'Face Pay desactivado',
      color: value ? Colors.green : Colors.orange,
    );
  }

  void _mostrarSnackBar(String mensaje, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rostroRegistrado = ref.watch(estadoAutenticacionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Pay'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Tarjeta de estado
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Icono biométrico con animación de carga
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading && !_hasCheckedInitialState
                        ? Container(
                            width: 96,
                            height: 96,
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          )
                        : Container(
                            key: ValueKey<bool>(rostroRegistrado),
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.primaryContainer.withOpacity(0.2),
                              border: Border.all(
                                color: rostroRegistrado 
                                    ? cs.primary 
                                    : cs.errorContainer,
                                width: 2),
                            ),
                            child: Icon(
                              rostroRegistrado 
                                  ? PhosphorIconsFill.scanSmiley 
                                  : PhosphorIconsRegular.smileyMelting,
                              size: 48,
                              color: rostroRegistrado ? cs.primary : cs.error,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Estado
                  Text(
                    _isLoading && !_hasCheckedInitialState
                        ? 'Verificando estado...'
                        : rostroRegistrado 
                            ? 'Biometría Registrada' 
                            : 'Registro Biométrico',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading && !_hasCheckedInitialState
                        ? 'Por favor espera'
                        : rostroRegistrado
                            ? 'Autenticación facial disponible'
                            : 'Registra tu rostro para pagos seguros',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón principal - Cambia según el estado
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLoading && !_hasCheckedInitialState
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : ElevatedButton.icon(
                              key: ValueKey<bool>(rostroRegistrado),
                              onPressed: _isLoading 
                                  ? null 
                                  : rostroRegistrado 
                                      ? _cambiarRegistro 
                                      : _navigateToRegisterFace,
                              icon: Icon(
                                rostroRegistrado 
                                    ? PhosphorIconsRegular.faceMask 
                                    : PhosphorIconsRegular.userPlus,
                                size: 20,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rostroRegistrado 
                                    ? cs.surfaceVariant 
                                    : cs.primary,
                                foregroundColor: rostroRegistrado 
                                    ? cs.onSurfaceVariant 
                                    : cs.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: Text(
                                rostroRegistrado 
                                    ? 'Cambiar Registro' 
                                    : 'Registrar Rostro'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Panel de configuración (solo si está registrado y ya se verificó el estado)
            if (rostroRegistrado && _hasCheckedInitialState) 
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.shieldCheck, color: cs.primary),
                          const SizedBox(width: 12),
                          Text('Configuración de Seguridad', style: tt.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: rostroRegistrado, // O usar un estado separado para Face Pay
                        onChanged: _isLoading ? null : _toggleFacePay,
                        activeColor: cs.primary,
                        title: const Text('Autenticación Biométrica'),
                        subtitle: const Text('Usar reconocimiento facial para pagos'),
                        secondary: Icon(
                          PhosphorIconsRegular.faceMask,
                          color: rostroRegistrado ? cs.primary : cs.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 32),
            Text(
              'Compatible con Android 8+ e iOS 11+',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}