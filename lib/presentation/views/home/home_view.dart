import 'package:animate_do/animate_do.dart';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/presentation/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facelock/presentation/widgets/home/home_widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([
        ref.read(recientesProductosProvider.notifier).loadNextPage(),
        ref.read(getProductosProvider.notifier).loadNextPage(),
        ref.read(getMejoresCalificadasProvider.notifier).loadNextPage(),
      ]);
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _initialLoadCompleted = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_initialLoadCompleted) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (currentScroll + 500 >= maxScroll) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      await ref.read(getProductosProvider.notifier).loadNextPage();
    } catch (e) {
      debugPrint('Error loading more products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar más productos: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final recientePro = ref.watch(recientesProductosProvider);
    final mejorCali = ref.watch(getMejoresCalificadasProvider);
    final productos = ref.watch(getProductosProvider);


    if (!_initialLoadCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          elevation: 1,
          title: AppbarCustom(),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _HorizontalBanner(),
              _SectionTitle('Categorías'),
              const CategoryList(),
              _SectionTitle('Nuevas llegadas'),
              ProductoHorizontalList(productos: recientePro, scrol: "recientes"),
              _SectionTitle('Tendencias'),
              ProductoHorizontalList(productos: mejorCali, scrol: "tedencias"),
              _SectionTitle('Anuncios'),
              const LuxuryFashionSlider(),
              _SectionTitle('Más Productos'),
              const SizedBox(height: 10),
            ],
          ),
        ),
        _ProductGrid(productos: productos),
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ProductGrid extends ConsumerWidget {
  final List<Producto> productos;
  
  const _ProductGrid({required this.productos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final producto = productos[index];
            return FadeInUp(
              child: CardVertical(producto: producto),
            );
          },
          childCount: productos.length,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _HorizontalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: BannerCard(
              context: context,
              title: 'Ofertas de la semana',
              image: 'assets/oferta.png', // Ruta a tu imagen
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withOpacity(0.8),
                  colors.primary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BannerCard(
              context: context,
              title: 'Colección destacada',
              image: 'assets/destacado.webp',
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pinkAccent.withOpacity(0.8),
                  Colors.deepPurple.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String image;
  final Gradient gradient;

  const BannerCard({
    super.key,
    required this.context,
    required this.title,
    required this.image,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay con gradiente
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Ver más'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}