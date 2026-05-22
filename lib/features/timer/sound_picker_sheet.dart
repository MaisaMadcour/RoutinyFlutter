import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'focus_sounds.dart';

/// Sound picker — does not auto-dismiss so the user can audition sounds.
Future<void> showSoundPicker(
  BuildContext context, {
  required String currentId,
  required Future<void> Function(FocusSound) onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.routinyBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _SoundPickerSheet(currentId: currentId, onPick: onPick),
  );
}

class _SoundPickerSheet extends StatefulWidget {
  const _SoundPickerSheet({required this.currentId, required this.onPick});
  final String currentId;
  final Future<void> Function(FocusSound) onPick;

  @override
  State<_SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<_SoundPickerSheet> {
  late String _selected = widget.currentId;
  String? _loadingId;

  Future<void> _pick(FocusSound s) async {
    setState(() => _loadingId = s.file == null ? null : s.id);
    try {
      await widget.onPick(s);
      setState(() => _selected = s.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('تعذّر تحميل الموسيقى — راجع الاتصال بالإنترنت')));
      }
    } finally {
      if (mounted) setState(() => _loadingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.calendarDayStroke,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          const Text('اختر صوت التركيز',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.chocolate)),
          const SizedBox(height: 4),
          const Text('اضغط لتشغيل الصوت — اضغط مرة تانية لإيقافه',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kFocusSounds.length,
              itemBuilder: (context, i) {
                final s = kFocusSounds[i];
                final selected = s.id == _selected;
                return GestureDetector(
                  onTap: () => _pick(s),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.calendarDayStroke,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.graphic_eq,
                            size: 30, color: AppColors.ribbonNeutral),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s.name,
                              style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepChocolate)),
                        ),
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: _loadingId == s.id
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary)
                              : selected
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.primary)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
