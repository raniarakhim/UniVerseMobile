import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/widgets/home_detail_app_bar.dart';
import 'package:diplomka/events/event_registered_page.dart';
import 'package:diplomka/events/models/event_item.dart';
import 'package:diplomka/events/widgets/event_summary_card.dart';
import 'package:diplomka/events/widgets/event_ticket_preview.dart';
import 'package:diplomka/events/widgets/register_stepper.dart';

class EventRegisterPage extends StatefulWidget {
  const EventRegisterPage({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegisterPage> createState() => _EventRegisterPageState();
}

class _EventRegisterPageState extends State<EventRegisterPage> {
  int _step = 0;

  final _nameCtrl = TextEditingController(text: 'Aymakhan Balausa');
  final _emailCtrl = TextEditingController(text: 'aymakhanbalausa@gmail.com');
  final _phoneCtrl = TextEditingController(text: '+7 771 887 33 37');
  final _facultyCtrl = TextEditingController(text: 'Information Technologies');
  final _linkedinCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();

  String _university = 'SKSU';
  int _yearIndex = 2;
  bool _inPerson = true;
  int _roleIndex = 0;
  final Set<int> _interests = {0, 3};
  double _level = 0.5;
  bool _favorite = false;

  static const _years = ['1st', '2nd', '3rd', '4th', '5th', '6th+'];
  static const _roles = ['Student', 'Graduate', 'Professional'];
  static const _interestLabels = [
    'Networking',
    'Startups',
    'Learning',
    'Jobs',
    'Mentorship',
    'Internship',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _facultyCtrl.dispose();
    _linkedinCtrl.dispose();
    _requirementsCtrl.dispose();
    super.dispose();
  }

  String get _yearLabel => _years[_yearIndex];
  String get _roleLabel => _roles[_roleIndex];
  String get _levelLabel {
    if (_level < 0.33) return 'Beginner';
    if (_level > 0.66) return 'Expert';
    return 'Intermediate';
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventRegisteredPage(
            event: widget.event,
            attendeeName: _nameCtrl.text,
            attendeeType: _roleLabel,
          ),
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const HomeDetailAppBar(title: 'Register for event'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    EventSummaryCard(
                      event: widget.event,
                      isFavorite: _favorite,
                      onFavoriteToggle: () => setState(() => _favorite = !_favorite),
                    ),
                    const SizedBox(height: 12),
                    RegisterStepper(currentStep: _step),
                    const SizedBox(height: 12),
                    if (_step == 0) _stepInfo(),
                    if (_step == 1) _stepPreferences(),
                    if (_step == 2) _stepConfirm(),
                    const SizedBox(height: 12),
                    _navButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButtons() {
    if (_step == 0) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: HomeTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
            ),
          ),
          child: const Text('Continue to Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 44,
          child: OutlinedButton(
            onPressed: _back,
            style: OutlinedButton.styleFrom(
              backgroundColor: HomeTheme.inputBackground,
              foregroundColor: HomeTheme.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios_new, size: 16, color: HomeTheme.primary),
                SizedBox(width: 4),
                Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(HomeTheme.cardRadius),
                ),
              ),
              child: Text(
                _step == 2 ? 'Confirm registration' : 'Continue to Confirm',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PERSONAL INFO'),
        const SizedBox(height: 8),
        _field('Full Name', _nameCtrl),
        const SizedBox(height: 8),
        _field('Email', _emailCtrl),
        const SizedBox(height: 8),
        _field('Phone number', _phoneCtrl),
        const SizedBox(height: 16),
        _sectionLabel('ACADEMIC INFO'),
        const SizedBox(height: 8),
        _dropdownUniversity(),
        const SizedBox(height: 8),
        _field('Faculty / Major', _facultyCtrl),
        const SizedBox(height: 8),
        const Text('Year of study', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        _yearChips(),
        const SizedBox(height: 8),
        _field('LinkedIn (optional)', _linkedinCtrl, hint: 'linkedin.com/in/username'),
      ],
    );
  }

  Widget _stepPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ATTENDANCE'),
        const SizedBox(height: 8),
        const Text('Will you attend in person?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _attendanceChip('In person', _inPerson, () => setState(() => _inPerson = true))),
            const SizedBox(width: 8),
            Expanded(child: _attendanceChip('Online', !_inPerson, () => setState(() => _inPerson = false))),
          ],
        ),
        const SizedBox(height: 8),
        const Text('I am attending as', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_roles.length, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i < _roles.length - 1 ? 4 : 0),
              child: _roleChip(_roles[i], _roleIndex == i, () => setState(() => _roleIndex = i)),
            );
          }),
        ),
        const SizedBox(height: 16),
        _sectionLabel('YOUR INTERESTS'),
        const SizedBox(height: 8),
        const Text('What are you looking for?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(_interestLabels.length, (i) {
            final selected = _interests.contains(i);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _interests.remove(i);
                  } else {
                    _interests.add(i);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? HomeTheme.primary : HomeTheme.inputBackground,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  _interestLabels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : HomeTheme.tagMuted,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _sectionLabel('EXPERIENCE LEVEL'),
        const SizedBox(height: 8),
        const Text('Your current level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF7C3AED),
            inactiveTrackColor: const Color(0xFFE8E5F5),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF7C3AED).withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _level,
            onChanged: (v) => setState(() => _level = v),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Beginner', style: TextStyle(fontSize: 10, color: _levelLabel == 'Beginner' ? const Color(0xFF7C3AED) : HomeTheme.tagMuted)),
            Text('Intermediate', style: TextStyle(fontSize: 10, color: _levelLabel == 'Intermediate' ? const Color(0xFF7C3AED) : HomeTheme.tagMuted)),
            Text('Expert', style: TextStyle(fontSize: 10, color: _levelLabel == 'Expert' ? const Color(0xFF7C3AED) : HomeTheme.tagMuted)),
          ],
        ),
        const SizedBox(height: 16),
        _sectionLabel('ADDITIONAL'),
        const SizedBox(height: 8),
        const Text('Any special requirements?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        TextField(
          controller: _requirementsCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Dietary needs, accessibility, others......',
            hintStyle: TextStyle(color: HomeTheme.tagMuted.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepConfirm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('REVIEW YOUR INFO'),
        const SizedBox(height: 8),
        _reviewCard([
          _ReviewRow('Full name', _nameCtrl.text, onEdit: () => setState(() => _step = 0)),
          _ReviewRow('Email', _emailCtrl.text, onEdit: () => setState(() => _step = 0)),
          _ReviewRow('Phone', _phoneCtrl.text, onEdit: () => setState(() => _step = 0)),
          _ReviewRow('University · Year', '$_university · $_yearLabel year', onEdit: () => setState(() => _step = 0)),
        ]),
        const SizedBox(height: 16),
        _sectionLabel('YOUR PREFERENCES'),
        const SizedBox(height: 8),
        _reviewCard([
          _ReviewRow('Attendance', _inPerson ? 'In person' : 'Online', onEdit: () => setState(() => _step = 1)),
          _ReviewRow('Role · Level', '$_roleLabel · $_levelLabel', onEdit: () => setState(() => _step = 1)),
        ]),
        const SizedBox(height: 16),
        _sectionLabel('SELECTED INTERESTS'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _interests.map((i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomeTheme.inputBackground,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                _interestLabels[i],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF4C1D95)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionLabel('YOUR TICKET'),
        const SizedBox(height: 8),
        EventTicketPreview(
          event: widget.event,
          attendeeName: _nameCtrl.text,
          attendeeType: _roleLabel,
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: HomeTheme.tagMuted.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownUniversity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('University', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.bodyText)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _university,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'SKSU', child: Text('SKSU')),
            DropdownMenuItem(value: 'KBTU', child: Text('KBTU')),
          ],
          onChanged: (v) => setState(() => _university = v ?? _university),
        ),
      ],
    );
  }

  Widget _yearChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_years.length, (i) {
          final selected = i == _yearIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < _years.length - 1 ? 6 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _yearIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? HomeTheme.primary : HomeTheme.inputBackground,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  _years[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : HomeTheme.tagMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _attendanceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? HomeTheme.primary : HomeTheme.inputBackground,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 18, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : HomeTheme.tagMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? HomeTheme.primary : HomeTheme.inputBackground,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(color: HomeTheme.surfaceBackground, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 12, color: HomeTheme.primary),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : HomeTheme.tagMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(List<_ReviewRow> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 12, color: HomeTheme.accentSurface),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value, {required this.onEdit});

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: HomeTheme.tagMuted.withValues(alpha: 0.7))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HomeTheme.primary)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: const Text('Edit', style: TextStyle(fontSize: 12, color: Color(0xFF4C1D95))),
        ),
      ],
    );
  }
}