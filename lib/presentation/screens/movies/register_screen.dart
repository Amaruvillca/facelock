import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _pwdCtrl.text.trim(),
          );

      // Navegar a pantalla de bienvenida para nuevos usuarios
      if (mounted) {
        context.go('/welcome', extra: {
          'isNewUser': true,
          'email': userCredential.user?.email,
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _translateError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Verificamos si es un nuevo usuario
      final authResult = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (authResult.additionalUserInfo?.isNewUser ?? false) {
        // Usuario nuevo -> Pantalla de bienvenida
        if (mounted) {
          context.go('/welcome', extra: {
            'isNewUser': true,
            'email': authResult.user?.email,
            'provider': 'google',
          });
        }
      } else {
        // Usuario existente -> Home
        if (mounted) context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _translateError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _translateError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico no válido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'Contraseña demasiado débil';
      default:
        return 'Ocurrió un error. Intenta nuevamente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            expandedHeight: size.height * .4,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FadeIn(
                    duration: const Duration(milliseconds: 800),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha((0.2 * 255).round()),
                          Colors.black.withAlpha((0.6 * 255).round()),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: BounceInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/logo.png",
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crear Cuenta',
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FA),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: const Color(0xFFF8F5FA),
                    width: 0,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Mensaje de error
                    if (_errorMessage != null)
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // Campo de email
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.sms),
                          labelText: 'Correo electrónico',
                          hintText: 'ejemplo@correo.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Correo electrónico no válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de contraseña
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscurePwd,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.lock),
                          labelText: 'Contraseña',
                          hintText: 'Crea una contraseña segura',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePwd ? Iconsax.eye_slash : Iconsax.eye,
                            ),
                            onPressed: () => 
                                setState(() => _obscurePwd = !_obscurePwd),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirmar contraseña
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: TextFormField(
                        controller: _confirmPwdCtrl,
                        obscureText: _obscureConfirmPwd,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.lock_1),
                          labelText: 'Confirmar contraseña',
                          hintText: 'Repite tu contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPwd ? Iconsax.eye_slash : Iconsax.eye,
                            ),
                            onPressed: () => 
                                setState(() => _obscureConfirmPwd = !_obscureConfirmPwd),
                          ),
                        ),
                        validator: (value) {
                          if (value != _pwdCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botón de registro
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _registerWithEmail,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('REGISTRARSE'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divisor
                    FadeInUp(
                      duration: const Duration(milliseconds: 1100),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: colors.outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'O',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onBackground.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: colors.outline)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de Google
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/google.png',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text('Continuar con Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colors.outline),
                          ),
                          onPressed: _isLoading ? null : _signInWithGoogle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Enlace a login
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Ya tienes una cuenta?",
                            style: textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _isLoading 
                                ? null 
                                : () => context.go('/'),
                            child: Text(
                              'Inicia sesión',
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}