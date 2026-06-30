import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/ar_dates.dart';
import '../../core/database.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../reflection/reflection_models.dart';

/// "مذكراتي" — private journal entries the user chose to keep, with delete.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<ReflectionEntity> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppDatabase.instance.journalEntries();
    if (mounted) setState(() {
      _entries = list;
      _loading = false;
    });
  }

  Future<void> _delete(ReflectionEntity e) async {
    final ok = await showDialog<bool>(
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
              Text(S.deleteJournalTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chocolate)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(S.deleteJournalConfirm,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(S.goBack,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        color: AppColors.secondaryText)),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      await AppDatabase.instance.deleteReflectionJournal(e.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: [
                  Text(S.journalTitleLabel,
                      style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2818))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.deepChocolate),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _entries.isEmpty
                      ? _empty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                          itemCount: _entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _entryCard(_entries[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤍', style: TextStyle(fontSize: 44)),
            SizedBox(height: 12),
            Text(
                'لسه مفيش مذكرات محفوظة.\nمن صفحة "حاسة بإيه" فعّلي "احتفظي بمذكراتي" وإنتِ بتكتبي 🌸',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget _entryCard(ReflectionEntity e) {
    final date = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
    final mood = moodById(e.mood);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBE0D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (mood != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset('assets/moods/${mood.imageAsset}.png'),
                  ),
                ),
              Expanded(
                child: Text('${date.day} ${ArDates.monthYear(date)}',
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepChocolate)),
              ),
              GestureDetector(
                onTap: () => _delete(e),
                child: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(e.journal ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.deepChocolate)),
        ],
      ),
    );
  }
}
