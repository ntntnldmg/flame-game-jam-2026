import 'package:flutter/material.dart';

import '../../app_typography.dart';
import '../../consts.dart';
import '../../models/resident.dart';

class ResidentListItem extends StatefulWidget {
  final Resident resident;
  final VoidCallback onTap;

  const ResidentListItem({
    super.key,
    required this.resident,
    required this.onTap,
  });

  @override
  State<ResidentListItem> createState() => _ResidentListItemState();
}

class _ResidentListItemState extends State<ResidentListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final resident = widget.resident;
    final dimmed = resident.isArrested;
    final hasCompletionMarker = resident.hasCompletedActionMarker;
    final isPending =
        resident.isInvestigationPending || resident.isArrestPending;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered ? AppColors.hoverBackground : AppColors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      resident.id,
                      style: AppTypography.barcode39(
                        color: dimmed
                            ? AppColors.green.withAlpha(60)
                            : AppColors.green.withAlpha(150),
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (resident.isArrested)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: AppColors.red.withAlpha(210),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  '${resident.lastName.toUpperCase()}, ${resident.firstName}',
                                  style: AppTypography.mono(
                                    color: dimmed
                                        ? AppColors.bluishWhite.withAlpha(50)
                                        : AppColors.bluishWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (resident.isArrestPending)
                            Text(
                              'ARREST WARRANT IN PROGRESS',
                              style: AppTypography.mono(
                                color: AppColors.red.withAlpha(180),
                                fontSize: 13,
                                letterSpacing: 0.6,
                              ),
                            )
                          else if (resident.isInvestigationPending)
                            Text(
                              'INVESTIGATION IN PROGRESS',
                              style: AppTypography.mono(
                                color: AppColors.green.withAlpha(200),
                                fontSize: 13,
                                letterSpacing: 0.6,
                              ),
                            )
                          else if (dimmed)
                            Text(
                              '[ARRESTED]',
                              style: AppTypography.mono(
                                color: AppColors.red.withAlpha(160),
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            )
                          else
                            Text(
                              '${resident.occupation.toUpperCase()} // ${resident.district.toUpperCase()}',
                              style: AppTypography.mono(
                                color: AppColors.green.withAlpha(190),
                                fontSize: 13,
                                letterSpacing: 0.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isPending)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 2),
                        child: Icon(
                          Icons.schedule,
                          size: 15,
                          color: AppColors.green,
                        ),
                      ),
                    if (hasCompletionMarker)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.bluishWhite,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '!',
                          style: AppTypography.mono(
                            color: AppColors.bluishWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.green.withAlpha(40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
