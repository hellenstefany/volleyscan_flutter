import 'package:flutter/material.dart';
import '../models/content_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/content_category_tabs.dart';
import '../widgets/usuario/content_video_card.dart';
import '../widgets/usuario/content_video_dialog.dart';
import '../widgets/usuario/menu_button.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  // TODO: cargar los videos reales desde tu API.
  final List<ContentVideo> _all = ContentData.videos;

  String _cat = 'all';
  int _page = 1;
  bool _loadingMore = false;

  void _changeCat(String cat) => setState(() {
    _cat = cat;
    _page = 1;
  });

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _page++;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _cat == 'all'
        ? _all
        : _all.where((v) => v.cat == _cat).toList();
    final visible = filtered.take(_page * ContentData.pageSize).toList();
    final hasMore = visible.length < filtered.length;

    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const MenuButton(),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Contenido Educativo',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      drawer: const UserDrawer(
        selectedId: 'contenido',
      ), // cambia el id en cada archivo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: RoutineColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: RoutineColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 12,
                  children: [
                    const Text(
                      'Contenido educativo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ContentTopicDropdown(selected: _cat, onChanged: _changeCat),
                  ],
                ),
                const SizedBox(height: 16),
                ContentCategoryTabs(selected: _cat, onSelect: _changeCat),
                const SizedBox(height: 18),
                if (filtered.isEmpty) _emptyState() else _grid(visible),
                if (hasMore) ...[
                  const SizedBox(height: 20),
                  Center(child: _loadMoreButton()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(List<ContentVideo> videos) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 700 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 205,
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

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.movie_outlined,
              size: 42,
              color: RoutineColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No hay videos para esta categoría.',
              style: TextStyle(color: RoutineColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadMoreButton() {
    return ElevatedButton.icon(
      onPressed: _loadingMore ? null : _loadMore,
      icon: _loadingMore
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.play_circle_fill_rounded, size: 20),
      label: Text(
        _loadingMore ? 'Cargando…' : 'Ver más contenido',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        disabledBackgroundColor: const Color(0xFF3B82F6).withOpacity(0.6),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
