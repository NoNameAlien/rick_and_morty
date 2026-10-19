import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../domain/entities/character.dart';
import 'character_visuals.dart';

class CharacterCard extends StatefulWidget {
  const CharacterCard({
    required this.character,
    required this.onTap,
    super.key,
  });
  final Character character;
  final VoidCallback onTap;

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed
        ? .97
        : _hovered
        ? 1.015
        : 1,
    duration: const Duration(milliseconds: 130),
    child: Semantics(
      button: true,
      onTap: widget.onTap,
      label:
          '${widget.character.name}, ${widget.character.status}. Open details',
      excludeSemantics: true,
      child: Material(
        color: _hovered ? AppColors.raised : AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (value) => setState(() => _hovered = value),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'character-${widget.character.id}',
                      child: CharacterImage(url: widget.character.image),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusBadge(status: widget.character.status),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  height: MediaQuery.textScalerOf(context).scale(16) * 3,
                  child: Text(
                    widget.character.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
