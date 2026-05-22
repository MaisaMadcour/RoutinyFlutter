import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../routine/routine_page.dart';
import '../timer/timer_page.dart';
import '../tests/tests_page.dart';
import '../care/care_page.dart';
import '../settings/settings_page.dart';

/// Holds the currently selected tab so deep links / nested screens can switch.
class ShellController {
  static final ValueNotifier<int> tab = ValueNotifier<int>(2);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 2});
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    ShellController.tab.value = widget.initialTab;
  }

  // Index order: 0 settings, 1 care, 2 routine, 3 timer, 4 tests.
  // Under RTL the first child renders at the right edge.
  static const _tabs = <_TabDef>[
    _TabDef('الإعدادات', Icons.settings_outlined, Icons.settings),
    _TabDef('عناية', Icons.spa_outlined, Icons.spa),
    _TabDef('روتيني', Icons.check_circle_outline, Icons.check_circle),
    _TabDef('مؤقت', Icons.timer_outlined, Icons.timer),
    _TabDef('اختبار', Icons.edit_outlined, Icons.edit),
  ];

  final _pages = const [
    SettingsPage(),
    CarePage(),
    RoutinePage(),
    TimerPage(),
    TestsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ShellController.tab,
      builder: (context, current, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: _pages[current],
          bottomNavigationBar: _BottomNav(
            tabs: _tabs,
            current: current,
            onTap: (i) => ShellController.tab.value = i,
          ),
        );
      },
    );
  }
}

class _TabDef {
  final String label;
  final IconData icon;
  final IconData iconSelected;
  const _TabDef(this.label, this.icon, this.iconSelected);
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.current,
    required this.onTap,
  });

  final List<_TabDef> tabs;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    def: tabs[i],
                    selected: i == current,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.def,
    required this.selected,
    required this.onTap,
  });

  final _TabDef def;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navActive : AppColors.navInactive;
    final textColor =
        selected ? AppColors.navActiveText : AppColors.navInactive;
    return InkResponse(
      onTap: onTap,
      radius: 38,
      highlightColor: AppColors.navRipple,
      splashColor: AppColors.navRipple,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.navDot : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          Icon(selected ? def.iconSelected : def.icon, color: color, size: 26),
          const SizedBox(height: 2),
          Text(
            def.label,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 12,
              color: textColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
