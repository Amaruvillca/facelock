import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LuxuryFashionSlider extends StatelessWidget {
  static const List<Map<String, dynamic>> fashionItems = [
    {
      'title': 'Colección Premium',
      'subtitle': 'Edición Limitada',
      'image': 'https://i.pinimg.com/736x/51/4e/53/514e53cee74f4390ff5b3481e4ded1d4.jpg',
      'price': 'Bs. 299',
      'tag': 'Nuevo',
    },
    {
      'title': 'Línea Nocturna',
      'subtitle': 'Elegancia en Negro',
      'image': 'https://i.pinimg.com/736x/cb/46/1d/cb461dd1691bab634a467a304f2a94e7.jpg',
      'price': 'Bs. 249',
      'tag': 'Popular',
    },
    {
      'title': 'Esencia Minimal',
      'subtitle': 'Diseños Puros',
      'image': 'https://i.pinimg.com/236x/74/95/55/749555a30ced83620e8e15fb542e9c07.jpg',
      'price': 'Bs. 179',
      'tag': 'Oferta',
    },
    {
      'title': 'Urban Chic',
      'subtitle': 'Estilo Metropolitano',
      'image': 'https://i.pinimg.com/236x/bc/69/2e/bc692ed8048f026b389ef70bbf7d515c.jpg',
      'price': 'Bs. 349',
      'tag': 'Exclusivo',
    },
  ];

  const LuxuryFashionSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: size.width * 0.85,
      child: Swiper(
        autoplay: true,
        autoplayDelay: 5000,
        duration: 1000,
        curve: Curves.easeInOutCubic,
        itemCount: fashionItems.length,
        viewportFraction: 0.86,
        scale: 0.92,
        physics: const BouncingScrollPhysics(),
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(bottom: 10),
          builder: DotSwiperPaginationBuilder(
            color: colors.outline.withOpacity(0.3),
            activeColor: colors.primary,
            size: 7.0,
            activeSize: 9.0,
            space: 6.0,
          ),
        ),
        itemBuilder: (_, index) {
          final item = fashionItems[index];
          return FadeIn(
            delay: Duration(milliseconds: 150 * index),
            duration: const Duration(milliseconds: 800),
            child: _LuxuryFashionCard(
              title: item['title'],
              subtitle: item['subtitle'],
              imageUrl: item['image'],
              price: item['price'],
              tag: item['tag'],
            ),
          );
        },
      ),
    );
  }
}

class _LuxuryFashionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String price;
  final String tag;

  const _LuxuryFashionCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen principal con efecto de brillo
            _LuxuryImage(imageUrl: imageUrl),

            // Overlay de lujo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.8],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Tag de categoría
            Positioned(
              top: 20,
              right: 20,
              child: FadeInDown(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTagColor(tag, colors),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),

            // Contenido inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y subtítulo
                    FadeInUp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Precio y botón
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Precio
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              price,
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Botón de acción
                          FloatingActionButton.small(
                            backgroundColor: colors.surface.withOpacity(0.9),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: () {},
                            child: const Icon(Iconsax.shopping_bag, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag, ColorScheme colors) {
    switch (tag.toLowerCase()) {
      case 'nuevo':
        return Colors.blueAccent;
      case 'popular':
        return Colors.pinkAccent;
      case 'oferta':
        return Colors.orangeAccent;
      case 'exclusivo':
        return Colors.purpleAccent;
      default:
        return colors.primary;
    }
  }
}

class _LuxuryImage extends StatelessWidget {
  final String imageUrl;

  const _LuxuryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.8),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: Center(
                child: Icon(
                  Iconsax.gallery,
                  size: 50,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            );
          },
        ),
        // Efecto de brillo sutil
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.9,
              colors: [
                Colors.white.withOpacity(0.03),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}