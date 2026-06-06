import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/card_item.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

/// Auto-rotating hero carousel with 3-5 featured articles.
class HeroCarousel extends StatefulWidget {
  final List<CardItem> items;
  final void Function(CardItem item) onTap;

  const HeroCarousel({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    if (widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length > 1 && _timer == null) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    _currentPage = page;
    _startAutoPlay(); // reset timer on manual swipe
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = Responsive.heroImageHeight(context);
    final isTablet = Responsive.isTablet(context);

    return Column(
      children: [
        SizedBox(
          height: isTablet ? imageHeight + 244 : imageHeight + 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return _HeroCard(
                item: widget.items[index],
                imageHeight: imageHeight,
                onTap: () => widget.onTap(widget.items[index]),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          _PageIndicator(count: widget.items.length, current: _currentPage),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final CardItem item;
  final double imageHeight;
  final VoidCallback onTap;

  const _HeroCard({
    required this.item,
    required this.imageHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.surfaceTile1,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Cover image with gradient overlay
              Stack(
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: item.displayImg,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.hairline),
                      errorWidget: (_, _, _) => CachedNetworkImage(
                        imageUrl: CardItem.defaultImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: imageHeight * 0.6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x99000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Title + author + button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppText.displayMdSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onDark,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.authorName != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.authorName!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    CupertinoButton(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 8,
                      ),
                      onPressed: onTap,
                      child: Text(
                        AppLocalizations.of(context)?.startReading ?? '开始阅读',
                        style: const TextStyle(
                          fontSize: AppText.bodySize,
                          fontWeight: FontWeight.w400,
                          color: AppColors.canvas,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? AppColors.primary : AppColors.hairline,
          ),
        );
      }),
    );
  }
}
