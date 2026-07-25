/// Compry — Premium Skeleton Loaders with Shimmer Animation
library;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_dimensions.dart';

// ─── Shimmer Wrapper ─────────────────────────────────────────────────────────

class _ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const _ShimmerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1C1F28) : const Color(0xFFE8EAED);
    final highlightColor = isDark ? const Color(0xFF252830) : const Color(0xFFF8FAFB);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusSM,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F28) : const Color(0xFFE8EAED),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── List Card Skeleton ───────────────────────────────────────────────────────

class ListCardSkeleton extends StatelessWidget {
  const ListCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16181F) : Colors.white;

    return _ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.cardSpacing / 2,
        ),
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority bar
                _ShimmerBox(
                  width: 5,
                  height: 52,
                  borderRadius: 4,
                ),
                const Gap(AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: double.infinity, height: 17),
                      const Gap(8),
                      _ShimmerBox(width: 120, height: 12),
                    ],
                  ),
                ),
                const Gap(AppDimensions.spaceMD),
                _ShimmerBox(width: 90, height: 24, borderRadius: AppDimensions.radiusFull),
              ],
            ),
            const Gap(AppDimensions.spaceMD),
            _ShimmerBox(width: double.infinity, height: AppDimensions.progressBarHeight, borderRadius: AppDimensions.radiusFull),
            const Gap(AppDimensions.spaceSM),
            Row(
              children: [
                _ShimmerBox(width: 80, height: 11),
                const Spacer(),
                _ShimmerBox(width: 60, height: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListCardSkeletonList extends StatelessWidget {
  final int count;
  const ListCardSkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) => ListCardSkeleton()),
    );
  }
}

// ─── Item Tile Skeleton ───────────────────────────────────────────────────────

class ItemTileSkeleton extends StatelessWidget {
  const ItemTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceSM,
        ),
        child: Row(
          children: [
            _ShimmerBox(width: 28, height: 28, borderRadius: 7),
            const Gap(AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 16),
                  const Gap(6),
                  _ShimmerBox(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
