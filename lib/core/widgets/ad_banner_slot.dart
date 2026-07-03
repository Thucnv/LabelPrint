import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget hiển thị AdMob banner advertisement.
///
/// Tự động sử dụng test ID cho debug build và release ID cho release build.
///
/// Ví dụ:
/// ```dart
/// AdBannerSlot(height: 60)
/// ```
class AdBannerSlot extends StatefulWidget {
  /// Chiều cao của banner slot (mặc định 50).
  final double height;

  const AdBannerSlot({
    super.key,
    this.height = 50,
  });

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adRequest = const AdRequest();
    final bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      request: adRequest,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Silent fail - không hiển thị lỗi cho người dùng
        },
      ),
    );

    bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        height: widget.height,
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Fallback placeholder khi quảng cáo chưa load
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Ad',
          style: AppTextStyles.label.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
