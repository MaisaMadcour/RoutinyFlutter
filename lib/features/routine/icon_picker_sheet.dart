import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/task_icons.dart';
import '../../theme/app_colors.dart';

/// Shows the icon picker bottom sheet; returns the chosen icon id or null.
Future<String?> showIconPicker(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.routinyBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _IconPickerSheet(current: current),
  );
}

class _IconPickerSheet extends StatelessWidget {
  const _IconPickerSheet({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    final ids = TaskIcons.all;
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
          Text(S.chooseIcon,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
          const SizedBox(height: 14),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: ids.length,
              itemBuilder: (context, i) {
                final id = ids[i];
                final selected = id == current;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, id),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedScale(
                      scale: selected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.navRipple
                              : AppColors.routinyBg,
                          border: Border.all(
                            color: selected
                                ? AppColors.ribbonNeutral
                                : AppColors.calendarDayStroke,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Icon(TaskIcons.of(id),
                            size: 26, color: AppColors.deepChocolate),
                      ),
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
