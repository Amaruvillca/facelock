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
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cerrar sesión en Google primero si estaba usando Google Sign-In
      await GoogleSignIn().signOut();
      
      // Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      
      // Cerrar el diálogo de carga
      if (context.mounted) Navigator.of(context).pop();
      
      // Navegar a la pantalla de login usando GoRouter
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

    // Mostrar diálogo de confirmación
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
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Eliminar la cuenta del usuario
      await user.delete();
      
      // Cerrar el diálogo de carga
      if (context.mounted) Navigator.of(context).pop();
      
      // Navegar a la pantalla de login usando GoRouter
      if (context.mounted) context.go('/login');
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Cuenta eliminada exitosamente')),
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar cuenta: ${e.message}')),
      );
      
      // Si el error es que necesita reautenticación
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          await _showReauthenticationDialog(context);
        }
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
                  // Volver a intentar eliminar la cuenta
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
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.gear),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : const NetworkImage(
                            'https://media.istockphoto.com/id/155068180/es/foto/guy-real.jpg',
                          ) as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(email),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      provider == 'google' ? 'Google' : 'Email/Contraseña',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.user),
                    title: const Text('Editar Perfil'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
                    onTap: () => context.push('/profile/edit'),
                  ),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.lock),
                    title: const Text('Cambiar Contraseña'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
                    onTap: () => context.push('/profile/change-password'),
                  ),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.shield),
                    title: const Text('Privacidad y Seguridad'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
                    onTap: () => context.push('/profile/privacy'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.signOut),
                    title: const Text('Cerrar Sesión'),
                    onTap: () => _signOut(context),
                  ),
                  ListTile(
                    leading: Icon(
                      PhosphorIconsRegular.trash,
                      color: Colors.red[400],
                    ),
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