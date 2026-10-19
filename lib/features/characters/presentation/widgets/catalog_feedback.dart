import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import 'character_visuals.dart';

class CatalogFeedback extends StatelessWidget {
  const CatalogFeedback({
    required this.isError,
    required this.hasSearch,
    required this.onRetry,
    required this.onClear,
    super.key,
  });
  final bool isError;
  final bool hasSearch;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 250),
    builder: (_, value, child) => Opacity(opacity: value, child: child),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const PortalMark(size: 88),
          const SizedBox(height: 24),
          Text(
            isError ? 'Signal lost' : 'An unexplored dimension',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            isError
                ? 'We couldn’t reach the archive. Check your connection and try again.'
                : 'No characters found. Try a different name to continue exploring.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, height: 1.6),
          ),
          const SizedBox(height: 24),
          if (isError)
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            )
          else if (hasSearch)
            FilledButton(onPressed: onClear, child: const Text('Clear search')),
        ],
      ),
    ),
  );
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading characters',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radius),
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: ColoredBox(color: AppColors.raised)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: MediaQuery.textScalerOf(context).scale(16) * 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.raised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 8,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.raised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
