import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/ads/interstitial_manager.dart';
import '../../theme/app_colors.dart';

class FocusResultScreen extends StatefulWidget {
  const FocusResultScreen({super.key, required this.completed});
  final bool completed;

  @override
  State<FocusResultScreen> createState() => _FocusResultScreenState();
}

class _FocusResultScreenState extends State<FocusResultScreen> {
  bool _confetti = false;

  @override
  void initState() {
    super.initState();
    if (widget.completed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _confetti = true);
      });
    }
    // interstitial after a focus session (cap 3 min)
    Future.delayed(const Duration(milliseconds: 700), () {
      InterstitialManager.instance.showIfReady(InterstitialManager.ctxFocusEnd);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.completed;
    final bg = c ? const Color(0xFFF2D8C9) : const Color(0xFFF9CEC4);
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 96),
                _character(c),
                const SizedBox(height: 36),
                Text(
                  c ? 'رائع!\nأنجزتِ المهمة!' : 'استرخي!\nكل جهد يُحتسب',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1C)),
                ),
                const SizedBox(height: 12),
                Text(
                  c ? 'احتفلي بتقدّمك ✨' : 'لنواصل حين تكونين جاهزة',
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 16,
                      color: AppColors.chocolate),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 44),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Text(c ? 'أنا فخورة بنفسي!' : 'حسناً!',
                          style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_confetti)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset('assets/lottie/confetti_result.json',
                    repeat: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _character(bool c) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 240,
            height: 240,
            child: Lottie.asset(c
                ? 'assets/lottie/trophy.json'
                : 'assets/lottie/giraffe_neck_growing.json'),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(c ? '✓' : '!',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
