import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/models/job_item.dart';

class JobListTile extends StatelessWidget {
  const JobListTile({
    super.key,
    required this.job,
    this.onTap,
  });

  final JobItem job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 71,
          decoration: BoxDecoration(
            color: job.accentBarColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HomeTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.listSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeTheme.tagMuted.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: HomeTheme.chipInactive,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  job.employmentType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.tagMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          job.salaryMonthly,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: HomeTheme.primary,
          ),
        ),
      ],
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
