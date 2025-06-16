import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/presentation/widgets/home/producto_vertial_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';

class AppbarCustom extends StatelessWidget {
  const AppbarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(PhosphorIconsRegular.camera),
                  onPressed: () => _showImageSourceDialog(context),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 104, 103, 103),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _NotificationButton(),
        const SizedBox(width: 10),
        _LocationButton(),
      ],
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    try {
      final result = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Buscar por imagen'),
          content: const Text('Selecciona el origen de la imagen'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Galería'),
            ),
          ],
        ),
      );

      if (result != null && context.mounted) {
        final pickedFile = await ImagePicker().pickImage(
          source: result,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        
        if (pickedFile != null && context.mounted) {
          await _showImagePreviewBottomSheet(context, pickedFile.path);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showImagePreviewBottomSheet(BuildContext context, String imagePath) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSearchResults(imagePath: imagePath),
    );
  }
}

class ImageSearchResults extends StatefulWidget {
  final String imagePath;

  const ImageSearchResults({super.key, required this.imagePath});

  @override
  State<ImageSearchResults> createState() => _ImageSearchResultsState();
}

class _ImageSearchResultsState extends State<ImageSearchResults> {
  late final Future<Map<String, dynamic>> _searchFuture;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _searchFuture = _searchProductsByImage(widget.imagePath);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<Map<String, dynamic>> _searchProductsByImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      final dio = Dio();
      final response = await dio.post(
        '${Environment.urlBase}/comparar-imagenes',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error en la respuesta del servidor');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!['data'] == null) {
            return _buildErrorState('No se encontraron resultados');
          }

          final products = snapshot.data!['data'] as List<dynamic>;
          return _buildSuccessState(products);
        },
      ),
    );
  }

  Widget _buildSuccessState(List<dynamic> products) {
    return Column(
      children: [
        _buildDragHandle(),
        _buildImagePreview(),
        const SizedBox(height: 16),
        Text(
          '${products.length} resultados encontrados',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData = products[index];
              final producto = Producto(
              idProducto: productData['id_producto'] ?? 0,
              nombre: productData['nombre'] ?? 'Sin nombre',
              descripcion: productData['descripcion'] ?? 'Sin descripción',
              imagen: productData['imagen'] ?? '',
              fechaCreacion: DateTime.parse(productData['fecha'] ?? DateTime.now().toString()),
              genero: productData['genero'] ?? 'Unisex',
              precio: (productData['precio'] as num?)?.toDouble() ?? 0.0,
              para: productData['para'] ?? 'General',
              idSucursal: productData['id_sucursal'] ?? 0,
              idCategoria: productData['id_categoria'] ?? 0,
              bannerProducto: productData['banner'] ?? '',
              promedioCalificacion: (productData['promedio_calificacion'] as num?)?.toDouble() ?? 0.0,
            );
             //return _buildProductCard(products[index]);
             return FadeIn(child: CardVertical(producto: producto));
            } 
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 50, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(widget.imagePath),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[200],
              ),
              child: Center(
                child: product['imagen'] != null
                    ? Image.network(
                        'http://192.168.0.5:8000/img/productos/${product['imagen']}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      )
                    : const Icon(Icons.shopping_bag, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product['precio']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['descripcion'] ?? 'Sin descripción',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// Los widgets _NotificationButton y _LocationButton permanecen igual

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {},
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(PhosphorIconsRegular.bell, size: 24),
            ),
            Positioned(
              right: 0,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 199, 57, 47),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(PhosphorIconsRegular.mapPin, size: 24),
        ),
      ),
    );
  }
}