import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _signOut(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) context.go('/');
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta permanentemente? '
          'Todos tus datos se perderán y esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await user.delete();
      
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) context.go('/login');
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Cuenta eliminada exitosamente')),
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar cuenta: ${e.message}')),
      );
      
      if (e.code == 'requires-recent-login' && context.mounted) {
        await _showReauthenticationDialog(context);
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showReauthenticationDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reautenticación requerida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor ingresa tu contraseña para continuar'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                final email = user?.email;
                
                if (user != null && email != null) {
                  final cred = EmailAuthProvider.credential(
                    email: email,
                    password: passwordController.text,
                  );
                  
                  await user.reauthenticateWithCredential(cred);
                  Navigator.of(context).pop();
                  await _deleteAccount(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? 'Usuario';
    final email = user?.email ?? 'No proporcionado';
    final provider = user?.providerData.isNotEmpty ?? false 
        ? user!.providerData[0].providerId.replaceAll('.com', '') 
        : 'email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sección de información del usuario
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : const NetworkImage(
                                  'https://media.istockphoto.com/id/155068180/es/foto/guy-real.jpg',
                                ) as ImageProvider,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            provider == 'google' 
                                ? PhosphorIconsBold.googleLogo 
                                : PhosphorIconsBold.envelope,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/profile/edit'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Editar Perfil'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de opciones
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.lock, color: Colors.deepPurple),
                    title: const Text('Cambiar Contraseña'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    onTap: () => context.push('/profile/change-password'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.scanSmiley, color: Colors.deepPurple),
                    title: const Text('Registro Biométrico'),
                    subtitle: const Text('Configura tu Reconocimiento facial'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    onTap: () => context.push('/home/profile'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.shield, color: Colors.deepPurple),
                    title: const Text('Privacidad y Seguridad'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    onTap: () => context.push('/profile/privacy'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.storefront, color: Colors.deepPurple),
                    title: const Text('Sucursales'),
                    subtitle: const Text('Encuentra nuestras sucursales cercanas'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    onTap: () => context.push('/home/mapa'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.clockUser, color: Colors.deepPurple),
                    title: const Text('Historial de compras'),
                    subtitle: const Text('Consulta tus compras realizadas'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    onTap: () => context.push('/profile/branches'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de acciones importantes
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(PhosphorIconsRegular.signOut, color: Colors.blue[700]),
                    title: const Text('Cerrar Sesión'),
                    onTap: () => _signOut(context),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(PhosphorIconsRegular.trash, color: Colors.red[400]),
                    title: Text(
                      'Eliminar Cuenta',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}