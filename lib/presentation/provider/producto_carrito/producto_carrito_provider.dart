import 'package:dio/dio.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/presentation/provider/producto_carrito/producto_carrito_reposirorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado del carrito
class CarritoState {
  final List<Producto> productos;
  final bool isLoading;
  final Response? ultimaRespuesta;

  CarritoState({
    this.productos = const [],
    this.isLoading = false,
    this.ultimaRespuesta,
  });

  CarritoState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    Response? ultimaRespuesta,
  }) {
    return CarritoState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      ultimaRespuesta: ultimaRespuesta ?? this.ultimaRespuesta,
    );
  }
}

// Provider
final carritoProvider = StateNotifierProvider<CarritoNotifier, CarritoState>((ref) {
  final agregarAlCarrito = ref.watch(productoCarritoRepositorioProvider).postProductoCarrito;
  return CarritoNotifier(agregarAlCarrito: agregarAlCarrito);
});

// Notifier
class CarritoNotifier extends StateNotifier<CarritoState> {
  final Future<Response> Function({ProductoCarrito? productoCarrito}) agregarAlCarrito;

  CarritoNotifier({
    required this.agregarAlCarrito,
  }) : super(CarritoState());

  Future<void> agregarProducto(ProductoCarrito productoCarrito) async {
    if (state.isLoading) return;

    // Iniciar carga
    state = state.copyWith(isLoading: true);

    try {
      final response = await agregarAlCarrito(productoCarrito: productoCarrito);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Actualizar estado con la respuesta exitosa
        state = state.copyWith(
          isLoading: false,
          ultimaRespuesta: response,
          // Aquí podrías actualizar la lista de productos si la respuesta los incluye
        );
      } else {
        throw Exception('Error al agregar producto: ${response.statusCode}');
      }
    } catch (e) {
      // Error en la operación
      state = state.copyWith(isLoading: false);
      debugPrint('Error al agregar producto: $e');
      rethrow;
    }
  }
}