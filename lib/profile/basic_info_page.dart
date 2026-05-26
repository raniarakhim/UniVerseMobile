import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/core/models/picked_local_file.dart';
import 'package:diplomka/core/services/profile_photo_service.dart';
import 'package:diplomka/core/services/user_resume_service.dart';
import 'package:diplomka/core/utils/file_pick_helpers.dart';
import 'package:diplomka/core/widgets/app_file_upload_area.dart';
import 'package:diplomka/profile/profile_photo_picker.dart';
import 'package:diplomka/profile/widgets/profile_avatar.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({super.key});

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();

  int _yearIndex = 0;
  AppUser? _user;
  String? _photoPath;
  String? _photoUrl;
  PickedLocalFile? _resumeFile;
  String? _savedResumeName;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingResume = false;

  final _profilePhoto = ProfilePhotoService.instance;
  final _resumeService = UserResumeService.instance;

  static const _years = ['1st', '2nd', '3rd', '4th', '5th', '6th+'];

  @override
  void initState() {
    super.initState();
    _profilePhoto.addListener(_onPhotoChanged);
    _loadProfile();
  }

  void _onPhotoChanged() {
    if (mounted) _refreshPhoto();
  }

  Future<void> _loadProfile() async {
    final user = await UserProfileService.instance.load();
    if (!mounted) return;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone;
      _universityCtrl.text = user.university;
      _facultyCtrl.text = user.faculty;
      final yearIdx = _years.indexOf(user.yearOfStudy);
      _yearIndex = yearIdx >= 0 ? yearIdx : 0;
    }
    setState(() {
      _user = user;
      _loading = false;
    });
    await _refreshPhoto();
    await _loadResumeInfo();
  }

  Future<void> _refreshPhoto() async {
    final uid = _user?.uid;
    final path = await _profilePhoto.pathForUser(uid);
    final url = await _profilePhoto.urlForUser(uid);
    if (mounted) {
      setState(() {
        _photoPath = path;
        _photoUrl = url ?? _user?.photoUrl;
      });
    }
  }

  Future<void> _loadResumeInfo() async {
    final info = await _resumeService.infoForUser(_user?.uid);
    if (mounted) {
      setState(() => _savedResumeName = info.fileName);
    }
  }

  Future<void> _changeProfilePhoto() async {
    final uid = _user?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите в аккаунт, чтобы загрузить фото')),
      );
      return;
    }
    await ProfilePhotoPicker.pickAndSave(
      context,
      uid,
      hasPhoto: _photoPath != null || (_photoUrl != null && _photoUrl!.isNotEmpty),
    );
    if (mounted) await _refreshPhoto();
  }

  Future<void> _pickResume() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final picked = await FilePickHelpers.pickPdf(context);
      if (picked == null || !mounted) return;
      setState(() {
        _resumeFile = picked;
        _uploadingResume = true;
      });
      await _resumeService.uploadResume(uid, picked);
      if (mounted) {
        setState(() {
          _savedResumeName = picked.name;
          _uploadingResume = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploaded')),
        );
      }
    } on FilePickSizeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingResume = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    final user = _user;
    if (user == null) return;
    setState(() => _saving = true);
    final updated = user.copyWith(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      university: _universityCtrl.text.trim(),
      faculty: _facultyCtrl.text.trim(),
      yearOfStudy: _years[_yearIndex],
    );
    try {
      await UserProfileService.instance.save(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось сохранить: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _profilePhoto.removeListener(_onPhotoChanged);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _universityCtrl.dispose();
    _facultyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: HomeTheme.pageBackground,
        body: Center(child: CircularProgressIndicator(color: HomeTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailAppBar(title: 'Basic Info'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _avatarSection(),
                    const SizedBox(height: 16),
                    _sectionHeader('PERSONAL INFO'),
                    const SizedBox(height: 8),
                    _editableField('Full Name', _nameCtrl),
                    const SizedBox(height: 8),
                    _editableField('Email', _emailCtrl),
                    const SizedBox(height: 8),
                    _editableField('Phone number', _phoneCtrl),
                    const SizedBox(height: 16),
                    _sectionHeader('ACADEMIC INFO'),
                    const SizedBox(height: 8),
                    _editableField('University', _universityCtrl),
                    const SizedBox(height: 8),
                    _editableField('Faculty / Major', _facultyCtrl),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Year of study',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: HomeTheme.bodyText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _yearChips(),
                    const SizedBox(height: 16),
                    _sectionHeader('CV / RESUME'),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PDF max. 2 MB — used when applying for jobs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HomeTheme.placeholder,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppFileUploadArea(
                      file: _resumeFile ??
                          (_savedResumeName != null
                              ? PickedLocalFile(
                                  name: _savedResumeName!,
                                  path: '',
                                  sizeBytes: 0,
                                )
                              : null),
                      uploading: _uploadingResume,
                      onTap: _pickResume,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                          ),
                        ),
                        child: Text(
                          _saving ? 'Saving...' : 'Save changes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

  Widget _avatarSection() {
    final initials = _user?.initials ?? '?';
    return Column(
      children: [
        ProfileAvatar(
          initials: initials,
          photoPath: _photoPath,
          photoUrl: _photoUrl,
          size: 100,
          backgroundColor: HomeTheme.primary,
          initialsFontSize: 48,
          showEditBadge: true,
          onTap: _changeProfilePhoto,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _changeProfilePhoto,
          child: const Text(
            'Change photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomeTheme.accentLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: HomeTheme.tagMuted.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: HomeTheme.accentSurface),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 16, color: HomeTheme.bodyText),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Icon(Icons.edit_outlined, size: 20, color: HomeTheme.accent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _yearChips() {
    return Wrap(
      spacing: 6,
      children: List.generate(_years.length, (i) {
        final selected = _yearIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _yearIndex = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? HomeTheme.primary : HomeTheme.chipInactive,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              _years[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : HomeTheme.tagMuted.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }),
    );
  }
}
