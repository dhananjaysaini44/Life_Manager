import 'package:flutter/material.dart';
import '../../data/database.dart';

class SubTaskItem extends StatefulWidget {
  final SubTask subTask;
  final VoidCallback onToggle;

  const SubTaskItem({
    super.key,
    required this.subTask,
    required this.onToggle,
  });

  @override
  State<SubTaskItem> createState() => _SubTaskItemState();
}

class _SubTaskItemState extends State<SubTaskItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = widget.subTask.isCompleted;

    Color checkColor;
    if (isCompleted) {
      checkColor = Colors.green;
    } else if (widget.subTask.hasAttachment) {
      checkColor = Colors.orange;
    } else {
      checkColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onToggle();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: checkColor,
                width: 2,
              ),
              color: isCompleted ? checkColor : Colors.transparent,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white, key: ValueKey('check'))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ),
      ),
      title: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              color: isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            ),
        child: Text(widget.subTask.title),
      ),
      trailing: widget.subTask.hasAttachment
          ? Icon(Icons.attach_file, size: 18, color: colorScheme.onSurfaceVariant)
          : null,
    );
  }
}
