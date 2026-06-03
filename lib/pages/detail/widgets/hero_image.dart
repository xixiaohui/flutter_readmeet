import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';

class DetailHeroImage extends StatelessWidget {
  final String? imageUrl;

  const DetailHeroImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      placeholder: (_, _) =>
          Container(height: 240, color: AppColors.canvasParchment),
      errorWidget: (_, _, _) =>
          Container(height: 240, color: AppColors.canvasParchment),
    );
  }
}
