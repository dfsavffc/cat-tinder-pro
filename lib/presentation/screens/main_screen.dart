import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/cat_controller.dart';
import '../widgets/cat_stack.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/like_button.dart';
import '../widgets/dislike_button.dart';
import 'liked_cats_screen.dart';
import '../themes/app_theme.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MainScreen({super.key, required this.onToggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showLoader = true;
  bool _dialogScheduled = false;

  void _hideLoader() {
    if (!_showLoader) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showLoader = false);
    });
  }

  void _scheduleErrorDialog(CatController controller) {
    if (_dialogScheduled) return;
    _dialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(
                'Ошибка сети',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              content: Text(
                'Не удалось загрузить данные.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _dialogScheduled = false);
                    controller.reset();
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<CatController>(
        builder: (_, controller, __) {
          if (controller.hasError) _scheduleErrorDialog(controller);

          final stackEmpty = controller.cats.isEmpty;
          final loading = _showLoader || stackEmpty;

          final width = MediaQuery.of(context).size.width * 0.9;
          final height = width * 4 / 3;
          final frameH = height + 24;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child:
                      stackEmpty
                          ? SizedBox(
                            width: width,
                            height: frameH,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: const LoadingIndicator(),
                            ),
                          )
                          : CatStack(
                            cats: controller.cats,
                            isLoading: loading,
                            onSwipe: (liked) {
                              setState(() => _showLoader = true);
                              controller.handleSwipe(liked);
                            },
                            onTopLoaded: _hideLoader,
                          ),
                ),
              ),

              SizedBox(
                height: 40,
                child: AnimatedOpacity(
                  opacity: loading ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child:
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DislikeButton(
                      onPressed: () {
                        setState(() => _showLoader = true);
                        controller.handleSwipe(false);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stackEmpty
                            ? 'Загрузка…'
                            : controller.cats.first.breedName,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    LikeButton(
                      onPressed: () {
                        setState(() => _showLoader = true);
                        controller.handleSwipe(true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext ctx) => AppBar(
    title: const Text('Cat Tinder'),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Consumer<CatController>(
          builder:
              (_, c, __) => GestureDetector(
                onTap:
                    () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => const LikedCatsScreen(),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.badgeBg(ctx),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${c.likedCats.length}',
                        style: Theme.of(ctx).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.brightness_6),
        onPressed: widget.onToggleTheme,
      ),
    ],
  );
}
