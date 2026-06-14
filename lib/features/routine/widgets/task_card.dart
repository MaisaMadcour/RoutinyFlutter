import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/models.dart';
import '../../../core/routiny_stats.dart';
import '../../../core/task_icons.dart';
import '../../../theme/app_colors.dart';
import 'dashed_rect.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.position,
    required this.dateYmd,
    required this.expanded,
    required this.onLongPress,
    required this.onTapWhenExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskEntity task;
  final int position;
  // The day this card is showing — checks are stored per day.
  final String dateYmd;
  final bool expanded;
  final VoidCallback onLongPress;
  final VoidCallback onTapWhenExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late List<bool> _checks;
  bool _lastAllDone = false;
  bool _confetti = false;
  bool _deleting = false;

  void _startDelete() {
    setState(() => _deleting = true);
  }

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  @override
  void didUpdateWidget(TaskCard old) {
    super.didUpdateWidget(old);
    if (old.task.id != widget.task.id ||
        old.task.subTasks.length != widget.task.subTasks.length ||
        old.dateYmd != widget.dateYmd) {
      _loadChecks();
    }
  }

  void _loadChecks() {
    _checks = List.generate(
      widget.task.subTasks.length,
      (i) => RoutinyStats.isSubtaskChecked(widget.task.id, i, widget.dateYmd),
    );
    _lastAllDone = _allDone;
  }

  bool get _allDone =>
      _checks.isNotEmpty && _checks.every((c) => c);

  Future<void> _toggle(int index) async {
    final v = !_checks[index];
    setState(() => _checks[index] = v);
    await RoutinyStats.setSubtaskChecked(
        widget.task.id, index, widget.dateYmd, v);
    final done = _allDone;
    if (done && !_lastAllDone) {
      await RoutinyStats.recordTaskCompleted(widget.task.id, widget.dateYmd);
      setState(() => _confetti = true);
    } else if (!done && _lastAllDone) {
      await RoutinyStats.unrecordTaskCompleted(widget.task.id, widget.dateYmd);
    }
    _lastAllDone = done;
  }

  Color get _taskColor => AppColors.parseHex(widget.task.colorHex);
  Color get _ribbonColor =>
      widget.position.isEven ? AppColors.ribbon1 : AppColors.ribbon2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          // action toolbar (revealed on long-press, hidden when deleting)
          if (!_deleting)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: widget.expanded ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Center(child: _toolbar()),
              ),
            ),
          // keep the card occupying space even while deleting, so the
          // overlaid Lottie has a box to fill (otherwise the Stack collapses)
          Visibility(
            visible: !_deleting,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(right: widget.expanded ? 58 : 0),
              child: _cardBody(),
            ),
          ),
          if (_deleting)
            Positioned.fill(
              child: Lottie.asset(
                'assets/lottie/cancel.json',
                repeat: false,
                fit: BoxFit.contain,
                onLoaded: (c) {
                  Future.delayed(c.duration, () {
                    if (mounted) widget.onDelete();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolbar() {
    Widget btn(IconData icon, String label, Color bg, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.delete_outline, 'مسح', const Color(0xFF900C20),
            _startDelete),
        const SizedBox(height: 6),
        btn(Icons.edit_outlined, 'تعديل', AppColors.primary, widget.onEdit),
      ],
    );
  }

  Widget _cardBody() {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.expanded ? widget.onTapWhenExpanded : null,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              foregroundPainter:
                  DashedRectPainter(color: AppColors.ribbonNeutral),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 14),
                    _ribbon(),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < widget.task.subTasks.length;
                              i++)
                            _subRow(i),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_confetti)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  repeat: false,
                  onLoaded: (c) {
                    Future.delayed(c.duration, () {
                      if (mounted) setState(() => _confetti = false);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ribbon() {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 0.9,
      child: ClipPath(
        clipper: RibbonClipper(),
        child: Container(
          height: 40,
          color: _ribbonColor,
          padding: const EdgeInsetsDirectional.only(start: 10, end: 22),
          child: Row(
            children: [
              Icon(TaskIcons.of(widget.task.iconResName),
                  size: 18, color: _taskColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subRow(int i) {
    final checked = _checks[i];
    return GestureDetector(
      onTap: () => _toggle(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Row(
              children: [
                _checkIcon(checked),
                const SizedBox(width: 8),
                Expanded(
                  child: Opacity(
                    opacity: checked ? 0.5 : 1,
                    child: Text(
                      widget.task.subTasks[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        color: AppColors.deepChocolate,
                        // line sits UNDER the Arabic text (line-through renders
                        // too high over Arabic glyphs in a Latin font).
                        decoration: checked
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: AppColors.deepChocolate,
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (i != widget.task.subTasks.length - 1)
              Container(
                margin: const EdgeInsets.only(top: 4, right: 30),
                height: 0.5,
                color: const Color(0x44BC8A7B),
              ),
          ],
        ),
      ),
    );
  }

  Widget _checkIcon(bool checked) {
    if (checked) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.ribbon2,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ribbonNeutral, width: 2),
      ),
    );
  }
}

/// Card text uses these date helpers elsewhere; re-export to keep imports tidy.
String todayYmd() => ymd(DateTime.now());
