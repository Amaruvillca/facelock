import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ListTile(
                leading: Icon(PhosphorIconsRegular.shoppingCartSimple),
                title: Text('Producto en carrito 1'),
                subtitle: Text('\$29.99'),
                trailing: Text('x1'),
              ),
              ListTile(
                leading: Icon(PhosphorIconsRegular.shoppingCartSimple),
                title: Text('Producto en carrito 2'),
                subtitle: Text('\$19.99'),
                trailing: Text('x2'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Pagar \$69.97'),
          ),
        ),
      ],
    );
  }
}