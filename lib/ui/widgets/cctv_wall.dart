import 'package:flutter/material.dart';

import 'cctv_screen_tile.dart';

class CctvWall extends StatelessWidget {
  const CctvWall({super.key});

  static const String _stamp = '2064-18-04 12:08:45.627';
  static const double _spacing = 2;

  @override
  Widget build(BuildContext context) {
    const feeds = [
      ('assets/images/cam1.jpg', 1),
      ('assets/images/cam2.jpg', 2),
      ('assets/images/cam3.jpg', 3),
      ('assets/images/cam4.jpg', 4),
      ('assets/images/cam5.jpg', 5),
      ('assets/images/cam6.jpg', 6),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - _spacing) / 2;
        final tileHeight = (constraints.maxHeight - (_spacing * 2)) / 3;
        final childAspectRatio = tileWidth / tileHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feeds.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return CctvScreenTile(
              cameraNumber: feeds[index].$2,
              imageAsset: feeds[index].$1,
              timestamp: _stamp,
            );
          },
        );
      },
    );
  }
}
