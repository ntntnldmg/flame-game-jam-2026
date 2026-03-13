// // ─── Barcode painter ─────────────────────────────────────────────────────────
// import 'package:bigbrother/consts.dart';
// import 'package:flutter/material.dart';

// class BarcodePainter extends CustomPainter {
//   final bool dimmed;

//   // Fixed bar-width pattern (even indices = bars, odd = gaps), in relative units.
//   static const List<double> _pattern = [
//     2,
//     1,
//     1,
//     1,
//     3,
//     1,
//     2,
//     1,
//     1,
//     2,
//     1,
//     1,
//     2,
//     1,
//     3,
//     1,
//     1,
//     1,
//     2,
//     1,
//     1,
//     1,
//     2,
//     1,
//     1,
//     2,
//     3,
//     1,
//     1,
//     1,
//     2,
//     1,
//     1,
//     1,
//     3,
//     1,
//     2,
//     1,
//     1,
//     2,
//   ];

//   BarcodePainter({required this.dimmed});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = dimmed
//           ? AppColors.bluishWhite.withAlpha(35)
//           : AppColors.bluishWhite.withAlpha(210)
//       ..style = PaintingStyle.fill;

//     final totalUnits = _pattern.fold<double>(0, (s, e) => s + e);
//     final unitW = size.width / totalUnits;

//     double x = 0;
//     for (int i = 0; i < _pattern.length; i++) {
//       final w = _pattern[i] * unitW;
//       if (i.isEven) {
//         canvas.drawRect(Rect.fromLTWH(x, 0, w - 0.5, size.height), paint);
//       }
//       x += w;
//     }
//   }

//   @override
//   bool shouldRepaint(BarcodePainter old) => old.dimmed != dimmed;
// }
