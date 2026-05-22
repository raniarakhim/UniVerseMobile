import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diplomka/job/application_sent_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/job/models/job_item.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/core/widgets/home_form_field.dart';

class ApplyForJobPage extends StatefulWidget {
  const ApplyForJobPage({super.key, this.job = JobItem.frontendKaspi});

  final JobItem job;

  @override
  State<ApplyForJobPage> createState() => _ApplyForJobPageState();
}

class _ApplyForJobPageState extends State<ApplyForJobPage> {
  static const _startOptions = ['Immediately', '2 weeks', '1 month', 'Flexible'];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _coverCtrl;
  late final TextEditingController _portfolioCtrl;

  int _selectedStart = 0;
  String? _cvFileName;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _coverCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _coverCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const HomeDetailAppBar(title: 'Apply for job'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  HomeTheme.horizontalPadding,
                  11,
                  HomeTheme.horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _jobSummary(),
                    const SizedBox(height: 12),
                    HomeFormField(label: 'Full Name', controller: _nameCtrl),
                    const SizedBox(height: 12),
                    HomeFormField(label: 'Email', controller: _emailCtrl),
                    const SizedBox(height: 12),
                    HomeFormField(label: 'Phone number', controller: _phoneCtrl),
                    const SizedBox(height: 12),
                    HomeFormField(
                      label: 'Cover letter',
                      controller: _coverCtrl,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload your CV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F0E2A),
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'We support only PDF max. 2mb',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _uploadArea(),
                    const SizedBox(height: 12),
                    const Text(
                      'When can you start?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F0E2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _startChips(),
                    const SizedBox(height: 12),
                    HomeFormField(
                      label: 'Portfolio / GitHub',
                      controller: _portfolioCtrl,
                      hint: 'github.com/username',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                          ),
                        ),
                        child: const Text(
                          'Submit Application',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Color(widget.job.logoColor),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'K',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: HomeTheme.primary,
                  ),
                ),
                Text(
                  widget.job.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: HomeTheme.placeholder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCv() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Choose PDF file'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || choice == null) return;

    if (choice == 'gallery') {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _cvFileName = image.name);
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _cvFileName = result.files.single.name);
    }
  }

  Widget _uploadArea() {
    final hasFile = _cvFileName != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickCv,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 102,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasFile ? HomeTheme.accentLight : HomeTheme.accentSurface,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasFile ? Icons.check_circle_outline : Icons.upload_file,
                size: 30,
                color: hasFile ? HomeTheme.accentLight : HomeTheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                hasFile ? _cvFileName! : 'Upload',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: hasFile ? HomeTheme.accentLight : HomeTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _startChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_startOptions.length, (index) {
        final selected = _selectedStart == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedStart = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: HomeTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(16),
              border: selected ? Border.all(color: HomeTheme.accentLight) : null,
            ),
            child: Text(
              _startOptions[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? HomeTheme.primary : HomeTheme.tagMuted,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationSentPage(companyName: widget.job.company),
      ),
    );
  }
}
