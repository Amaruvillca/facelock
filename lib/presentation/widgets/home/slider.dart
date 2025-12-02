import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LuxuryFashionSlider extends StatefulWidget {
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
  State<LuxuryFashionSlider> createState() => _LuxuryFashionSliderState();
}

class _LuxuryFashionSliderState extends State<LuxuryFashionSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _currentPage = 0;
  bool _isAutoPlaying = true;
  Timer? _autoPlayTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (!_isVisible) return;
    
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isAutoPlaying && _isVisible && mounted) {
        if (_currentPage < LuxuryFashionSlider.fashionItems.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void _pauseAutoPlay() {
    setState(() => _isAutoPlaying = false);
    _autoPlayTimer?.cancel();
  }

  void _resumeAutoPlay() {
    setState(() => _isAutoPlaying = true);
    _startAutoPlay();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    setState(() {
      _isVisible = info.visibleFraction > 0.5;
    });
    
    if (_isVisible && _isAutoPlaying) {
      _startAutoPlay();
    } else {
      _autoPlayTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;

    return VisibilityDetector(
      key: const Key('fashion_slider'),
      onVisibilityChanged: _onVisibilityChanged,
      child: SizedBox(
        height: size.width * 0.85,
        child: Column(
          children: [
            // Slider principal
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => _pauseAutoPlay(),
                onTapUp: (_) => Future.delayed(
                  const Duration(seconds: 3),
                  _resumeAutoPlay,
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemCount: LuxuryFashionSlider.fashionItems.length,
                  itemBuilder: (context, index) {
                    final item = LuxuryFashionSlider.fashionItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _LuxuryFashionCard(
                        title: item['title'],
                        subtitle: item['subtitle'],
                        imageUrl: item['image'],
                        price: item['price'],
                        tag: item['tag'],
                        isActive: index == _currentPage,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Indicadores de página
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                LuxuryFashionSlider.fashionItems.length,
                (index) => _PageIndicator(
                  isActive: index == _currentPage,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 20 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
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
  final bool isActive;

  const _LuxuryFashionCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.tag,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen optimizada con pre-carga
            _OptimizedLuxuryImage(
              imageUrl: imageUrl,
              isActive: isActive,
            ),

            // Overlay de degradado optimizado
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.8],
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),

            // Tag de categoría
            Positioned(
              top: 20,
              right: 20,
              child: _FashionTag(tag: tag),
            ),

            // Contenido inferior
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FashionContent(
                title: title,
                subtitle: subtitle,
                price: price,
                colors: colors,
                textTheme: textTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptimizedLuxuryImage extends StatelessWidget {
  final String imageUrl;
  final bool isActive;

  const _OptimizedLuxuryImage({
    required this.imageUrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeIn,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      cacheKey: imageUrl.hashCode.toString(),
      maxWidthDiskCache: 400,
      maxHeightDiskCache: 400,
      memCacheWidth: 400,
      memCacheHeight: 400,
      useOldImageOnUrlChange: true,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Iconsax.gallery,
          size: 50,
          color: Colors.white30,
        ),
      ),
    );
  }
}

class _FashionTag extends StatelessWidget {
  final String tag;

  const _FashionTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTagColor(tag, colors).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        tag,
        style: textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          fontSize: 11,
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

class _FashionContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final ColorScheme colors;
  final TextTheme textTheme;

  const _FashionContent({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y subtítulo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Precio y botón de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  price,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              // Botón de acción
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Acción al presionar el botón
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.shopping_bag,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}