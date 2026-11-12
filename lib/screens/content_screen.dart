import 'package:flutter/material.dart';
import '../models/content_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/content_category_tabs.dart';
import '../widgets/usuario/content_state_views.dart';
import '../widgets/usuario/content_video_card.dart';
import '../widgets/usuario/content_video_dialog.dart';
import '../widgets/usuario/dash_card.dart';
import '../widgets/usuario/menu_button.dart';

/// Pantalla "Contenido Educativo" alineada con `VolleyScan_Next/src/app/usuario/contenido/page.jsx`.
class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  List<ContentVideo> _videos = const [];
  bool _loading = true;
  String? _error;

  String _cat = 'all';
  int _page = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _cargarContenido();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarContenido() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService().obtenerContenidos();
      if (!mounted) return;
      setState(() {
        _videos = list;
        _loading = false;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = err.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar el contenido.';
      });
    }
  }

  void _changeCat(String cat) {
    if (_cat == cat) return;
    setState(() {
      _cat = cat;
      _page = 1;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _page++;
      _loadingMore = false;
    });
  }

  List<ContentVideo> get _filtered => _cat == 'all'
      ? _videos
      : _videos.where((v) => v.categoria == _cat).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final visible = filtered.take(_page * ContentData.pageSize).toList();
    final hasMore = visible.length < filtered.length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'contenido'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: _cargarContenido,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: DashCard(
                          padding: const EdgeInsets.all(20),
                          borderRadius: AppRadii.authCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _topBar(),
                              const SizedBox(height: 16),
                              ContentCategoryTabs(
                                selected: _cat,
                                onSelect: _changeCat,
                              ),
                              const SizedBox(height: 20),
                              if (_loading)
                                const ContentLoadingView()
                              else if (_error != null)
                                ContentErrorView(
                                  error: _error,
                                  onRetry: _cargarContenido,
                                )
                              else if (filtered.isEmpty)
                                const ContentEmptyView()
                              else ...[
                                _grid(visible),
                                if (hasMore) ...[
                                  const SizedBox(height: 20),
                                  Center(
                                    child: ContentLoadMoreButton(
                                      loading: _loadingMore,
                                      onPressed: _loadMore,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
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

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DashColors.card,
                borderRadius: BorderRadius.circular(AppRadii.panel),
                border: Border.all(color: DashColors.border),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 22,
                color: DashColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Contenido Educativo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        const Text(
          'Contenido educativo',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: DashColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        ContentTopicDropdown(selected: _cat, onChanged: _changeCat),
      ],
    );
  }

  Widget _grid(List<ContentVideo> videos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns;
        if (width >= 760) {
          columns = 3;
        } else if (width >= 420) {
          columns = 2;
        } else {
          columns = 1;
        }
        final spacing = 14.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;
        final thumbHeight = cardWidth * 9 / 16;
        final cardExtent = thumbHeight + 86;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cardExtent,
          ),
          itemBuilder: (_, i) => ContentVideoCard(
            key: ValueKey(videos[i].id),
            video: videos[i],
            onTap: () => showContentVideoDialog(context, videos[i]),
          ),
        );
      },
    );
  }
}
