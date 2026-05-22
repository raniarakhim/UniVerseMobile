import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/job/job_details_page.dart';
import 'package:diplomka/job/widgets/job_list_tile.dart';
import 'package:diplomka/profile/my_applications_page.dart';

class ApplicationSentPage extends StatelessWidget {
  const ApplicationSentPage({super.key, required this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  24,
                  HomeTheme.horizontalPadding,
                  16,
                ),
                child: Column(
                  children: [
                    _successVisual(),
                    const SizedBox(height: 16),
                    const Text(
                      'Application submitted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 36 / 28,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 256,
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 18 / 14,
                            color: HomeTheme.tagMuted,
                          ),
                          children: [
                            const TextSpan(text: 'Your application has been sent to '),
                            TextSpan(
                              text: companyName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: '. They will contact you soon.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Other similar jobs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...JobItem.similarJobs.map(
                      (job) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: JobListTile(
                          job: job,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailsPage(job: job),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HomeTheme.horizontalPadding,
                0,
                HomeTheme.horizontalPadding,
                24,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyApplicationsPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: HomeTheme.chipInactive,
                        foregroundColor: HomeTheme.primary,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                        ),
                      ),
                      child: const Text(
                        'View my applications',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HomeTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                        ),
                      ),
                      child: const Text(
                        'Back to Jobs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successVisual() {
    return SizedBox(
      width: 319,
      height: 187,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._confettiPieces(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: HomeTheme.accentSurface,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '✓',
                style: TextStyle(fontSize: 38, color: Colors.white, height: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _confettiPieces() {
    final pieces = <({double left, double top, double size, Color color, double opacity})>[
      (left: 18, top: 38, size: 8, color: const Color(0xFF7C3AED), opacity: 0.4),
      (left: 285, top: 29, size: 10, color: HomeTheme.companyTint, opacity: 0.6),
      (left: 6, top: 120, size: 6, color: HomeTheme.accentSurface, opacity: 1),
      (left: 300, top: 107, size: 7, color: const Color(0xFF7C3AED), opacity: 0.25),
      (left: 59, top: 9, size: 9, color: HomeTheme.companyTint, opacity: 0.5),
      (left: 238, top: 48, size: 8, color: HomeTheme.accentSurface, opacity: 0.8),
      (left: 37, top: 72, size: 6, color: HomeTheme.companyTint, opacity: 0.5),
      (left: 262, top: 82, size: 5, color: const Color(0xFF7C3AED), opacity: 0.35),
      (left: 120, top: 0, size: 7, color: const Color(0xFF7C3AED), opacity: 0.3),
      (left: 199, top: 19, size: 8, color: HomeTheme.companyTint, opacity: 0.4),
      (left: 272, top: 2, size: 6, color: HomeTheme.accentSurface, opacity: 0.7),
    ];

    return pieces
        .map(
          (p) => Positioned(
            left: p.left,
            top: p.top,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: p.opacity),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        )
        .toList();
  }
}
