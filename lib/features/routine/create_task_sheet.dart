import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../core/task_icons.dart';
import '../../core/task_reminder.dart';
import '../../theme/app_colors.dart';
import '../../widgets/press_scale.dart';
import 'icon_picker_sheet.dart';
import 'widgets/task_card.dart';

Future<TaskEntity?> showCreateTaskSheet(BuildContext context,
    {TaskEntity? edit}) {
  return showModalBottomSheet<TaskEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.routinyBg,
    barrierColor: const Color(0x7A000000),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _CreateTaskSheet(edit: edit),
    ),
  );
}

class _CreateTaskSheet extends StatefulWidget {
  const _CreateTaskSheet({this.edit});
  final TaskEntity? edit;

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _subCtrls = <TextEditingController>[];
  final _subFocusNodes = <FocusNode>[];
  String _iconId = 'star';
  int _colorIndex = 0;
  TimeOfDay? _time;
  bool _reminder = false;
  String? _error;
  final Set<int> _selectedDays = {}; // Dart weekdays: 1=Mon..7=Sun

  bool get _isEdit => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _titleCtrl.text = e.title;
      _iconId = e.iconResName;
      final idx = AppColors.taskPalette.indexWhere(
          (c) => AppColors.parseHex(e.colorHex).toARGB32() == c.toARGB32());
      _colorIndex = idx < 0 ? 0 : idx;
      for (final s in e.subTasks) {
        _subCtrls.add(TextEditingController(text: s));
        _subFocusNodes.add(FocusNode());
      }
      if (e.time.contains(':')) {
        final p = e.time.split(':');
        _time = TimeOfDay(
            hour: int.tryParse(p[0]) ?? 8, minute: int.tryParse(p[1]) ?? 0);
      }
      _reminder = e.hasReminder;
    }
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _subCtrls) c.dispose();
    for (final f in _subFocusNodes) f.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = S.taskTitleEmpty);
      return;
    }
    if (title.length > 15) {
      setState(() => _error = S.taskTitleTooLong);
      return;
    }
    final subs = _subCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final timeStr = _time == null
        ? ''
        : '${_time!.hour.toString().padLeft(2, '0')}:'
            '${_time!.minute.toString().padLeft(2, '0')}';
    final task = widget.edit ?? TaskEntity(title: title);
    task
      ..title = title
      ..iconResName = _iconId
      ..colorHex =
          '#${AppColors.taskPalette[_colorIndex].toARGB32().toRadixString(16).substring(2).toUpperCase()}'
      ..subTasks = subs
      ..time = timeStr
      ..hasReminder = _reminder;
    if (!_isEdit) {
      if (_selectedDays.isEmpty) {
        task.date = todayYmd();
        Navigator.pop(context, task);
      } else if (_selectedDays.length == 7) {
        task.date = '';
        Navigator.pop(context, task);
      } else {
        _insertMultiDayTasks(task);
        return;
      }
    } else {
      Navigator.pop(context, task);
    }
  }

  Future<void> _insertMultiDayTasks(TaskEntity template) async {
    // Snapshot before any awaits to guard against concurrent UI modification.
    final days = List<int>.from(_selectedDays);
    int? firstId;
    DateTime? nearestDate;

    for (final weekday in days) {
      var d = DateTime.now();
      while (d.weekday != weekday) {
        d = d.add(const Duration(days: 1));
      }
      // Track the nearest upcoming occurrence across all selected weekdays
      // so the routine page can jump straight to it after creation.
      if (nearestDate == null || d.isBefore(nearestDate)) nearestDate = d;
      for (var i = 0; i < 52; i++) {
        final t = TaskEntity(
          title: template.title,
          iconResName: template.iconResName,
          colorHex: template.colorHex,
          subTasks: List.from(template.subTasks),
          date: '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
          time: template.time,
          hasReminder: template.hasReminder,
        );
        final id = await AppDatabase.instance.insertTask(t);
        firstId ??= id;
        d = d.add(const Duration(days: 7));
      }
    }
    // one daily reminder at the task time (fires at the next occurrence)
    if (firstId != null) await TaskReminder.sync(firstId, template);
    if (mounted) {
      // Pop with a navigation hint (empty title = hint, date = first occurrence)
      // so the routine page can jump to the day where the task first appears.
      final navDate = nearestDate != null
          ? '${nearestDate.year}-${nearestDate.month.toString().padLeft(2, '0')}-${nearestDate.day.toString().padLeft(2, '0')}'
          : '';
      Navigator.pop(context, TaskEntity(title: '', date: navDate));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => MediaQuery(
        // force the picker into 12-hour (AM/PM) mode regardless of device
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Theme(
          data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.routinyBg,
            onSurface: AppColors.deepChocolate,
            secondary: AppColors.primary,
            onSecondary: Colors.white,
            primaryContainer: AppColors.primary,
            onPrimaryContainer: Colors.white,
            secondaryContainer: AppColors.secondary,
            onSecondaryContainer: AppColors.deepChocolate,
            tertiary: AppColors.primary,
          ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _toggleReminder(bool v) {
    if (v && _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.chooseTimeFirst)));
      return;
    }
    setState(() => _reminder = v);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scroll) => SingleChildScrollView(
        controller: scroll,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.calendarDayStroke,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  PressScale(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE07A62), Color(0xFFB85A44)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFC86850)),
                      ),
                      child: Text(
                        _isEdit ? 'حفظ' : 'إنشاء ✦',
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        color: AppColors.deepChocolate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _iconCircle(),
            const SizedBox(height: 14),
            _titleRow(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 28, left: 28),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(_error!,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          color: AppColors.warning)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 28, left: 28),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('${_titleCtrl.text.length}/15',
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 11,
                        color: AppColors.secondaryText)),
              ),
            ),
            const SizedBox(height: 18),
            _colorPicker(),
            const SizedBox(height: 18),
            _addSubtaskButton(),
            _subtaskList(),
            const SizedBox(height: 16),
            _settingsCard(),
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 16, 32, 24),
              child: Text(
                'يمكن استخدام المهام الفرعية لروتين يومي أو قائمة تحقق',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    color: AppColors.secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconCircle() {
    return PressScale(
      onTap: () async {
        final id = await showIconPicker(context, _iconId);
        if (id != null) setState(() => _iconId = id);
      },
      child: Container(
        width: 76,
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.routinyBg,
          border: Border.all(color: AppColors.calendarDayStroke),
        ),
        child: Icon(
          TaskIcons.of(_iconId),
          size: 34,
          color: AppColors.taskPalette[_colorIndex],
        ),
      ),
    );
  }

  Widget _titleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleCtrl,
              maxLength: 15,
              maxLines: 1,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  color: AppColors.deepChocolate),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'عنوان المهمة...',
                hintStyle: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 20,
                    color: AppColors.hintText),
              ),
            ),
          ),
          if (_time != null)
            Container(
              margin: const EdgeInsetsDirectional.only(start: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.todayHeaderChipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                ArDates.time12h(_time!.hour, _time!.minute),
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    color: AppColors.todayHeaderChipText),
              ),
            ),
        ],
      ),
    );
  }

  Widget _colorPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < AppColors.taskPalette.length; i++)
            GestureDetector(
              onTap: () => setState(() => _colorIndex = i),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_colorIndex == i)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.deepChocolate, width: 2),
                        ),
                      ),
                    AnimatedScale(
                      scale: _colorIndex == i ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 160),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.taskPalette[i],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addSubtaskButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          final fn = FocusNode();
          _subFocusNodes.add(fn);
          setState(() => _subCtrls.add(TextEditingController()));
          WidgetsBinding.instance.addPostFrameCallback((_) => fn.requestFocus());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.routinyBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.ribbonNeutral, width: 1.5),
          ),
          child: const Text(
            '+ إضافة مهام فرعية',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 15,
                color: AppColors.ribbonNeutral),
          ),
        ),
      ),
    );
  }

  Widget _subtaskList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          for (var i = 0; i < _subCtrls.length; i++)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.routinyBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.calendarDayStroke, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subCtrls[i],
                      focusNode: i < _subFocusNodes.length ? _subFocusNodes[i] : null,
                      maxLines: 1,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: AppColors.deepChocolate),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'اكتب مهمة فرعية...',
                        hintStyle: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: AppColors.hintText),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _subCtrls.removeAt(i).dispose();
                    }),
                    child: const Icon(Icons.remove_circle_outline,
                        size: 20, color: AppColors.ribbonNeutral),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.navRipple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _pickTime,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 22, color: AppColors.deepChocolate),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('الوقت',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            color: AppColors.deepChocolate)),
                  ),
                  Text(
                    _time == null
                        ? S.anyTime
                        : ArDates.time12h(_time!.hour, _time!.minute),
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        color: _time == null
                            ? AppColors.secondaryText
                            : AppColors.deepChocolate),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 0.5, color: Color(0xDDBA9A89)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: _recurrenceRow(),
          ),
          const Divider(height: 0.5, color: Color(0xDDBA9A89)),
          SizedBox(
            height: 52,
            child: Row(
              children: [
                const Icon(Icons.notifications_none,
                    size: 22, color: AppColors.deepChocolate),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('التذكير',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: AppColors.deepChocolate)),
                ),
                Switch(
                  value: _reminder,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.navRipple,
                  inactiveThumbColor: AppColors.ribbonNeutral,
                  onChanged: _toggleReminder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recurrence helpers ──────────────────────────────────────────

  Widget _recurrenceRow() {
    const days = [
      (7, 'أحد'),
      (1, 'اثنين'),
      (2, 'ثلاثاء'),
      (3, 'أربعاء'),
      (4, 'خميس'),
      (5, 'جمعة'),
      (6, 'سبت'),
    ];
    final allSelected = _selectedDays.length == 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.repeat, size: 22, color: AppColors.deepChocolate),
              const SizedBox(width: 12),
              const Text('التكرار',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.deepChocolate)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // يومياً chip
              GestureDetector(
                onTap: () => setState(() {
                  if (allSelected) {
                    _selectedDays.clear();
                  } else {
                    _selectedDays.addAll([1, 2, 3, 4, 5, 6, 7]);
                  }
                }),
                child: _dayChip('يومياً', allSelected),
              ),
              // individual day chips
              for (final d in days)
                GestureDetector(
                  onTap: () => setState(() {
                    if (_selectedDays.contains(d.$1)) {
                      _selectedDays.remove(d.$1);
                    } else {
                      _selectedDays.add(d.$1);
                    }
                  }),
                  child: _dayChip(d.$2, _selectedDays.contains(d.$1)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.routinyBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xDDBA9A89),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.deepChocolate,
        ),
      ),
    );
  }
}
