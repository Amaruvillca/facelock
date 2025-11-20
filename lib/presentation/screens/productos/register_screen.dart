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

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Animaciones muy ligeras (sin Animate_do)
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<double>(begin: 20, end: 0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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

      if (mounted) {
        context.go('/welcome', extra: {
          'isNewUser': true,
          'email': userCredential.user?.email,
          'provider': 'Email',
          'uid': userCredential.user?.uid,
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
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (authResult.additionalUserInfo?.isNewUser ?? false) {
        if (mounted) {
          context.go('/welcome', extra: {
            'isNewUser': true,
            'email': authResult.user?.email,
            'provider': 'Google',
            'uid': authResult.user?.uid,
          });
        }
      } else {
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
      case 'weak-password':
        return 'Contraseña muy débil';
      default:
        return 'Ocurrió un error. Intenta nuevamente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: keyboardIsOpen ? 120 : size.height * 0.45,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (!keyboardIsOpen)
                    Image.network(
                      "https://images.unsplash.com/photo-1483985988355-763728e1935b",
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      gaplessPlayback: true,
                    ),

                  if (!keyboardIsOpen)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(.2),
                            Colors.black.withOpacity(.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                  if (!keyboardIsOpen)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/logo.png",
                                width: 90,
                                height: 90,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Crear Cuenta",
                                style: text.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F5FA),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ),

          // ================= FORM =================
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // EMAIL
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _inputDecoration(
                          label: "Correo electrónico",
                          icon: Iconsax.sms,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final regex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(v)) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // PASSWORD
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscurePwd,
                        decoration: _inputDecoration(
                          label: "Contraseña",
                          icon: Iconsax.lock,
                          suffix: IconButton(
                            icon: Icon(_obscurePwd
                                ? Iconsax.eye_slash
                                : Iconsax.eye),
                            onPressed: () =>
                                setState(() => _obscurePwd = !_obscurePwd),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa una contraseña';
                          }
                          if (v.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // CONFIRM PASSWORD
                      TextFormField(
                        controller: _confirmPwdCtrl,
                        obscureText: _obscureConfirmPwd,
                        decoration: _inputDecoration(
                          label: "Confirmar contraseña",
                          icon: Iconsax.lock,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirmPwd
                                ? Iconsax.eye_slash
                                : Iconsax.eye),
                            onPressed: () => setState(
                                () => _obscureConfirmPwd = !_obscureConfirmPwd),
                          ),
                        ),
                        validator: (v) {
                          if (v != _pwdCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _registerWithEmail,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("CREAR CUENTA"),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          Expanded(
                            child:
                                Divider(color: colors.outline, thickness: .7),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("O"),
                          ),
                          Expanded(
                            child:
                                Divider(color: colors.outline, thickness: .7),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      IconButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Image.asset("assets/google.png", width: 30),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: colors.outline),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿Ya tienes una cuenta?"),
                          TextButton(
                            onPressed: () => context.go('/'),
                            child: Text(
                              "Iniciar sesión",
                              style: TextStyle(color: colors.primary),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: suffix,
    );
  }
}
