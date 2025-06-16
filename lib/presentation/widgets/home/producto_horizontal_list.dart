import 'package:animate_do/animate_do.dart';

import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/presentation/widgets/home/card_producto.dart';
import 'package:flutter/material.dart';

class ProductoHorizontalList extends StatefulWidget {
  const ProductoHorizontalList({
    super.key,
    required this.productos, 
    required this.scrol,
    this.isLoading = false,
    this.emptyStateMessage = 'Cargando...', // Nuevo: mensaje cuando no hay productos
    this.loadingIndicatorColor = Colors.black, // Nuevo: customizable color
    this.loadingIndicatorStrokeWidth = 2.0, // Nuevo: customizable stroke
  });

  final List<Producto> productos;
  final String scrol;
  final bool isLoading;
  final String emptyStateMessage; // Nuevo
  final Color loadingIndicatorColor; // Nuevo
  final double loadingIndicatorStrokeWidth; // Nuevo

  @override
  State<ProductoHorizontalList> createState() => _ProductoHorizontalListState();
}

class _ProductoHorizontalListState extends State<ProductoHorizontalList> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: widget.isLoading 
          ? _buildLoadingIndicator() 
          : widget.productos.isEmpty // Nuevo: manejo de lista vacía
            ? _buildEmptyState()
            : _buildProductList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: widget.loadingIndicatorColor, // Usando el nuevo parámetro
        strokeWidth: widget.loadingIndicatorStrokeWidth, // Usando el nuevo parámetro
      ),
    );
  }

  // Nuevo: Widget para estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        widget.emptyStateMessage,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.separated(
      key: PageStorageKey(widget.scrol),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      itemCount: widget.productos.length,
      separatorBuilder: (context, index) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        final producto = widget.productos[index];
        return FadeInRight(
          duration: const Duration(milliseconds: 200), // Nuevo: duración consistente
          delay: Duration(milliseconds: index * 50), // Nuevo: efecto escalonado
          child: CardProducto(
            producto: producto,
          ),
        );
      },
    );
  }
}