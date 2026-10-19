import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../domain/entities/character.dart';
import '../widgets/character_visuals.dart';

class CharacterDetailsPage extends StatelessWidget {
  const CharacterDetailsPage({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 960 &&
              MediaQuery.textScalerOf(context).scale(16) <= 24;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1160 : 760),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 32 : 16,
                        wide ? 24 : 8,
                        24,
                        16,
                      ),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back to catalog',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'CHARACTER FILE',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ),
                          Text(
                            '#${character.id.toString().padLeft(3, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (wide)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _Portrait(character: character)),
                              const SizedBox(width: 64),
                              Expanded(
                                child: _Profile(
                                  character: character,
                                  compact: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _Portrait(character: character),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _Profile(character: character),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: AppColors.mint.withValues(alpha: .09),
          blurRadius: 60,
          spreadRadius: 4,
        ),
      ],
    ),
    child: AspectRatio(
      aspectRatio: 1,
      child: Hero(
        tag: 'character-${character.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: CharacterImage(url: character.image),
        ),
      ),
    ),
  );
}

class _Profile extends StatelessWidget {
  const _Profile({required this.character, this.compact = false});
  final Character character;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      StatusBadge(status: character.status),
      const SizedBox(height: 16),
      Text(
        character.name,
        style: Theme.of(
          context,
        ).textTheme.displaySmall?.copyWith(fontSize: compact ? 46 : null),
      ),
      const SizedBox(height: 12),
      Text(
        'A life somewhere in the multiverse.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      ),
      SizedBox(height: compact ? 24 : 32),
      Text(
        'DIMENSIONAL PROFILE',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.mint),
      ),
      const SizedBox(height: 16),
      _InfoBlock(
        icon: Icons.fingerprint_rounded,
        label: 'Species',
        value: character.species,
      ),
      _InfoBlock(
        icon: Icons.public_rounded,
        label: 'Origin',
        value: character.origin,
      ),
      _InfoBlock(
        icon: Icons.location_on_outlined,
        label: 'Last Known Location',
        value: character.location,
      ),
    ],
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mint, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    ),
  );
}
