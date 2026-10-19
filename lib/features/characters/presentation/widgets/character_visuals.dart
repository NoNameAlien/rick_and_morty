import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({required this.url, super.key});
  final String url;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    placeholder: (_, _) => const ColoredBox(
      color: AppColors.raised,
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 48,
          color: AppColors.muted,
        ),
      ),
    ),
    errorWidget: (_, _, _) => const ColoredBox(
      color: AppColors.raised,
      child: Center(
        child: Icon(
          Icons.person_off_outlined,
          size: 48,
          color: AppColors.muted,
        ),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'alive' => AppColors.lime,
      'dead' => AppColors.coral,
      _ => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PortalMark extends StatelessWidget {
  const PortalMark({this.size = 72, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.mint.withValues(alpha: .2),
            AppColors.lime.withValues(alpha: .07),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: AppColors.lime.withValues(alpha: .3)),
      ),
      padding: EdgeInsets.all(size * .18),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.mint.withValues(alpha: .65),
            width: 2,
          ),
        ),
        child: const Icon(Icons.auto_awesome, color: AppColors.lime, size: 20),
      ),
    ),
  );
}
