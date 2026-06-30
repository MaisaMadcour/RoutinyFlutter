import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_strings.dart';
import '../../core/lang_notifier.dart';
import '../../core/database.dart';
import '../../core/prefs.dart';
import '../../theme/app_colors.dart';
import '../care/breathing_exercise_screen.dart';
import '../care/quote_dialog.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // 1:1 with the Kotlin settings palette
  static const _ink = Color(0xFF5C3D2E);      // row title / chevron
  static const _muted = Color(0xFF8E7366);    // section label / version
  static const _danger = Color(0xFFC25C5C);   // clear-data row
  static const _divider = Color(0x1F5C3D2E);  // 12% chocolate hairline

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // ── الحساب ──
                _sectionLabel('الحساب'),
                _row(context,
                    icon: Icons.account_circle,
                    title: 'تعديل الملف الشخصي',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()))),

                // ── التطبيق ──
                _sectionLabel('التطبيق'),
                _row(context,
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()))),
                _hairline(),
                _row(context,
                    icon: Icons.format_quote,
                    title: S.dailyQuoteRow,
                    onTap: () => showQuoteTodayDialog(context)),
                _hairline(),
                _row(context,
                    icon: Icons.self_improvement,
                    title: 'تمرين تنفّس',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BreathingExerciseScreen()))),
                _hairline(),
                _languageRow(context),

                // ── المساعدة والتعليقات ──
                _sectionLabel('المساعدة والتعليقات'),
                _row(context,
                    icon: Icons.thumb_up,
                    title: 'قيّمينا',
                    onTap: () => _showRate(context)),
                _hairline(),
                _row(context,
                    icon: Icons.delete_forever,
                    title: 'مسح جميع البيانات',
                    danger: true,
                    onTap: () => _showClear(context)),

                const SizedBox(height: 22),
                const Center(
                  child: Text('v1.0',
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: _muted)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── curved header with a soft drop shadow ──
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 22),
          child: Center(
            child: Text('الإعدادات',
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                color: _muted)),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? _danger : _ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: danger ? _danger : AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      color: color)),
            ),
            Icon(Icons.chevron_left, size: 20, color: color),
          ],
        ),
      ),
    );
  }

  Widget _languageRow(BuildContext context) {
    return InkWell(
      onTap: () => _showLanguagePicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.language, size: 22, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(S.languageLabel,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      color: _ink)),
            ),
            Text(S.currentLanguage,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: _muted)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left, size: 20, color: _ink),
          ],
        ),
      ),
    );
  }

  Widget _hairline() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Divider(height: 1, thickness: 1, color: _divider),
      );

  // ───────────────────────── dialogs / sheets ─────────────────────────

  void _showLanguagePicker(BuildContext context) {
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
              Text(S.languagePickerTitle,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 20),
              _langOption(context, S.langMasri, 'masri'),
              const SizedBox(height: 12),
              _langOption(context, S.langFusha, 'fusha'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, String label, String lang) {
    final isSelected = S.isFusha ? lang == 'fusha' : lang == 'masri';
    return InkWell(
      onTap: () {
        LangNotifier.instance.setLang(lang);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0x1F5C3D2E),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : _ink)),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  size: 20, color: AppColors.primary),
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
              Text(S.rateDialogTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 12),
              Text(S.rateDialogBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      color: AppColors.secondaryText)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final storeUrl = Uri.parse(
                        'market://details?id=com.routiny.app');
                    final webUrl = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.routiny.app');
                    if (!await launchUrl(storeUrl,
                        mode: LaunchMode.externalApplication)) {
                      await launchUrl(webUrl,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3F4D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(S.rateBtn,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.maybeLater,
                    style: const TextStyle(
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
              Text(S.clearDataConfirmTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 12),
              Text(S.clearDataConfirmBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                        SnackBar(content: Text(S.dataClearedMsg)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27)),
                  ),
                  child: Text(S.yes,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.no,
                    style: const TextStyle(
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
