import 'package:facelock/domain/entities/producto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seachQueryProductoPrivider= StateProvider<String>((ref) => '');
final guardarListaDeBusqueda = StateProvider<List<Producto>>((ref) => []);
final historialDeBusqueda = StateProvider<List<String>>((ref) => []);