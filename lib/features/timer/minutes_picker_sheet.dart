import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

Future<int?> showMinutesPicker(
  BuildContext context, {
  required String title,
  int min = 1,
  int max = 120,
  required int initial,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.routinyBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        _MinutesPickerSheet(title: title, min: min, max: max, initial: initial),
  );
}

class _MinutesPickerSheet extends StatefulWidget {
  const _MinutesPickerSheet({
    required this.title,
    required this.min,
    required this.max,
    required this.initial,
  });
  final String title;
  final int min;
  final int max;
  final int initial;

  @override
  State<_MinutesPickerSheet> createState() => _MinutesPickerSheetState();
}

class _MinutesPickerSheetState extends State<_MinutesPickerSheet> {
  static const _spacing = 14.0;
  late int _value;
  late final ScrollController _sc;
  double _viewportHalf = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(widget.min, widget.max);
    _sc = ScrollController();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    final v = (widget.min + (_sc.offset / _spacing).round())
        .clamp(widget.min, widget.max);
    if (v != _value) setState(() => _value = v);
  }

  void _snap() {
    final target = (_value - widget.min) * _spacing;
    _sc.animateTo(target,
        duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.deepChocolate),
            ),
          ),
          Text(widget.title,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1C))),
          const SizedBox(height: 28),
          const Icon(Icons.arrow_drop_down, color: AppColors.rulerPink),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$_value',
                  style: const TextStyle(
                      fontFamily: 'InterDisplay',
                      fontSize: 84,
                      height: 1.0,
                      color: AppColors.rulerPink)),
              const SizedBox(width: 8),
              const Text('دقيقة',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      color: AppColors.rulerPink)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: LayoutBuilder(builder: (context, c) {
              _viewportHalf = c.maxWidth / 2;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_sc.hasClients && _sc.offset == 0 && _value != widget.min) {
                  _sc.jumpTo((_value - widget.min) * _spacing);
                }
              });
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollUpdateNotification) _onScroll();
                  if (n is ScrollEndNotification) _snap();
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _sc,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: (widget.max - widget.min) * _spacing +
                        _viewportHalf * 2,
                    height: 100,
                    child: CustomPaint(
                      painter: _RulerPainter(
                        min: widget.min,
                        max: widget.max,
                        spacing: _spacing,
                        leading: _viewportHalf,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('تأكيد',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.min,
    required this.max,
    required this.spacing,
    required this.leading,
  });
  final int min;
  final int max;
  final double spacing;
  final double leading;

  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()
      ..color = const Color(0xFFD8CFC9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var v = min; v <= max; v++) {
      final x = leading + (v - min) * spacing;
      final major = v % 5 == 0;
      final h = major ? 28.0 : 14.0;
      canvas.drawLine(Offset(x, 10), Offset(x, 10 + h), tick);
      if (major) {
        final tp = TextPainter(
          text: TextSpan(
              text: '$v',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  color: Color(0xFF9C8B7F))),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 44));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) => false;
}
