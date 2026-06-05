import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';

class DetailHeroImage extends StatelessWidget {
  final String? imageUrl;

  const DetailHeroImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : CardItem.defaultImg;
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      placeholder: (_, _) =>
          Container(height: 240, color: AppColors.canvasParchment),
      errorWidget: (_, _, _) => CachedNetworkImage(
        imageUrl: CardItem.defaultImg,
        height: 240,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(height: 240, color: AppColors.canvasParchment),
        errorWidget: (_, _, _) =>
            Container(height: 240, color: AppColors.canvasParchment),
      ),
    );
  }
}
