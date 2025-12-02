import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/presentation/provider/carrito/carrito_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class CartView extends ConsumerStatefulWidget {
  const CartView({super.key});

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref
          .read(carritoPendienteProvider.notifier)
          .cargarCarritoPendiente(user.uid);
    }
  }

  Future<void> _eliminarCarrito() async {
    final productos = ref.read(carritoPendienteProvider);
    final idCarrito = productos.isNotEmpty && productos.first.idCarrito != null ? productos.first.idCarrito! : null;
    if (idCarrito == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay carrito para eliminar'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final dio = Dio();
      final response = await dio.delete(
        '${Environment.urlBase}/carrito/$idCarrito',
        options: Options(
          headers: {
            'accept': 'application/json',
            'x-api-name': 'Facelook',
            'x-api-version': '1.0',
            'x-developed-by': 'Kurve',
            'x-code': '17145',
          },
        ),
      );
      if (response.data['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message']), backgroundColor: Colors.green),
        );
        // Recargar productos del carrito
        await _cargarProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar carrito'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> actualizarCantidadProductoCarrito(int idProductoCarrito, int cantidad) async {
    try {
      final dio = Dio();
      final response = await dio.put(
        '${Environment.urlBase}/productocarrito/',
        queryParameters: {
          'id_producto_carrito': idProductoCarrito,
          'cantidad': cantidad,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'x-api-name': 'Facelook',
            'x-api-version': '1.0',
            'x-developed-by': 'Kurve',
            'x-code': '17145',
          },
        ),
      );
      if (response.data['message'] != null) {
        // Puedes mostrar un mensaje de éxito si lo deseas
        debugPrint(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error al actualizar cantidad: $e');
    }
  }

  Future<void> eliminarProductoCarrito(int idProductoCarrito) async {
    try {
      final dio = Dio();
      final response = await dio.delete(
        '${Environment.urlBase}/productocarrito/$idProductoCarrito',
        options: Options(
          headers: {
            'accept': 'application/json',
            'x-api-name': 'Facelook',
            'x-api-version': '1.0',
            'x-developed-by': 'Kurve',
            'x-code': '17145',
          },
        ),
      );
      if (response.data['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message']), backgroundColor: Colors.green),
        );
        await _cargarProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar producto'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(carritoPendienteProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (productos.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    final total = productos.fold<double>(
      0.0,
      (sum, producto) => sum + producto.precioTotal,
    );

    return Scaffold(
      backgroundColor: colors.surfaceVariant.withOpacity(0.2),
      body: CustomScrollView(
        slivers: [
          // AppBar personalizado
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: _eliminarCarrito,
                icon: Icon(Iconsax.trash),
              )
            ],
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mi Carrito',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
          ),

          // Lista de productos
          SliverPadding(
            padding: const EdgeInsets.only(top: 16, bottom: 90),
            sliver: SliverList.separated(
              itemCount: productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCartItem(
                  productos[index],
                  theme,
                  colors,
                  index: index,
                );
              },
            ),
          ),

          // Total flotante
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildFloatingTotalPanel(total, theme, colors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.bag_2,
              size: 80,
              color: colors.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Carrito vacío',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Añade productos para comenzar tu pedido',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Explorar productos',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    ProductoCarrito producto,
    ThemeData theme,
    ColorScheme colors, {
    required int index,
  }) {
    return Dismissible(
      key: Key('cart_item_${producto.idProductoCarrito}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Iconsax.trash, color: colors.error.withOpacity(0.7)),
      ),
      onDismissed: (_) {},
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + (index * 100)),
        curve: Curves.easeOutQuad,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen del producto
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      '${Environment.urlBase}/img/producto_v/${producto.imagen}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      '${Environment.urlBase}/img/producto_v/${producto.imagen}',
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Iconsax.gallery_slash,
                      size: 24,
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 300),
                  imageBuilder: (context, imageProvider) =>
                      Container(), // Contenedor vacío porque usamos DecorationImage
                ),
              ),
              const SizedBox(width: 16),

              // Detalles del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${producto.descripcion}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bs. ${producto.precioTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Talla: ${producto.talla}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selector de cantidad
              Column(
                children: [
                  TextButton.icon(
                    onPressed: producto.idProductoCarrito == null
                        ? null
                        : () async {
                            await eliminarProductoCarrito(producto.idProductoCarrito!);
                          },
                    icon: Icon(
                      Iconsax.trash,
                      size: 20,
                      color: colors.error.withOpacity(0.85),
                    ),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: colors.error.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: colors.error.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      splashFactory: InkRipple.splashFactory,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildQuantitySelector(producto, colors),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(ProductoCarrito producto, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Iconsax.minus, size: 18, color: colors.onSurface),
            onPressed: producto.idProductoCarrito == null
                ? null
                : () async {
                    await actualizarCantidadProductoCarrito(producto.idProductoCarrito!, -1);
                    await _cargarProductos();
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              producto.cantidad.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Iconsax.add, size: 18, color: colors.onSurface),
            onPressed: producto.idProductoCarrito == null
                ? null
                : () async {
                    await actualizarCantidadProductoCarrito(producto.idProductoCarrito!, 1);
                    await _cargarProductos();
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTotalPanel(
    double total,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Bs. ${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final result =
                    await context.push<bool>('/home/verificacionbiometrica');

                if (result == true) {
                  // Biometría exitosa, proceder con el pago
                  _procesarPagoExitoso();
                } else if (result == false) {
                  // Mostrar mensaje de error en biometría
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verificación biométrica fallida'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                // Si es null, el usuario canceló el proceso
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.card, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Pagar ahora',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPagoExitoso() async {
    final productos = ref.read(carritoPendienteProvider);
    final colors = Theme.of(context).colorScheme;
    final total =
        productos.fold<double>(0.0, (sum, producto) => sum + producto.precioTotal);

    if (productos.isEmpty) return;

    try {
      // 1. Mostrar diálogo de "procesando pago"
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Procesando pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Bs. ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      // 2. Simular tiempo de procesamiento (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // 3. Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      // 4. Mostrar formulario de tarjeta simulado
      final user = FirebaseAuth.instance.currentUser;
      final idCarrito = productos.isNotEmpty && productos.first.idCarrito != null ? productos.first.idCarrito! : 0;
      final uid = user?.uid ?? '';
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _SimuladorTarjetaDialog(
          total: total,
          idCarrito: idCarrito,
          uid: uid,
        ),
      );

      // 5. Si el usuario completó el formulario
      if (result == true) {
        // Limpiar carrito (simulado)
        // ref.read(carritoPendienteProvider.notifier).limpiarCarrito();

        // Mostrar confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Pago simulado exitoso!'),
              backgroundColor: colors.primary,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en simulación: ${e.toString()}'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }
}

class _SimuladorTarjetaDialog extends StatefulWidget {
  final double total;
  final int idCarrito;
  final String uid;

  const _SimuladorTarjetaDialog({
    required this.total,
    required this.idCarrito,
    required this.uid,
  });

  @override
  State<_SimuladorTarjetaDialog> createState() => _SimuladorTarjetaDialogState();
}

class _SimuladorTarjetaDialogState extends State<_SimuladorTarjetaDialog> {
  bool _loading = true;
  String? _codigoProceso;
  String? _error;
  bool _verificando = false;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _iniciarBusquedaPago();
  }

  Future<void> _iniciarBusquedaPago() async {
    try {
      final response = await dio.post(
        '${Environment.urlBase}/qr_transactions/iniciar_busqueda',
        queryParameters: {
          'id_carrito': widget.idCarrito,
          'uid': widget.uid,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'x-api-name': 'Facelook',
            'x-api-version': '1.0',
            'x-developed-by': 'Kurve',
            'x-code': '17145',
          },
        ),
      );
      if (response.data['success'] == true) {
        setState(() {
          _codigoProceso = response.data['codigo_proceso'];
          _loading = false;
        });
        _iniciarVerificacionPago();
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Error desconocido';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión';
        _loading = false;
      });
    }
  }

  Future<void> _iniciarVerificacionPago() async {
    _verificando = true;
    final int maxSegundos = 300; // 5 minutos
    int segundos = 0;
    while (_verificando && segundos < maxSegundos) {
      await Future.delayed(const Duration(seconds: 5));
      segundos += 5;
      try {
        final response = await dio.get(
          '${Environment.urlBase}/qr_transactions/verificar_transaccion',
          queryParameters: {
            'id_carrito': widget.idCarrito,
            'codigo': _codigoProceso,
          },
          options: Options(
            headers: {
              'accept': 'application/json',
              'x-api-name': 'Facelook',
              'x-api-version': '1.0',
              'x-developed-by': 'Kurve',
              'x-code': '17145',
            },
          ),
        );
        if (response.data['success'] == true) {
          final estado = response.data['estado'];
          if (estado == 'C') {
            _verificando = false;
            if (mounted) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pago exitoso: ${response.data['mensaje']}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return;
          } else if (estado == 'T') {
            _verificando = false;
            if (mounted) {
              Navigator.pop(context, false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No se encontró el pago'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      } catch (e) {
        // Ignorar errores de red y seguir intentando
      }
    }
    // Si se agota el tiempo
    if (mounted) {
      Navigator.pop(context, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tiempo agotado, no se completó el pago'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _loading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Iniciando búsqueda de pago...'),
                  ],
                )
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bs. ${widget.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Código de proceso: $_codigoProceso', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 16),
                        const Text(
                          'Escanea el QR para pagar',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: '${Environment.urlBase}/img/qr/union_qr.png',
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey[600],
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.qr_code_2,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              _verificando = false;
                              Navigator.pop(context, false);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}