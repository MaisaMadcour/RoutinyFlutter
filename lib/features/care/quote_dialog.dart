import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'quotes_data.dart';

Future<void> showQuoteTodayDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: _QuoteCard(quote: currentLoveYourselfQuote()),
    ),
  );
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.calendarDayStroke),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('“',
                    style: TextStyle(
                        fontSize: 48,
                        height: 0.6,
                        color: AppColors.primary)),
              ),
              Text(quote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepChocolate)),
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('”',
                    style: TextStyle(
                        fontSize: 48,
                        height: 0.2,
                        color: AppColors.primary)),
              ),
            ],
          ),
        ),
        Positioned(
          top: -14,
          left: -6,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.close,
                  size: 20, color: AppColors.deepChocolate),
            ),
          ),
        ),
      ],
    );
  }
}
