import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/database.dart';
import '../../core/lang_notifier.dart';
import '../../core/prefs.dart';
import '../../theme/app_colors.dart';
import '../care/breathing_exercise_screen.dart';
import '../care/quote_dialog.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
              children: [
                _sectionLabel('الحساب'),
                _card([
                  _row(context, Icons.account_circle, AppColors.primary,
                      'تعديل الملف الشخصي',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage()))),
                ]),
                _sectionLabel('التطبيق'),
                _card([
                  _row(context, Icons.notifications, AppColors.primary,
                      'الإشعارات',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage()))),
                  _divider(),
                  _rowWithSub(context, Icons.translate, AppColors.primary,
                      'اللغة', S.currentLanguage,
                      () => _showLanguagePicker(context)),
                  _divider(),
                  _row(context, Icons.format_quote, AppColors.primary,
                      'كوتة اليوم', () => showQuoteTodayDialog(context)),
                  _divider(),
                  _row(context, Icons.self_improvement, AppColors.primary,
                      'تمرين تنفّس',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const BreathingExerciseScreen()))),
                ]),
                _sectionLabel('المساعدة والتعليقات'),
                _card([
                  _row(context, Icons.thumb_up, AppColors.primary, 'قيّمينا',
                      () => _showRate(context)),
                  _divider(),
                  _row(context, Icons.delete_forever, AppColors.danger,
                      'مسح جميع البيانات', () => _showClear(context),
                      danger: true),
                ]),
                const SizedBox(height: 22),
                const Center(
                  child: Text('v1.0',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: AppColors.secondaryText)),
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
      padding: const EdgeInsets.only(top: 36, bottom: 22),
      decoration: const BoxDecoration(
        color: AppColors.routinyBg,
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: const SafeArea(
        bottom: false,
        child: Center(
          child: Text('الإعدادات',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepChocolate)),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(text,
          style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 56, endIndent: 16, color: Color(0x1F5C3D2E));

  Widget _rowWithSub(BuildContext context, IconData icon, Color tint,
      String label, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          color: AppColors.deepChocolate)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 12,
                          color: AppColors.secondaryText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.deepChocolate),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = LangNotifier.instance.value;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.routinyBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, refresh) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(S.languagePickerTitle,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepChocolate)),
            const SizedBox(height: 16),
            _langOption(context, S.langMasri, 'masri', current),
            const SizedBox(height: 8),
            _langOption(context, S.langFusha, 'fusha', current),
          ]),
        ),
      ),
    );
  }

  Widget _langOption(
      BuildContext context, String label, String code, String current) {
    final selected = current == code;
    return GestureDetector(
      onTap: () {
        LangNotifier.instance.setLang(code);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2),
        ),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepChocolate))),
          if (selected)
            const Icon(Icons.check_circle,
                color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, Color tint, String label,
      VoidCallback onTap,
      {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      color: danger
                          ? AppColors.danger
                          : AppColors.deepChocolate)),
            ),
            Icon(Icons.chevron_left,
                color: danger ? AppColors.danger : AppColors.deepChocolate),
          ],
        ),
      ),
    );
  }

  void _showRate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل استمتعتِ بـ Routiny؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 12),
              const Text(
                  'ساعدينا على التحسّن من خلال تقييمنا، وسنبذل قصارى جهدنا لجعل تجربتكِ أفضل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.secondaryText)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3F4D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('أعطنا ٥ نجوم',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ربما لاحقاً',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        color: AppColors.secondaryText)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنتِ متأكدة من مسح جميع البيانات؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 12),
              const Text(
                  'هيتم حذف كل المهام، الإحصائيات، الصورة الشخصية، الاسم وسجل الإشعارات. مش هتقدري ترجّعيها.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.secondaryText)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    await AppDatabase.instance.clearAll();
                    await Prefs.I.clearAll();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم مسح كل البيانات')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27)),
                  ),
                  child: const Text('نعم',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لا',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        color: AppColors.secondaryText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
