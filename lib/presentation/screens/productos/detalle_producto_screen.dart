import 'package:cached_network_image/cached_network_image.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/presentation/provider/producto_carrito/producto_carrito_provider.dart';
import 'package:facelock/presentation/provider/productos/producto_providers.dart';
import 'package:facelock/presentation/widgets/home/producto_horizontal_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facelock/presentation/provider/productos/detalle_producto_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class DetalleProductoScreen extends ConsumerStatefulWidget {
  final int idProducto;
  const DetalleProductoScreen({super.key, required this.idProducto});

  @override
  ConsumerState<DetalleProductoScreen> createState() =>
      _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends ConsumerState<DetalleProductoScreen> {
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0;
  final _scrollController = ScrollController();
  bool _isFavorite = false;
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [
    {
      'name': 'María Pérez',
      'rating': 5.0,
      'time': 'Hace 2 días',
      'comment': 'Excelente calidad, me encantó el producto. Muy cómodo y el color es exactamente como en la foto.',
      'avatar': 'M',
      'verified': true,
    },
    {
      'name': 'Carlos López',
      'rating': 4.0,
      'time': 'Hace 1 semana',
      'comment': 'Buen producto, la talla es la correcta. La entrega fue rápida.',
      'avatar': 'C',
      'verified': true,
    },
    {
      'name': 'Ana González',
      'rating': 5.0,
      'time': 'Hace 3 días',
      'comment': 'Perfecto para el uso diario. Material de buena calidad.',
      'avatar': 'A',
      'verified': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productoDetalleProvider.notifier).loadProducto(widget.idProducto);
      ref.read(getSimilaresProvider.notifier).loadSimilar(widget.idProducto);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  List<Color> obtenerColoresDesdeHex(String coloresHex) {
    final hexList = coloresHex.split(',').map((e) => e.trim()).toList();
    return hexList.map((hex) => hexToColor(hex)).toList();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isFavorite ? Iconsax.heart5 : Iconsax.heart,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isFavorite 
                ? 'Añadido a favoritos' 
                : 'Eliminado de favoritos',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: _isFavorite ? Colors.pink : Colors.grey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    final newComment = {
      'name': 'Tú',
      'rating': 5.0,
      'time': 'Ahora',
      'comment': _commentController.text,
      'avatar': 'T',
      'verified': true,
    };
    
    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
      _showComments = true;
    });
    
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Comentario publicado'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Material(
        color: Colors.black.withOpacity(0.3),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _toggleFavorite,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                key: ValueKey(_isFavorite),
                color: _isFavorite ? Colors.pink : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentarios (${_comments.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showComments ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _showComments = !_showComments;
                    });
                  },
                ),
              ],
            ),
            
            if (_showComments) ...[
              const SizedBox(height: 16),
              
              // Campo para añadir comentario
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'T',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Escribe tu comentario...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RatingBar.builder(
                          initialRating: 5.0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            // Calificación del usuario
                          },
                        ),
                        ElevatedButton(
                          onPressed: _addComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('Publicar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Lista de comentarios
              ..._comments.map((comment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: comment['name'] == 'Tú' 
                                ? theme.colorScheme.primary 
                                : Colors.blueGrey,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                comment['avatar'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (comment['verified'])
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Iconsax.verify,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  comment['time'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RatingBarIndicator(
                            rating: comment['rating'],
                            itemBuilder: (context, index) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16,
                            unratedColor: Colors.grey[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment['comment'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Iconsax.like_1,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Text(
                            'Útil',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(
                              Iconsax.dislike,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productoAsync = ref.watch(productoDetalleProvider);
    final similarAsync = ref.watch(getSimilaresProvider);

    final expandedHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      extendBodyBehindAppBar: true,

      bottomNavigationBar: _BottomBar(
        productoAsync: productoAsync,
        selectedColorIndex: selectedColorIndex,
        selectedSizeIndex: selectedSizeIndex,
      ),
      body: productoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
        data: (producto) {
          final colorActual = producto.colores[selectedColorIndex];
          final imageUrl =
              "${Environment.urlBase}/img/producto_v/${colorActual.imagen}";

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Imagen principal con efecto parallax
                  SliverAppBar(
                    expandedHeight: expandedHeight,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      background: Hero(
                        tag: 'product-${producto.idProducto}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[100],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 60),
                                    ),
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.6, 1],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Contenido principal
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),
                        // Encabezado con nombre y precio
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: 4.8,
                                        itemBuilder:
                                            (context, index) => const Icon(
                                              Icons.star_rounded,
                                              color: Colors.amber,
                                            ),
                                        itemCount: 5,
                                        itemSize: 20,
                                        unratedColor: Colors.amber.withAlpha(50),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '4.8 (${_comments.length} opiniones)',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Bs. ${producto.precio.toStringAsFixed(2)}",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  producto.genero,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  producto.para,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Descripción
                        Text(
                          'Descripción',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          producto.descripcion,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Selector de colores
                        Text(
                          'Colores disponibles',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: producto.colores.length,
                            itemBuilder: (context, index) {
                              final color = producto.colores[index];
                              final isSelected = index == selectedColorIndex;
                              final colores = obtenerColoresDesdeHex(color.colores);

                              return GestureDetector(
                                onTap:
                                    () => setState(() {
                                      selectedColorIndex = index;
                                      selectedSizeIndex = 0;
                                    }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? theme.colorScheme.primary
                                              : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors:
                                            colores.length > 1
                                                ? colores
                                                : [colores.first, colores.first],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Selector de tallas
                        Text(
                          'Tallas disponibles',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(colorActual.tallas.length, (
                            index,
                          ) {
                            final talla = colorActual.tallas[index];
                            final isSelected = index == selectedSizeIndex;
                            return GestureDetector(
                              onTap:
                                  () => setState(() => selectedSizeIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? theme.colorScheme.primary.withOpacity(
                                            0.1,
                                          )
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  talla.talla,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ]),
                    ),
                  ),
                  
                  // Ubicación del producto
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        Text(
                          'Ubicación del producto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  producto.sucursal.latitud,
                                  producto.sucursal.longitud,
                                ),
                                initialZoom: 16,
                                interactionOptions: const InteractionOptions(
                                  flags:
                                      InteractiveFlag.pinchZoom |
                                      InteractiveFlag.drag,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.facelock.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: LatLng(
                                        producto.sucursal.latitud,
                                        producto.sucursal.longitud,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          producto.sucursal.nombre,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          producto.sucursal.direccion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Tel: ${producto.sucursal.telefono}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ]),
                    ),
                  ),

                  // Sección de comentarios
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildCommentsSection(),
                    ),
                  ),

                  // Productos relacionados
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        Text(
                          'Productos relacionados',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ProductoHorizontalList(
                          productos: similarAsync,
                          scrol: "similares",
                        ),
                        const SizedBox(height: 100), // Espacio para el bottom bar
                      ]),
                    ),
                  ),
                ],
              ),
              
              // Botón de favorito flotante
              _buildFavoriteButton(),
            ],
          );
        },
      ),
    );
  }
}

class _BottomBar extends ConsumerStatefulWidget {
  final AsyncValue<dynamic> productoAsync;
  final int selectedColorIndex;
  final int selectedSizeIndex;

  const _BottomBar({
    required this.productoAsync,
    required this.selectedColorIndex,
    required this.selectedSizeIndex,
  });

  @override
  ConsumerState<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<_BottomBar> {
  int counter = 1;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: widget.productoAsync.when(
          loading:
              () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (_, __) => const SizedBox(),
          data:
              (producto) => Row(
                children: [
                  // Contador de cantidad
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (counter > 1) {
                              setState(() {
                                counter--;
                              });
                            }
                          },
                        ),
                        Text(
                          '$counter',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              counter++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Botón principal de añadir al carrito
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final producto = widget.productoAsync.value!;
                        final colorSeleccionado =
                            producto.colores[widget.selectedColorIndex];
                        final tallaSeleccionada =
                            colorSeleccionado.tallas[widget.selectedSizeIndex];

                        final carritoItem = ProductoCarrito(
                          fechaAnadido: DateTime.now(),
                          cantidad: counter,
                          talla: tallaSeleccionada.talla,
                          precioUnitario: producto.precio,
                          precioTotal: producto.precio * counter,
                          idColorProducto: colorSeleccionado.idColorProducto,
                        );

                        // Llama al notifier usando ref
                        ref
                            .read(carritoProvider.notifier)
                            .agregarProducto(carritoItem);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Iconsax.shopping_cart,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Producto añadido al carrito',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            elevation: 4,
                            duration: const Duration(seconds: 2),
                            dismissDirection: DismissDirection.horizontal,
                            animation: CurvedAnimation(
                              parent: AnimationController(
                                duration: const Duration(milliseconds: 300),
                                vsync: Scaffold.of(context),
                              ),
                              curve: Curves.easeOutCubic,
                            ),
                            action: SnackBarAction(
                              label: 'Ver carrito',
                              textColor: theme.colorScheme.onPrimary.withOpacity(0.8),
                              onPressed: () {
                                // Navegar al carrito
                              },
                            ),
                          ),
                        );
                        setState(() {
                          counter = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Iconsax.shopping_cart,
                        size: 20,
                      ),
                      label: const Text(
                        'Añadir al carrito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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