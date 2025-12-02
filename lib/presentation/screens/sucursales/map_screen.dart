import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/sucursal.dart';
import 'package:facelock/domain/repositories/Sucursal_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> with TickerProviderStateMixin {
  final SucursalService _sucursalService = SucursalService();
  List<Sucursal> _sucursales = [];
  bool _isLoading = true;
  LatLng? _initialCenter;
  final MapController _mapController = MapController();
  Sucursal? _selectedSucursal;
  int _currentImageIndex = 0;
  late PageController _pageController;
  bool _showDetail = false;
  late AnimationController _detailController;
  late Animation<double> _detailAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _detailController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _detailAnimation = CurvedAnimation(
      parent: _detailController,
      curve: Curves.easeInOut,
    );
    _loadSucursales();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _loadSucursales() async {
    try {
      final response = await _sucursalService.getSucursales();
      
      if (response.data.isNotEmpty) {
        double latSum = 0;
        double lonSum = 0;
        for (var sucursal in response.data) {
          latSum += sucursal.latitud;
          lonSum += sucursal.longitud;
        }
        _initialCenter = LatLng(latSum / response.data.length, lonSum / response.data.length);
      } else {
        _initialCenter = const LatLng(-16.5, -68.15);
      }

      setState(() {
        _sucursales = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _initialCenter = const LatLng(-16.5, -68.15);
        _isLoading = false;
      });
    }
  }

  void _showSucursalDetail(Sucursal sucursal) {
    setState(() {
      _selectedSucursal = sucursal;
      _currentImageIndex = 0;
      _showDetail = true;
    });
    _detailController.forward();
    _mapController.move(LatLng(sucursal.latitud, sucursal.longitud), 14);
  }

  void _closeDetail() {
    _detailController.reverse().then((_) {
      setState(() {
        _selectedSucursal = null;
        _showDetail = false;
        _currentImageIndex = 0;
      });
    });
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  Future<void> _openDirections(double lat, double lon) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Color _getColorByCiudad(String ciudad) {
    if (ciudad.contains('La Paz')) return const Color(0xFF4A90E2);
    if (ciudad.contains('El Alto')) return const Color(0xFFE74C3C);
    if (ciudad.contains('Cochabamba')) return const Color(0xFF2ECC71);
    if (ciudad.contains('Santa Cruz')) return const Color(0xFFF39C12);
    return const Color(0xFF9B59B6);
  }

  List<String> _getImages(Sucursal sucursal) {
    final images = <String>[];
    if (sucursal.imagen1 != null && sucursal.imagen1!.isNotEmpty) {
      images.add('${Environment.urlBase}/img/sucursales/${sucursal.imagen1!}');
    }
    if (sucursal.imagen2 != null && sucursal.imagen2!.isNotEmpty) {
      images.add('${Environment.urlBase}/img/sucursales/${sucursal.imagen2!}');
    }
    if (sucursal.imagen3 != null && sucursal.imagen3!.isNotEmpty) {
      images.add('${Environment.urlBase}/img/sucursales/${sucursal.imagen3!}');
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Cargando sucursales...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Mapa principal
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter ?? const LatLng(-16.5, -68.15),
              initialZoom: 6,
              minZoom: 3,
              maxZoom: 18,
              onTap: (_, __) {
                if (_showDetail) {
                  _closeDetail();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.facelock.app',
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // Overlay semi-transparente cuando hay detalle
          if (_showDetail)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDetail,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),

          // Encabezado con diseño mejorado
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildHeader(),
          ),

          // Controles de zoom con diseño mejorado
          Positioned(
            right: 16,
            bottom: 160,
            child: _buildZoomControls(),
          ),

          // Panel de detalle con overlay
          if (_selectedSucursal != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 5) {
                    _closeDetail();
                  }
                },
                child: AnimatedBuilder(
                  animation: _detailAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _detailAnimation.value) * 500),
                      child: _buildDetailPanel(_selectedSucursal!),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _showDetail ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _showDetail ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sucursales',
                  style: TextStyle(
                    color: _showDetail ? Colors.white : Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_sucursales.length} disponibles',
                  style: TextStyle(
                    color: _showDetail ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _loadSucursales,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _showDetail ? Colors.white.withOpacity(0.2) : const Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  color: _showDetail ? Colors.white : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _showDetail ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: _showDetail ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.add,
            onPressed: _zoomIn,
            isVisible: !_showDetail,
          ),
          Container(
            width: 40,
            height: 1,
            color: _showDetail ? Colors.transparent : Colors.grey[200],
          ),
          _buildControlButton(
            icon: Icons.remove,
            onPressed: _zoomOut,
            isVisible: !_showDetail,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isVisible,
  }) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A90E2),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(Sucursal sucursal) {
    final images = _getImages(sucursal);
    final color = _getColorByCiudad(sucursal.ciudad);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle para cerrar con icono
          GestureDetector(
            onTap: _closeDetail,
            child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                    size: 30,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Slider de imágenes con diseño mejorado
          if (images.isNotEmpty) ...[
            Container(
              height: 220,
              child: _buildImagesSlider(images, color, sucursal.nombre),
            ),
            const SizedBox(height: 20),
          ],

          // Información de la sucursal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sucursal.nombre,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: color, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sucursal.direccion,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tarjetas de información
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Teléfono',
                        value: sucursal.telefono.toString(),
                        color: Colors.green[600]!,
                      ),
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Desde',
                        value: '${sucursal.fechaApertura.year}',
                        color: Colors.blue[600]!,
                      ),
                      _buildInfoCard(
                        icon: Icons.location_city,
                        title: 'Ciudad',
                        value: sucursal.ciudad,
                        color: color,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Estado con diseño mejorado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: sucursal.estado 
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sucursal.estado 
                          ? const Color(0xFFC8E6C9)
                          : const Color(0xFFFFCDD2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sucursal.estado ? Icons.check_circle : Icons.cancel,
                        color: sucursal.estado ? Colors.green[600] : Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sucursal.estado ? 'Sucursal abierta' : 'Sucursal cerrada',
                        style: TextStyle(
                          color: sucursal.estado ? Colors.green[800] : Colors.red[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Botón de acción con diseño premium
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openDirections(sucursal.latitud, sucursal.longitud),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Cómo llegar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildImagesSlider(List<String> imageUrls, Color color, String sucursalNombre) {
    return Column(
      children: [
        // Indicador de imágenes con diseño mejorado
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageUrls.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentImageIndex == index ? color : Colors.grey[300],
                  boxShadow: _currentImageIndex == index ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ] : [],
                ),
              );
            }),
          ),
        ),

        // Slider de imágenes con overlay
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    // Imagen con borde
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(color: color),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Imagen no disponible',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Badge de número de imagen
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1}/${imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return _sucursales.map((sucursal) {
      final color = _getColorByCiudad(sucursal.ciudad);
      final isSelected = _selectedSucursal?.idSucursal == sucursal.idSucursal;
      final hasImages = _getImages(sucursal).isNotEmpty;
      
      return Marker(
        width: isSelected ? 70 : 52,
        height: isSelected ? 70 : 52,
        point: LatLng(sucursal.latitud, sucursal.longitud),
        child: GestureDetector(
          onTap: () => _showSucursalDetail(sucursal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.4 : 0.2),
                  blurRadius: isSelected ? 20 : 12,
                  spreadRadius: isSelected ? 4 : 2,
                ),
              ],
              border: Border.all(
                color: color,
                width: isSelected ? 4 : 3,
              ),
            ),
            child: Center(
              child: Stack(
                children: [
                  Icon(
                    hasImages ? Icons.store_mall_directory : Icons.location_on,
                    color: color,
                    size: isSelected ? 28 : 22,
                  ),
                  if (hasImages && !isSelected)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.photo,
                            color: Colors.white,
                            size: 6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}