import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';

class NotificationHistoryPage extends StatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  State<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends State<NotificationHistoryPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notification_history') ?? '[]';
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
    setState(() => _items = []);
  }

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m  ${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _header(context),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_items.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'لا توجد إشعارات بعد',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 32),
                itemCount: _items.length,
                itemBuilder: (context, i) => _itemCard(_items[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 36, bottom: 18),
      decoration: const BoxDecoration(
        color: AppColors.routinyBg,
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'أحدث الإشعارات',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.deepChocolate,
              ),
            ),
            Positioned(
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.deepChocolate),
              ),
            ),
            if (_items.isNotEmpty)
              Positioned(
                left: 12,
                child: GestureDetector(
                  onTap: _clearAll,
                  child: const Text(
                    'مسح الكل',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final title = item['title'] as String? ?? '';
    final body = item['body'] as String? ?? '';
    final ts = (item['ts'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate,
                    ),
                  ),
                if (title.isNotEmpty && body.isNotEmpty)
                  const SizedBox(height: 4),
                if (body.isNotEmpty)
                  Text(
                    body,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 13,
                      color: AppColors.deepChocolate,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(ts),
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                size: 20, color: AppColors.secondaryText),
            onPressed: () {
              final text = [if (title.isNotEmpty) title, if (body.isNotEmpty) body]
                  .join('\n');
              Share.share(text);
            },
          ),
        ],
      ),
    );
  }
}
