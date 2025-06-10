import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://media.istockphoto.com/id/155068180/es/foto/guy-real.jpg?s=612x612&w=0&k=20&c=VDSua2eTduOoccz7LZZWxNhGMur6hl6jZKIqAiY3w68='),
          ),
          const SizedBox(height: 20),
          const Text(
            'Usuario Ejemplo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('usuario@ejemplo.com'),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(PhosphorIconsRegular.signOut),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}