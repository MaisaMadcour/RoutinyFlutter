import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import 'notification_prefs.dart';

class _SectionDef {
  final String label;
  final String desc;
  final IconData icon;
  final Color tint;
  final bool Function() get;
  final void Function(bool) set;
  const _SectionDef(
      this.label, this.desc, this.icon, this.tint, this.get, this.set);
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final List<_SectionDef> _sections = [
    _SectionDef('الكوتات اليومية', 'كوتة لطيفة', Icons.auto_awesome,
        AppColors.primary, NotificationPrefs.rawTips,
        (v) => NotificationPrefs.tips = v),
    _SectionDef(
        'تذكير العادة',
        'احصلي على تذكيرات لإكمال عاداتكِ',
        Icons.notifications_none,
        const Color(0xFF5A8DBF),
        NotificationPrefs.rawHabit,
        (v) => NotificationPrefs.habit = v),
    _SectionDef(
        'جلسة التركيز',
        'إشعار شغّال أثناء جلسة البومودورو يعرض الوقت المتبقي',
        Icons.timer_outlined,
        AppColors.primary,
        NotificationPrefs.rawFocusRunning,
        (v) => NotificationPrefs.focusRunning = v),
    _SectionDef(
        'انتهاء الجلسة',
        'تنبيه لما جلسة التركيز تخلص',
        Icons.favorite_border,
        const Color(0xFF5A8DBF),
        NotificationPrefs.rawFocusCompletion,
        (v) => NotificationPrefs.focusCompletion = v),
    _SectionDef(
        'تذكير العودة',
        'اشعار لطيف للتذكير بفتح الابلكيشن',
        Icons.favorite,
        AppColors.primary,
        NotificationPrefs.rawInactivity,
        (v) => NotificationPrefs.inactivity = v),
  ];

  @override
  Widget build(BuildContext context) {
    final allOn = NotificationPrefs.allEnabled;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Container(
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('جميع الإشعارات',
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepChocolate)),
                      ),
                      Switch(
                        value: allOn,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) =>
                            setState(() => NotificationPrefs.allEnabled = v),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: allOn ? 1 : 0.4,
                  child: Column(
                    children: [
                      for (final s in _sections) _section(s, allOn),
                      _batteryCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 36, bottom: 18),
      decoration: const BoxDecoration(
        color: AppColors.routinyBg,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('الإشعارات',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            Positioned(
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.deepChocolate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(_SectionDef s, bool masterOn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.label,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: s.tint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon, size: 18, color: s.tint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(s.desc,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        color: AppColors.deepChocolate)),
              ),
              Switch(
                value: s.get(),
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged:
                    masterOn ? (v) => setState(() => s.set(v)) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: masterOn
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم إرسال إشعار تجريبي: ${s.label}')))
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('اختبري الآن',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
            ),
          ),
          const SizedBox(height: 10),
          const Text('آخر الإشعارات (٧ أيام)',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA0907F))),
          const SizedBox(height: 6),
          const Text('لا توجد إشعارات حديثة',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _batteryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9DF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('وضعية توفير البطارية قيد التشغيل',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
              ),
              Icon(Icons.notifications_active,
                  color: AppColors.primary, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'تم تمكين تحسين البطارية الآن. قد لا تتلقّي إشعارات عند تمكين هذا الإعداد.',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              const channel = MethodChannel('com.routiny.routiny/focus');
              await channel.invokeMethod('openBatterySettings');
            },
            child: const Text('اذهبي إلى إعدادات الجهاز ←',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7B9C70))),
          ),
        ],
      ),
    );
  }
}
