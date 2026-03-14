import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final double value;
  final String? unit;
  final IconData icon;
  final bool isFullWidth;
  final bool isHighlighted;
  final double? progress;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '',
    required this.icon,
    this.isFullWidth = false,
    this.isHighlighted = false,
    this.progress,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: widget.isHighlighted ? colorScheme.primary : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: widget.isHighlighted ? BorderSide.none : BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  widget.icon,
                  color: widget.isHighlighted ? colorScheme.onPrimary : colorScheme.primary,
                  size: 20,
                ),
                if (!widget.isHighlighted)
                  Text(
                    '+5%',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${_animation.value.toInt()}${widget.unit}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: widget.isHighlighted ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: widget.isHighlighted ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                  ),
            ),
            if (widget.isHighlighted && widget.progress != null) ...[
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.progress!),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
