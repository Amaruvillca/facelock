import 'package:cached_network_image/cached_network_image.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class CardProducto extends StatelessWidget {
  const CardProducto({super.key, required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/home/detalleproducto/${producto.idProducto}');
      },
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl:
                        '${Environment.urlBase}/img/productos/${producto.imagen}',
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            Image.asset('assets/gif3.gif', fit: BoxFit.cover),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/gif3.gif',
                            fit: BoxFit.cover,
                            height: 700,
                            width: 700,
                          ),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: producto.promedioCalificacion,
                        itemBuilder:
                            (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 16.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 10),
                      Text("${producto.promedioCalificacion}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Bs. ${producto.precio.toString()}',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
