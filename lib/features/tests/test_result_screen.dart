import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database.dart';
import '../../core/image_palette.dart';
import '../../core/models.dart';
import '../../core/routiny_stats.dart';
import '../../theme/app_colors.dart';
import 'test_intro_screen.dart';
import 'test_models.dart';

const _kDownloadUrl =
    'https://play.google.com/store/apps/details?id=com.gpstracker.routiny';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({
    super.key,
    required this.test,
    required this.tierIndex,
  });
  final MentalTest test;
  final int tierIndex;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  bool _adopted = false;
  late Color _edge;

  TestResultTier get _tier => widget.test.resultTiers[widget.tierIndex];

  String get _coverAsset =>
      _tier.imageAsset.isNotEmpty ? _tier.imageAsset : widget.test.coverAsset;

  // ── colour derivations (1:1 with Android TestResultActivity) ───────────────
  Color get _pageBg  => ImagePalette.lighten(_edge, 0.82);
  Color get _heroBg  => ImagePalette.lighten(_edge, 0.05);
  Color get _chain   => ImagePalette.darken(_edge, 0.10);
  Color get _share   => ImagePalette.darken(_edge, 0.05);
  Color get _friends => ImagePalette.lighten(_edge, 0.30);
  Color get _retry   => ImagePalette.lighten(_edge, 0.50);

  static const _ink = Color(0xFF3E2818);
  static const _body = Color(0xFF5C4A3E);
  static const _muted = Color(0xFF8E7366);

  @override
  void initState() {
    super.initState();
    _edge = AppColors.parseHex(widget.test.cardBgColor);
    ImagePalette.from(
      'assets/images/$_coverAsset.jpg',
      fallback: AppColors.parseHex(widget.test.cardBgColor),
    ).then((c) { if (mounted) setState(() => _edge = c); });
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: [
            // ── top bar: close (right) + test name ───────────────────────
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GestureDetector(
                onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Icon(Icons.close, color: Color(0xFF5C3D2E), size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.test.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: _ink)),

            // ── hero card ────────────────────────────────────────────────
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: _heroBg,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/$_coverAsset.jpg',
                  width: double.infinity, fit: BoxFit.fitWidth),
            ),

            // ── levels card ──────────────────────────────────────────────
            const SizedBox(height: 14),
            _sectionCard(
              emoji: '📊',
              title: 'المستويات',
              child: _levels(),
            ),

            // ── details card ─────────────────────────────────────────────
            const SizedBox(height: 14),
            _sectionCard(
              emoji: '📋',
              title: 'تفاصيل نتيجتك',
              child: _bodyText(tier.details),
            ),

            if (tier.traits.isNotEmpty)
              _connectedCard(_sectionCard(
                emoji: '💡',
                title: 'النصيحة',
                child: _bullets(tier.traits),
              )),
            if (tier.strengths.isNotEmpty)
              _connectedCard(_sectionCard(
                emoji: '✨',
                title: 'نقاط القوة',
                child: _bullets(tier.strengths),
              )),
            if (tier.weaknesses.isNotEmpty)
              _connectedCard(_sectionCard(
                emoji: '🌧️',
                title: 'نقاط الضعف',
                child: _bullets(tier.weaknesses),
              )),
            if (tier.routine.isNotEmpty)
              _connectedCard(_routineCard(tier.routine)),

            // ── bottom buttons ───────────────────────────────────────────
            const SizedBox(height: 22),
            _fullButton(
              label: 'مشاركة نتيجتي',
              bg: _share,
              fg: Colors.white,
              icon: Icons.share,
              onTap: _shareResult,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _fullButton(
                    label: 'اختبر أصدقائي',
                    bg: _friends,
                    fg: _ink,
                    icon: Icons.share,
                    onTap: _challengeFriends,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _fullButton(
                    label: 'إعادة',
                    bg: _retry,
                    fg: _ink,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TestIntroScreen(test: widget.test)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── level bars (5) ──────────────────────────────────────────────────────
  Widget _levels() {
    const factors = [0.65, 0.45, 0.25, 0.10, -0.10];
    final labels = widget.test.levelLabels;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: _bar(i, factors[i])),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    i < labels.length ? labels[i] : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: i == widget.tierIndex ? 13 : 12,
                        fontWeight: i == widget.tierIndex
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: i == widget.tierIndex ? _ink : _muted),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(int i, double factor) {
    final base = factor >= 0
        ? ImagePalette.lighten(_edge, factor)
        : ImagePalette.darken(_edge, -factor);
    final isUser = i == widget.tierIndex;
    final color = isUser ? ImagePalette.darken(base, 0.22) : base;
    return Container(
      height: isUser ? 12 : 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  // ── chain-ring connector between cards ──────────────────────────────────
  /// A section card with the chain rings drawn ON TOP of it, overflowing
  /// upward onto the previous card — matches the Android elevation look so the
  /// pin always sits above both cards.
  Widget _connectedCard(Widget card) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 20 px gap above this card; the rings bridge it
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: card,
        ),
        // rings painted AFTER the card → always on top, overflow up onto the
        // previous card (this whole unit is painted after it)
        Positioned(right: 22, top: -18, child: _ChainRing(color: _chain)),
        Positioned(left: 22, top: -18, child: _ChainRing(color: _chain)),
      ],
    );
  }

  // ── section card ────────────────────────────────────────────────────────
  Widget _sectionCard({
    required String emoji,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBE0D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text,
          textAlign: TextAlign.right,
          style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              height: 1.55,
              color: _body)),
    );
  }

  Widget _bullets(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: Text('•  ${items[i]}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      height: 1.5,
                      color: _body)),
            ),
        ],
      ),
    );
  }

  Widget _routineCard(List<String> routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBE0D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌿', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('الروتين المناسب لكي',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < routine.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('◆ ',
                      style: TextStyle(fontSize: 12, color: _ink)),
                  Expanded(
                    child: Text(routine[i],
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            height: 1.5,
                            color: _body)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _adopted ? null : _adoptRoutine,
              style: ElevatedButton.styleFrom(
                backgroundColor: _share,
                disabledBackgroundColor: _share.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: Text(_adopted ? 'اتعمدت ✓' : 'اعتمدي الروتين ✓',
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullButton({
    required String label,
    required Color bg,
    required Color fg,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg)),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: fg),
            ],
          ],
        ),
      ),
    );
  }

  // ── actions ───────────────────────────────────────────────────────────
  Future<void> _adoptRoutine() async {
    await AppDatabase.instance.insertTask(TaskEntity(
      title: _cleanTitle(widget.test.title),
      iconResName: 'ic_routiny_sparkles',
      colorHex: widget.test.cardTextColor,
      subTasks: _tier.routine,
      date: ymd(DateTime.now()),
    ));
    await RoutinyStats.recordTaskCreation();
    if (!mounted) return;
    setState(() => _adopted = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('اتضاف كمهمة في صفحة الروتين 💗')));
  }

  String _cleanTitle(String raw) {
    var t = raw.trim();
    for (final p in ['اختبار ', 'إختبار ']) {
      if (t.startsWith(p)) t = t.substring(p.length).trim();
    }
    return t.length > 15 ? t.substring(0, 15) : t;
  }

  void _shareResult() {
    final t = widget.test;
    final tier = _tier;
    final text = 'نتيجتي في اختبار "${t.title}":\n'
        '► ${tier.title}\n\n'
        '${tier.details}\n\n'
        '📲 حمّلي تطبيق Routiny: $_kDownloadUrl';
    Share.share(text);
  }

  void _challengeFriends() {
    final text =
        'جربي اختبار "${widget.test.title}" على Routiny واكتشفي نفسكِ ✨\n\n'
        '📲 حمّلي التطبيق: $_kDownloadUrl';
    Share.share(text);
  }
}

/// Tinted silhouette of the Android `ic_chain_ring`: two circles joined by a
/// short tube, painted in a single colour.
class _ChainRing extends StatelessWidget {
  const _ChainRing({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 56),
      painter: _ChainRingPainter(color),
    );
  }
}

class _ChainRingPainter extends CustomPainter {
  _ChainRingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    // tube (x7..11, y8..48)
    canvas.drawRRect(
      RRect.fromLTRBR(7, 8, 11, 48, const Radius.circular(2)),
      p,
    );
    // top + bottom circles (r 4.6)
    canvas.drawCircle(const Offset(9, 8), 4.6, p);
    canvas.drawCircle(const Offset(9, 48), 4.6, p);
  }

  @override
  bool shouldRepaint(_ChainRingPainter old) => old.color != color;
}
