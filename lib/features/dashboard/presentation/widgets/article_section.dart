import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../article/domain/entities/article.dart';
import 'dashboard_card.dart';

class ArticleSection extends StatelessWidget {
  const ArticleSection({
    super.key,
    required this.isLoading,
    required this.articles,
    this.error,
  });

  final bool isLoading;
  final List<Article> articles;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Artikel Terbaru',
      trailingLabel: 'Lihat Semua',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (error != null) {
      return Text(error!, style: const TextStyle(color: AppColors.error));
    }
    if (articles.isEmpty) {
      return const Text(
        'Belum ada artikel.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: articles
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ArticleTile(article: a),
              ))
          .toList(),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 72,
            height: 54,
            child: article.thumbnailUrl != null && article.thumbnailUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(color: AppColors.background),
                  )
                : Container(color: AppColors.background),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (article.categoryName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        article.categoryName!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (article.publishedAt != null)
                    Text(
                      DateFormat('d MMM y', 'id_ID').format(article.publishedAt!),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
