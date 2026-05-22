import 'package:flutter/material.dart';
import 'package:diplomka/job/apply_for_job_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/core/services/saved_jobs_service.dart';
import 'package:diplomka/job/job_contact_page.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({super.key, required this.job});

  final JobItem job;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final _savedService = SavedJobsService.instance;

  static const _heroTagBg = Color(0xFF27236B);

  @override
  void initState() {
    super.initState();
    _savedService.addListener(_onSavedChanged);
  }

  @override
  void dispose() {
    _savedService.removeListener(_onSavedChanged);
    super.dispose();
  }

  void _onSavedChanged() {
    if (mounted) setState(() {});
  }

  bool get _isSaved => _savedService.isSaved(widget.job.saveId);

  void _toggleSave() => _savedService.toggle(widget.job.saveId);

  void _apply() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ApplyForJobPage(job: widget.job)),
    );
  }

  void _openContact() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobContactPage(job: widget.job)),
    );
  }

  void _openJob(JobItem job) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsPage(key: ValueKey(job.saveId), job: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final similar = JobItem.similarTo(job);
    final modes = job.workModes.isNotEmpty ? job.workModes : job.tags;

    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            HomeDetailAppBar(
              title: 'Job Details',
              trailing: IconButton(
                onPressed: _toggleSave,
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 32,
                  color: HomeTheme.primary,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      HomeTheme.horizontalPadding,
                      4,
                      HomeTheme.horizontalPadding,
                      88,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroCard(job, modes),
                        const SizedBox(height: 20),
                        _statsRow(job),
                        if (job.about.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('About the role'),
                          const SizedBox(height: 12),
                          Text(
                            job.about,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 18 / 14,
                              color: HomeTheme.tagMuted,
                            ),
                          ),
                        ],
                        if (job.requirements.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('Requirements'),
                          const SizedBox(height: 12),
                          ...job.requirements.map(_requirementRow),
                        ],
                        if (job.skills.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('Skills'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skills.map(_skillChip).toList(),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _sectionTitle('About the company'),
                        const SizedBox(height: 12),
                        _companyCard(job),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _openContact,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HomeTheme.primary,
                              side: const BorderSide(color: HomeTheme.accentLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Contact',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        if (similar.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('Similar jobs'),
                          const SizedBox(height: 12),
                          ...similar.map(_similarJobRow),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: HomeTheme.horizontalPadding,
                    right: HomeTheme.horizontalPadding,
                    bottom: 16,
                    child: _bottomActions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(JobItem job, List<String> modes) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
      decoration: BoxDecoration(
        color: HomeTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(
                  job.logoLetter,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: HomeTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      job.detailSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HomeTheme.surfaceBackground.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              if (job.isTopPick)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'TOP PICK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: HomeTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: modes
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _heroTagBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.salary,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'per month · negotiable',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HomeTheme.surfaceBackground.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _apply,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Quick Apply',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow(JobItem job) {
    return Row(
      children: [
        _statBox(job.experience, 'EXPERIENCE'),
        const SizedBox(width: 8),
        _statBox(job.schedule, 'SCHEDULE'),
        const SizedBox(width: 8),
        _statBox(job.status, 'STATUS'),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HomeTheme.surfaceBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeTheme.primary,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HomeTheme.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: HomeTheme.primary,
      ),
    );
  }

  Widget _requirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HomeTheme.accentLight, width: 1.5),
            ),
            child: const Icon(Icons.check, size: 12, color: HomeTheme.accentLight),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 18 / 14,
                color: HomeTheme.tagMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: HomeTheme.tagMuted,
        ),
      ),
    );
  }

  Widget _companyCard(JobItem job) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openContact,
        borderRadius: BorderRadius.circular(16),
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: HomeTheme.primary,
            child: Text(
              job.logoLetter,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.primary,
                  ),
                ),
                Text(
                  job.companyMeta.isNotEmpty
                      ? job.companyMeta
                      : '${job.location} · ${job.employmentType}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: HomeTheme.primary),
        ],
      ),
        ),
      ),
    );
  }

  Widget _similarJobRow(JobItem job) {
    final subtitle = '${job.company} · ${job.location} · ${job.employmentType}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openJob(job),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: HomeTheme.chipInactive),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: HomeTheme.primary,
                  child: Text(
                    job.logoLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: HomeTheme.primary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HomeTheme.tagMuted.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  job.salaryShort,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomActions() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _toggleSave,
            icon: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: HomeTheme.primary,
            ),
            label: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: HomeTheme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: HomeTheme.chipInactive,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
