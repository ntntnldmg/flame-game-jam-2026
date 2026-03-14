import 'package:flutter/material.dart';

import '../../app_typography.dart';
import '../../consts.dart';

class CctvScreenTile extends StatelessWidget {
  final int cameraNumber;
  final String imageAsset;
  final String timestamp;

  const CctvScreenTile({
    super.key,
    required this.cameraNumber,
    required this.imageAsset,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.green)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imageAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withAlpha(28),
                  AppColors.transparent,
                  AppColors.black.withAlpha(46),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.black.withAlpha(140),
                border: Border.all(color: AppColors.green),
              ),
              child: Text(
                '$cameraNumber',
                style: AppTypography.mono(
                  color: AppColors.green,
                  fontSize: 14,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 4,
            child: Text(
              timestamp,
              style: AppTypography.mono(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
