import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

class DetailHeroImage extends StatelessWidget {
  final String? imageUrl;

  const DetailHeroImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.isNotEmpty)
        ? imageUrl!
        : CardItem.defaultImg;
    final h = Responsive.detailHeroHeight(context);
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: h,
      fit: BoxFit.cover,
      placeholder: (_, _) =>
          Container(height: h, color: AppColors.canvasParchment),
      errorWidget: (_, _, _) => CachedNetworkImage(
        imageUrl: CardItem.defaultImg,
        height: h,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(height: h, color: AppColors.canvasParchment),
        errorWidget: (_, _, _) =>
            Container(height: h, color: AppColors.canvasParchment),
      ),
    );
  }
}
