import 'package:flutter/material.dart';
import 'package:diplomka/job/application_sent_page.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/models/picked_local_file.dart';
import 'package:diplomka/core/services/applications_service.dart';
import 'package:diplomka/core/services/storage_upload_service.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/core/services/user_resume_service.dart';
import 'package:diplomka/core/utils/file_pick_helpers.dart';
import 'package:diplomka/core/utils/form_validators.dart';
import 'package:diplomka/core/widgets/app_file_upload_area.dart';
import 'package:diplomka/core/widgets/app_snackbar.dart';
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
  PickedLocalFile? _cvFile;
  String? _profileResumePath;
  String? _profileResumeName;
  bool _useProfileResume = false;
  bool _submitting = false;
  bool _uploadingCv = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _coverCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await UserProfileService.instance.load();
    if (!mounted) return;
    if (user != null) {
      setState(() {
        if (_nameCtrl.text.isEmpty) _nameCtrl.text = user.fullName;
        if (_emailCtrl.text.isEmpty) _emailCtrl.text = user.email;
        if (_phoneCtrl.text.isEmpty) _phoneCtrl.text = user.phone;
        _profileResumePath = user.resumeUrl.isNotEmpty ? user.resumeUrl : null;
        _profileResumeName =
            user.resumeFileName.isNotEmpty ? user.resumeFileName : null;
      });
    }
    if (_profileResumePath == null && user != null) {
      final info = await UserResumeService.instance.infoForUser(user.uid);
      if (mounted) {
        setState(() {
          _profileResumePath = info.localPath;
          _profileResumeName = info.fileName;
        });
      }
    }
  }

  String? _validateForm() {
    final checks = [
      FormValidators.requiredField(_nameCtrl.text, fieldName: 'Имя'),
      FormValidators.email(_emailCtrl.text),
      FormValidators.phone(_phoneCtrl.text),
      FormValidators.requiredField(_coverCtrl.text, fieldName: 'Сопроводительное письмо'),
    ];
    for (final err in checks) {
      if (err != null) return err;
    }
    if (!_hasCv) {
      return 'Загрузите CV (PDF)';
    }
    return null;
  }

  bool get _hasCv =>
      _cvFile != null || (_useProfileResume && _profileResumePath != null);

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
                    const SizedBox(height: 4),
                    const Text(
                      'PDF only, max. 2 MB',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HomeTheme.placeholder,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppFileUploadArea(
                      file: _cvFile ??
                          (_useProfileResume && _profileResumeName != null
                              ? PickedLocalFile(
                                  name: _profileResumeName!,
                                  path: '',
                                  sizeBytes: 0,
                                )
                              : null),
                      uploading: _uploadingCv,
                      onTap: _pickCv,
                    ),
                    if (_profileResumePath != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _useProfileResume = true;
                            _cvFile = null;
                          });
                        },
                        icon: Icon(
                          _useProfileResume ? Icons.check_circle : Icons.description_outlined,
                          size: 20,
                          color: HomeTheme.accent,
                        ),
                        label: Text(
                          'Use CV from profile${_profileResumeName != null ? ': $_profileResumeName' : ''}',
                          style: const TextStyle(fontSize: 14, color: HomeTheme.accent),
                        ),
                      ),
                    ],
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
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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
            child: Text(
              widget.job.logoLetter,
              style: const TextStyle(
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
    try {
      final picked = await FilePickHelpers.pickPdf(context);
      if (picked == null || !mounted) return;
      setState(() {
        _cvFile = picked;
        _useProfileResume = false;
      });
    } on FilePickSizeException catch (e) {
      if (mounted) showAppError(context, e.message);
    }
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

  Future<void> _submit() async {
    final err = _validateForm();
    if (err != null) {
      showAppError(context, err);
      return;
    }

    setState(() => _submitting = true);
    try {
      final uid = UserProfileService.instance.current?.uid;
      if (uid == null || uid.isEmpty) {
        throw ApplicationException('Войдите в аккаунт');
      }

      String? cvLocalPath;
      String cvFileName;

      if (_cvFile != null) {
        setState(() => _uploadingCv = true);
        final ts = DateTime.now().millisecondsSinceEpoch;
        cvLocalPath = await StorageUploadService.instance.uploadFile(
          storagePath: 'users/$uid/applications/${widget.job.saveId}_$ts.pdf',
          file: _cvFile!,
          contentType: 'application/pdf',
          maxBytes: UserResumeService.maxBytes,
        );
        cvFileName = _cvFile!.name;
        if (mounted) setState(() => _uploadingCv = false);
      } else {
        cvLocalPath = _profileResumePath;
        cvFileName = _profileResumeName ?? 'resume.pdf';
      }

      await ApplicationsService.instance.submitJobApplication(
        jobId: widget.job.saveId,
        jobTitle: widget.job.title,
        company: widget.job.company,
        formData: {
          'fullName': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'coverLetter': _coverCtrl.text.trim(),
          'cvFileName': cvFileName,
          'cvLocalPath': cvLocalPath,
          'startAvailability': _startOptions[_selectedStart],
          'portfolio': _portfolioCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationSentPage(companyName: widget.job.company),
        ),
      );
    } on ApplicationException catch (e) {
      if (mounted) showAppError(context, e.message);
    } on StorageUploadException catch (e) {
      if (mounted) showAppError(context, e.message);
    } catch (e) {
      if (mounted) showAppError(context, 'Ошибка: $e');
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadingCv = false;
        });
      }
    }
  }
}
