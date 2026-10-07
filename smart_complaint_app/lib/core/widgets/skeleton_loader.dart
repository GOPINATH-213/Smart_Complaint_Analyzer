import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Lightweight enterprise Skeleton Loader widgets
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: borderRadius ?? AppRadius.r6,
      ),
    );
  }
}

class ComplaintCardSkeleton extends StatelessWidget {
  const ComplaintCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r14,
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 110, height: 22, borderRadius: AppRadius.r6),
              SkeletonBox(width: 80, height: 22, borderRadius: AppRadius.r22),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 16, borderRadius: AppRadius.r6),
          const SizedBox(height: 8),
          SkeletonBox(width: 200, height: 14, borderRadius: AppRadius.r6),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 70, height: 16, borderRadius: AppRadius.r6),
              SkeletonBox(width: 90, height: 14, borderRadius: AppRadius.r6),
            ],
          ),
        ],
      ),
    );
  }
}

class ComplaintListSkeleton extends StatelessWidget {
  final int count;

  const ComplaintListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (context, index) => const ComplaintCardSkeleton(),
    );
  }
}

class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.r12,
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 60, height: 12),
              SkeletonBox(width: 14, height: 14),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: 36, height: 24),
        ],
      ),
    );
  }
}
