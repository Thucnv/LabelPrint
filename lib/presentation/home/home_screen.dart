import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:label_print/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ad_banner_slot.dart';
import '../../domain/entities/enums/printer_enums.dart';
import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import 'widgets/feature_grid.dart';
import 'widgets/printer_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<HomeCubit>(
      create: (context) => sl<HomeCubit>()..loadDefaultPrinter(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 32,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.appTitle.toUpperCase(),
                style: AppTextStyles.headingLg.copyWith(
                  color: AppColors.onSurface,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.background,
          actions: [
            // Icon Shortcut sang quản lý máy in
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return IconButton(
                  icon: Badge(
                    backgroundColor: state.defaultPrinter != null
                        ? (state.printerStatus == PrinterStatus.ready
                            ? AppColors.success
                            : AppColors.statusIdle)
                        : AppColors.warning,
                    smallSize: 8,
                    child: const Icon(Icons.print_outlined, color: AppColors.onSurface),
                  ),
                  onPressed: () => _navigateToPrinterManagement(context),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().loadDefaultPrinter(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Trạng thái máy in
                            BlocBuilder<HomeCubit, HomeState>(
                              builder: (context, state) {
                                if (state.status == HomeStatus.loading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return PrinterStatusWidget(
                                  defaultPrinter: state.defaultPrinter,
                                  status: state.printerStatus,
                                  onManagePrinters: () => _navigateToPrinterManagement(context),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // 2. Tiêu đề nhóm tính năng
                            Text(
                              l10n.homeTitle.toUpperCase(),
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 3. Grid chức năng in ấn
                            FeatureGrid(
                              onBarcodeTap: () => _navigateToBarcodeScreen(context),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 4. Quảng cáo cố định
              const AdBannerSlot(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (index) {
              setState(() {
                _currentTab = index;
              });
              if (index == 1) {
                // Mock Lịch sử in
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lịch sử in đang được phát triển')),
                );
                setState(() {
                  _currentTab = 0;
                });
              } else if (index == 2) {
                // Mock Bản mẫu
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bản mẫu thiết kế đang được phát triển')),
                );
                setState(() {
                  _currentTab = 0;
                });
              }
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurfaceVariant,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.homeTitle,
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Lịch sử',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_border_outlined),
                activeIcon: const Icon(Icons.bookmark),
                label: l10n.saveTemplate,
              ),
            ],
          ),
      ),
    );
  }

  void _navigateToPrinterManagement(BuildContext context) async {
    await context.push('/printer-management');
    // Tự động reload lại khi quay về
    if (mounted) {
      // Vì BlocProvider bọc Scaffold, ta có thể dùng GlobalKey hoặc trigger từ callback
      // Một cách đơn giản là khi pop về ta gọi lại loadDefaultPrinter.
      // Do context ở đây chưa có HomeCubit trực tiếp (vì BlocProvider nằm dưới build của context HomeScreen),
      // nên ta dùng key hoặc bọc BlocProvider bên ngoài HomeScreen.
      // Tuy nhiên, vì ở đây có route push/pop, cách tốt nhất là bọc BlocProvider ở router cấp trên
      // hoặc dùng callback. Để đơn giản, ta sẽ bọc BlocProvider ở Router hoặc khi pop về thì gọi callback.
    }
  }

  void _navigateToBarcodeScreen(BuildContext context) {
    context.push('/barcode-print');
  }
}
