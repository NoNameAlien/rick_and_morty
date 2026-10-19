import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_theme.dart';
import '../cubit/characters_cubit.dart';
import '../cubit/characters_state.dart';
import '../widgets/character_card.dart';
import '../widgets/character_visuals.dart';
import '../widgets/catalog_feedback.dart';
import 'character_details_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _scroll = ScrollController();
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: context.read<CharactersCubit>().state.searchQuery,
    );
    _scroll.addListener(_loadNearEnd);
  }

  void _loadNearEnd() {
    if (!mounted || !_scroll.hasClients || _scroll.position.extentAfter > 360) {
      return;
    }
    final cubit = context.read<CharactersCubit>();
    if (cubit.state.loadMoreError == null) cubit.loadNextPage();
  }

  void _searchChanged(String value) {
    context.read<CharactersCubit>().searchQueryChanged(value);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _clearSearch() {
    _search.clear();
    _searchChanged('');
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: BlocConsumer<CharactersCubit, CharactersState>(
            listener: (_, state) {
              if (state.status == CharactersStatus.success &&
                  !state.isLoadingMore &&
                  state.loadMoreError == null) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _loadNearEnd(),
                );
              }
            },
            builder: (context, state) => LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth < 600 ? 24.0 : 40.0;
                final available = constraints.maxWidth - padding * 2;
                final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
                final minTileWidth = scale > 1.5
                    ? 250.0
                    : switch (available) {
                        >= 900 => 240.0,
                        >= 600 => 200.0,
                        _ => 148.0,
                      };
                final columns = math.max(
                  1,
                  ((available + AppColors.gap) / (minTileWidth + AppColors.gap))
                      .floor(),
                );
                final tileWidth =
                    (available - (columns - 1) * AppColors.gap) / columns;
                final tileHeight = math.min(tileWidth, 300) + 28 + 48 * scale;
                final loading =
                    state.status == CharactersStatus.loading ||
                    state.status == CharactersStatus.initial;
                return CustomScrollView(
                  controller: _scroll,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.lime,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'THE MULTIVERSE',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.lime),
                                  ),
                                ),
                                const Icon(
                                  Icons.blur_circular_rounded,
                                  color: AppColors.muted,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: 'Explore\n'),
                                        TextSpan(
                                          text: 'Characters',
                                          style: TextStyle(
                                            color: AppColors.lime,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displaySmall,
                                  ),
                                ),
                                if (available > 320 && scale < 1.4)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: PortalMark(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Infinite dimensions. Extraordinary lives.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _search,
                              onChanged: _searchChanged,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              decoration: InputDecoration(
                                hintText: 'Search characters...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.muted,
                                ),
                                suffixIcon:
                                    ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: _search,
                                      builder: (_, value, _) =>
                                          value.text.isEmpty
                                          ? const SizedBox.shrink()
                                          : IconButton(
                                              tooltip: 'Clear search',
                                              onPressed: _clearSearch,
                                              icon: const Icon(
                                                Icons.close_rounded,
                                              ),
                                            ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 16,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  state.searchQuery.isEmpty
                                      ? 'Discover'
                                      : 'Search results',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'DIMENSIONAL ARCHIVE',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 9,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                    if (loading)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: tileHeight,
                                crossAxisSpacing: AppColors.gap,
                                mainAxisSpacing: AppColors.gap,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (_, _) => const SkeletonCard(),
                            childCount: columns * 3,
                          ),
                        ),
                      )
                    else if (state.status == CharactersStatus.success)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: tileHeight,
                                crossAxisSpacing: AppColors.gap,
                                mainAxisSpacing: AppColors.gap,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final character = state.characters[index];
                            return CharacterCard(
                              key: ValueKey(character.id),
                              character: character,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CharacterDetailsPage(
                                      character: character,
                                    ),
                                  ),
                                );
                              },
                            );
                          }, childCount: state.characters.length),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: CatalogFeedback(
                          isError: state.status == CharactersStatus.failure,
                          hasSearch: state.searchQuery.isNotEmpty,
                          onRetry: context
                              .read<CharactersCubit>()
                              .loadCharacters,
                          onClear: _clearSearch,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: state.isLoadingMore
                            ? const Center(
                                child: SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : state.loadMoreError != null
                            ? Column(
                                children: [
                                  const Text(
                                    'The next dimension is out of reach.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: context
                                        .read<CharactersCubit>()
                                        .loadNextPage,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              )
                            : state.status == CharactersStatus.success &&
                                  !state.hasMore
                            ? Text(
                                'YOU’VE REACHED THE EDGE OF THIS UNIVERSE',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 9,
                                    ),
                              )
                            : const SizedBox(height: 8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
