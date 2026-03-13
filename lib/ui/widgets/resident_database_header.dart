import 'package:flutter/material.dart';

import '../../app_typography.dart';
import '../../consts.dart';

class ResidentDatabaseHeader extends StatelessWidget {
  final int entryCount;

  const ResidentDatabaseHeader({super.key, required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF071F30),
              border: Border(
                bottom: BorderSide(color: AppColors.green, width: 1.5),
                right: BorderSide(color: AppColors.green, width: 1.5),
              ),
            ),
            child: Text(
              'RESIDENT DATABASE',
              style: AppTypography.mono(
                color: AppColors.green,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.green, width: 1.5),
                ),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                '$entryCount entries',
                style: AppTypography.mono(
                  color: AppColors.bluishWhite.withAlpha(150),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
