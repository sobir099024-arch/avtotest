import 'package:flutter/material.dart';
import '../app_state.dart';
import '../data_repository.dart';
import '../models.dart';
import '../storage.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Question>? _favorites;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await DataRepository.instance.loadQuestions();
    final ids = await Storage.instance.getFavoriteIds();
    if (!mounted) return;
    setState(() => _favorites = all.where((q) => ids.contains(q.id)).toList());
  }

  Future<void> _remove(String id) async {
    await Storage.instance.toggleFavorite(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppStateScope.of(context).locale;
    final favorites = _favorites;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appT(context, 'navFavorites'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Expanded(
              child: favorites == null
                  ? const Center(child: CircularProgressIndicator())
                  : favorites.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border_rounded, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  appT(context, 'favoritesEmpty'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final q = favorites[i];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(q.texts.get(locale), style: const TextStyle(fontSize: 13.5, height: 1.35)),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.favorite_rounded, color: AppColors.danger, size: 20),
                                    onPressed: () => _remove(q.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
