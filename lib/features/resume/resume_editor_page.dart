import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../resume_data.dart';
import '../../resume_preview_screen.dart';
import '../../services/draft_storage.dart';

class ResumeEditorPage extends StatefulWidget {
  const ResumeEditorPage({super.key});

  @override
  State<ResumeEditorPage> createState() => _ResumeEditorPageState();
}

class _ResumeEditorPageState extends State<ResumeEditorPage> {
  final _personalForm = GlobalKey<FormState>();
  final _educationForm = GlobalKey<FormState>();
  final _projectsForm = GlobalKey<FormState>();
  final _experienceForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _github = TextEditingController();
  final _linkedin = TextEditingController();
  final List<_EducationEntry> _education = [_EducationEntry()];
  final Set<String> _languages = {};
  final List<String> _extraSkills = [];
  final _skillInput = TextEditingController();
  final List<_ResumeEntry> _projects = [];
  final List<_ResumeEntry> _experiences = [];
  final List<_ResumeEntry> _certifications = [];
  final List<_ResumeEntry> _achievements = [];
  int _languageDropdownKey = 0;
  int _page = 0;

  static const _pageTitles = ['Personal information', 'Education', 'Skills', 'Projects', 'Experience', 'Certifications', 'Achievements'];
  static const _pageDescriptions = [
    'Start with the details employers need to reach you.',
    'Add your higher education and any optional school details.',
    'Choose programming languages and add your other skills.',
    'Add academic, personal, or professional projects.',
    'Add employment or internship experience, if you have it.',
    'Add certifications you have earned, if applicable.',
    'Share accomplishments and recognition you have received, if applicable.',
  ];
  static const _languagesList = [
    'Ada', 'Assembly', 'Bash', 'C', 'C#', 'C++', 'Clojure', 'COBOL', 'Dart',
    'Elixir', 'Elm', 'Erlang', 'F#', 'Fortran', 'Go', 'Groovy', 'Haskell',
    'HTML', 'Java', 'JavaScript', 'Julia', 'Kotlin', 'Lisp', 'Lua', 'MATLAB',
    'Objective-C', 'Pascal', 'Perl', 'PHP', 'PowerShell', 'Prolog', 'Python',
    'R', 'Ruby', 'Rust', 'Scala', 'Scheme', 'SQL', 'Swift', 'TypeScript',
    'Visual Basic', 'Zig',
  ];

  static const _degrees = [
    'B.A.', 'B.Arch.', 'B.B.A.', 'B.Com.', 'B.C.A.', 'B.Des.', 'B.E.',
    'B.Ed.', 'B.Pharm.', 'B.Sc.', 'B.Tech.', 'B.V.Sc.', 'BAMS', 'BDS',
    'BHMS', 'BPT', 'BumS', 'CA', 'CS', 'Diploma', 'DNB', 'LL.B.', 'LL.M.',
    'M.A.', 'M.Arch.', 'M.B.A.', 'M.C.A.', 'M.Com.', 'M.Des.', 'M.Ed.',
    'M.Pharm.', 'M.Phil.', 'M.Sc.', 'M.Tech.', 'M.V.Sc.', 'MBBS', 'MD',
    'MDS', 'MS', 'MPT', 'Ph.D.', 'Other',
  ];

  static const _branches = [
    'Aerospace Engineering', 'Agriculture', 'Applied Mathematics',
    'Architecture', 'Artificial Intelligence', 'Automobile Engineering',
    'Biochemistry', 'Bioinformatics', 'Biomedical Engineering',
    'Biotechnology', 'Botany', 'Chemical Engineering', 'Chemistry',
    'Civil Engineering', 'Commerce', 'Computer Applications',
    'Computer Science and Engineering', 'Data Science', 'Economics',
    'Electrical Engineering', 'Electronics and Communication Engineering',
    'English', 'Environmental Science', 'Finance', 'Information Technology',
    'Law', 'Management', 'Marketing', 'Mathematics', 'Mechanical Engineering',
    'Medicine', 'Microbiology', 'Physics', 'Psychology', 'Statistics',
  ];

  static const _colleges = [
    'Aligarh Muslim University', 'Amrita Vishwa Vidyapeetham',
    'Andhra University', 'Anna University', 'Banaras Hindu University',
    'BITS Pilani', 'BMS College of Engineering', 'Delhi Technological University',
    'Guru Gobind Singh Indraprastha University', 'IISc Bengaluru', 'IIT Bombay',
    'IIT Delhi', 'IIT Guwahati', 'IIT Hyderabad', 'IIT Kanpur', 'IIT Kharagpur',
    'IIT Madras', 'IIT Roorkee', 'Jamia Millia Islamia', 'Jadavpur University',
    'Jawaharlal Nehru University', 'Manipal Academy of Higher Education',
    'Mumbai University', 'NIT Calicut', 'NIT Durgapur', 'NIT Karnataka',
    'NIT Rourkela', 'NIT Tiruchirappalli', 'Osmania University', 'Pune University',
    'Savitribai Phule Pune University', 'SRM Institute of Science and Technology',
    'University of Calcutta', 'University of Hyderabad', 'VIT Vellore',
  ];

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose(); _location.dispose();
    _github.dispose(); _linkedin.dispose();
    _skillInput.dispose();
    for (final entry in _education) { entry.dispose(); }
    for (final entries in [_projects, _experiences, _certifications, _achievements]) {
      for (final entry in entries) { entry.dispose(); }
    }
    super.dispose();
  }

  void _next() {
    final valid = switch (_page) {
      0 => _personalForm.currentState?.validate() ?? false,
      1 => _educationForm.currentState?.validate() ?? false,
      3 => _projectsForm.currentState?.validate() ?? false,
      4 => _experienceForm.currentState?.validate() ?? false,
      _ => true,
    };
    if (!valid) return;
    if (_page < _pageTitles.length - 1) {
      setState(() => _page++);
      return;
    }
    _saveDraft();
  }

  Future<void> _saveDraft() async {
    final resume = ResumeData(
      name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim(),
      location: _location.text.trim(), github: _github.text.trim(), linkedin: _linkedin.text.trim(),
      skills: [..._languages, ..._extraSkills],
      education: _education.where((e) => e.degree.text.trim().isNotEmpty || e.college.text.trim().isNotEmpty).map((e) => EducationData(
        degree: e.degree.text.trim(), branch: e.branch.text.trim(), college: e.college.text.trim(),
        startYear: e.startYear.text.trim(), endYear: e.endYear.text.trim(), cgpa: e.score.text.trim(),
      )).toList(),
      schoolName: _education.first.school.text.trim(), tenthPercentage: _education.first.schoolScore.text.trim(),
      intermediateInstitution: _education.first.intermediate.text.trim(), intermediateMarks: _education.first.intermediateScore.text.trim(),
      projects: _projects.map((e) => ProjectData(name: e.fields['name']?.text.trim() ?? '', description: e.fields['description']?.text.trim() ?? '', technologies: e.fields['technologies']?.text.trim() ?? '')).where((e) => e.name.isNotEmpty || e.description.isNotEmpty).toList(),
      experiences: _experiences.map((e) => ExperienceData(jobTitle: e.fields['jobTitle']?.text.trim() ?? '', company: e.fields['company']?.text.trim() ?? '', employmentType: e.choice ?? '', startDate: e.fields['startDate']?.text.trim() ?? '', endDate: e.fields['endDate']?.text.trim() ?? '', currentlyWorking: e.ongoing, description: e.fields['description']?.text.trim() ?? '')).where((e) => e.jobTitle.isNotEmpty || e.company.isNotEmpty).toList(),
      certifications: _certifications.map((e) => CertificationData(name: e.fields['name']?.text.trim() ?? '', organization: e.fields['organization']?.text.trim() ?? '', issueDate: e.fields['issueDate']?.text.trim() ?? '', credentialId: e.fields['credentialId']?.text.trim() ?? '', credentialUrl: e.fields['credentialUrl']?.text.trim() ?? '')).where((e) => e.name.isNotEmpty).toList(),
      achievements: _achievements.map((e) => AchievementData(title: e.fields['title']?.text.trim() ?? '', date: e.fields['date']?.text.trim() ?? '', description: e.fields['description']?.text.trim() ?? '')).where((e) => e.title.isNotEmpty || e.description.isNotEmpty).toList(),
    );
    try {
      await DraftStorage().save(resume);
      if (!mounted) return;
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResumePreviewScreen(resumeData: resume)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save resume: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New resume')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_pageTitles[_page],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 5),
                Text(_pageDescriptions[_page],
                  style: const TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_page + 1) / _pageTitles.length, minHeight: 6, backgroundColor: AppColors.line, color: AppColors.accent))),
                  const SizedBox(width: 10),
                  Text('Page ${_page + 1} of ${_pageTitles.length}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
              ]),
            ),
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: _pageContent())),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
              child: Row(children: [
                if (_page > 0) ...[
                  OutlinedButton.icon(onPressed: () => setState(() => _page--), icon: const Icon(Icons.arrow_back), label: const Text('Back')),
                  const SizedBox(width: 12),
                ],
                Expanded(child: FilledButton.icon(
                  onPressed: _next,
                  icon: Icon(_page == _pageTitles.length - 1 ? Icons.save_outlined : Icons.arrow_forward),
                  label: Text(_page == _pageTitles.length - 1 ? 'Save draft' : 'Continue'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 15)),
                )),
              ]),
            ),
          ]),
        ),
      ),
    ),
  );

  Widget _pageContent() => switch (_page) {
    0 => _personalPage(),
    1 => _educationPage(),
    2 => _skillsPage(),
    3 => _projectsPage(),
    4 => _experiencePage(),
    5 => _certificationsPage(),
    _ => _achievementsPage(),
  };

  Widget _personalPage() => Form(
    key: _personalForm,
    child: ListView(key: const ValueKey('personal'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
      const _SectionHeading(icon: Icons.person_outline, title: 'Contact details'),
      const SizedBox(height: 15),
      _input(_name, 'Full name', required: true, hint: 'Jordan Lee', capitalization: TextCapitalization.words),
      _input(_email, 'Email', required: true, hint: 'jordan@example.com', type: TextInputType.emailAddress,
        validator: (value) { if (value == null || value.trim().isEmpty) return 'Email is required'; if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) return 'Enter a valid email address'; return null; }),
      _input(_phone, 'Phone number', required: true, hint: '+91 98765 43210', type: TextInputType.phone,
        validator: (value) { if (value == null || value.trim().isEmpty) return 'Phone number is required'; if (value.replaceAll(RegExp(r'\D'), '').length < 7) return 'Enter a valid phone number'; return null; }),
      _input(_location, 'Location / communication address', required: true, hint: 'City, State', capitalization: TextCapitalization.words, lines: 2),
      const SizedBox(height: 12),
      const _SectionHeading(icon: Icons.link, title: 'Professional links'),
      const SizedBox(height: 14),
      _input(_github, 'GitHub link', hint: 'https://github.com/username', type: TextInputType.url),
      _input(_linkedin, 'LinkedIn link', hint: 'https://linkedin.com/in/username', type: TextInputType.url),
      const Text('* Required fields', style: TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );

  Widget _educationPage() => Form(
    key: _educationForm,
    child: ListView(key: const ValueKey('education'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
      for (var i = 0; i < _education.length; i++) ...[
        _EducationCard(key: ValueKey(_education[i]), entry: _education[i], index: i,
          onRemove: _education.length > 1 ? () => setState(() { _education.removeAt(i).dispose(); }) : null),
        const SizedBox(height: 14),
      ],
      OutlinedButton.icon(
        onPressed: () => setState(() => _education.add(_EducationEntry())),
        icon: const Icon(Icons.add_circle_outline), label: const Text('Add another education'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 13)),
      ),
      const SizedBox(height: 18),
      const _SectionHeading(icon: Icons.school_outlined, title: 'Schooling and intermediate (optional)'),
      const SizedBox(height: 5),
      const Text('Optional — include your school or intermediate college and percentage if you wish.', style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
      const SizedBox(height: 12),
      _input(_education.first.school, 'School name (optional)', hint: 'School name', capitalization: TextCapitalization.words),
      _input(_education.first.schoolScore, 'School percentage (optional)', hint: 'e.g. 92%', type: TextInputType.number),
      _input(_education.first.intermediate, 'Intermediate college name (optional)', hint: 'College name', capitalization: TextCapitalization.words),
      _input(_education.first.intermediateScore, 'Intermediate percentage (optional)', hint: 'e.g. 88%', type: TextInputType.number),
      const Text('* Required fields', style: TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );

  Widget _skillsPage() => ListView(
    key: const ValueKey('skills'),
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
    children: [
      const _SectionHeading(icon: Icons.code, title: 'Programming languages'),
      const SizedBox(height: 5),
      const Text('Choose one or more languages from the alphabetical list.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        key: ValueKey(_languageDropdownKey),
        value: null,
        decoration: const InputDecoration(labelText: 'Add a programming language', prefixIcon: Icon(Icons.search)),
        items: _languagesList.map((language) => DropdownMenuItem(value: language, child: Text(language))).toList(),
        onChanged: (language) {
          if (language == null) return;
          setState(() { _languages.add(language); _languageDropdownKey++; });
        },
      ),
      const SizedBox(height: 10),
      if (_languages.isNotEmpty) Wrap(spacing: 8, runSpacing: 5, children: [
        for (final language in _languages) InputChip(label: Text(language), onDeleted: () => setState(() => _languages.remove(language))),
      ]) else const Text('Your selected languages will appear here.', style: TextStyle(fontSize: 12, color: AppColors.muted)),
      const SizedBox(height: 24),
      const _SectionHeading(icon: Icons.auto_awesome_outlined, title: 'Other skills'),
      const SizedBox(height: 5),
      const Text('Add tools, frameworks, databases, software, technical skills, or soft skills.', style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: TextField(controller: _skillInput, textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Add a skill', hintText: 'e.g. Figma, teamwork'),
          onSubmitted: (_) => _addSkill())),
        const SizedBox(width: 8),
        Padding(padding: const EdgeInsets.only(top: 4), child: IconButton.filled(onPressed: _addSkill, tooltip: 'Add skill', icon: const Icon(Icons.add))),
      ]),
      if (_extraSkills.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 5, children: [
          for (final skill in _extraSkills) InputChip(label: Text(skill), onDeleted: () => setState(() => _extraSkills.remove(skill))),
        ]),
      ],
    ],
  );

  void _addSkill() {
    final skill = _skillInput.text.trim();
    if (skill.isEmpty) return;
    if (!_extraSkills.any((item) => item.toLowerCase() == skill.toLowerCase())) {
      setState(() => _extraSkills.add(skill));
    }
    _skillInput.clear();
  }

  Widget _projectsPage() => Form(
    key: _projectsForm,
    child: ListView(key: const ValueKey('projects'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
      if (_projects.isEmpty) const _EmptyHint(text: 'No projects added yet. Add a project if you want it included in your resume.'),
      for (var i = 0; i < _projects.length; i++) ...[
        _entryCard(title: 'Project ${i + 1}', entry: _projects[i], onRemove: () => _removeEntry(_projects, _projects[i]), children: [
          _entryField(_projects[i], 'name', 'Project name', required: true),
          _entryField(_projects[i], 'description', 'Project description (optional)', lines: 4),
          _entryField(_projects[i], 'technologies', 'Technologies used', required: true),
        ]),
        const SizedBox(height: 12),
      ],
      _addButton('Add another project', Icons.add_circle_outline, () => setState(() => _projects.add(_ResumeEntry(['name', 'description', 'technologies'])))),
    ]),
  );

  Widget _experiencePage() => Form(
    key: _experienceForm,
    child: ListView(key: const ValueKey('experience'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
      if (_experiences.isEmpty) const _EmptyHint(text: 'No experience added yet. You can continue if you have not worked or interned yet.'),
      for (var i = 0; i < _experiences.length; i++) ...[
        _entryCard(title: 'Experience ${i + 1}', entry: _experiences[i], onRemove: () => _removeEntry(_experiences, _experiences[i]), children: [
          _entryField(_experiences[i], 'jobTitle', 'Job title', required: true),
          _entryField(_experiences[i], 'company', 'Company name', required: true),
          Row(children: [
            Expanded(child: _dateField(_experiences[i], 'startDate', 'Start date')),
            const SizedBox(width: 12),
            Expanded(child: _experiences[i].ongoing
              ? const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Ongoing', style: TextStyle(color: AppColors.muted)))
              : _dateField(_experiences[i], 'endDate', 'End date')),
          ]),
          CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('I currently work here / continue this internship'), value: _experiences[i].ongoing,
            onChanged: (value) => setState(() { _experiences[i].ongoing = value ?? false; if (_experiences[i].ongoing) _experiences[i].fields['endDate']!.clear(); })),
          DropdownButtonFormField<String>(
            value: _experiences[i].choice,
            decoration: const InputDecoration(labelText: 'Employment type'),
            items: const [DropdownMenuItem(value: 'Full-Time', child: Text('Full-Time')), DropdownMenuItem(value: 'Internship', child: Text('Internship'))],
            onChanged: (value) => _experiences[i].choice = value,
          ),
          _entryField(_experiences[i], 'description', 'Responsibilities and contributions (optional)', lines: 4),
        ]),
        const SizedBox(height: 12),
      ],
      _addButton('Add another experience', Icons.add_circle_outline, () => setState(() => _experiences.add(_ResumeEntry(['jobTitle', 'company', 'startDate', 'endDate', 'description'])))),
    ]),
  );

  Widget _certificationsPage() => ListView(key: const ValueKey('certifications'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
    if (_certifications.isEmpty) const _EmptyHint(text: 'No certifications added yet. This section is optional.'),
    for (var i = 0; i < _certifications.length; i++) ...[
      _entryCard(title: 'Certificate ${i + 1}', entry: _certifications[i], onRemove: () => _removeEntry(_certifications, _certifications[i]), children: [
        _entryField(_certifications[i], 'name', 'Certificate name'),
        _entryField(_certifications[i], 'organization', 'Issuing organization'),
        _dateField(_certifications[i], 'issueDate', 'Issue date'),
        _entryField(_certifications[i], 'credentialId', 'Credential ID'),
        _entryField(_certifications[i], 'credentialUrl', 'Credential URL (optional)', type: TextInputType.url),
      ]),
      const SizedBox(height: 12),
    ],
    _addButton('Add another certificate', Icons.add_circle_outline, () => setState(() => _certifications.add(_ResumeEntry(['name', 'organization', 'issueDate', 'credentialId', 'credentialUrl'])))),
  ]);

  Widget _achievementsPage() => ListView(key: const ValueKey('achievements'), padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), children: [
    if (_achievements.isEmpty) const _EmptyHint(text: 'No achievements added yet. Add accomplishments you have genuinely earned; this section is optional.'),
    for (var i = 0; i < _achievements.length; i++) ...[
      _entryCard(title: 'Achievement ${i + 1}', entry: _achievements[i], onRemove: () => _removeEntry(_achievements, _achievements[i]), children: [
        _entryField(_achievements[i], 'title', 'Achievement title'),
        _dateField(_achievements[i], 'date', 'Achievement date'),
        _entryField(_achievements[i], 'description', 'Achievement description', lines: 4),
      ]),
      const SizedBox(height: 12),
    ],
    _addButton('Add another achievement', Icons.add_circle_outline, () => setState(() => _achievements.add(_ResumeEntry(['title', 'date', 'description'])))),
  ]);

  Widget _entryCard({required String title, required _ResumeEntry entry, required VoidCallback onRemove, required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppColors.sheet, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink))),
        IconButton(onPressed: onRemove, tooltip: 'Remove $title', icon: const Icon(Icons.delete_outline), color: AppColors.muted)]),
      ...children,
    ]),
  );

  Widget _entryField(_ResumeEntry entry, String key, String label, {bool required = false, int lines = 1, TextInputType? type}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: entry.fields[key], keyboardType: type, minLines: lines, maxLines: lines,
      decoration: InputDecoration(labelText: required ? '$label *' : label),
      validator: required ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null : null,
    ),
  );

  Widget _dateField(_ResumeEntry entry, String key, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: entry.fields[key], readOnly: true,
      decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
      validator: key == 'endDate' && !entry.ongoing
          ? (value) {
              final start = DateTime.tryParse(entry.fields['startDate']?.text ?? '');
              final end = DateTime.tryParse(value ?? '');
              if (start != null && end != null && end.isBefore(start)) return 'End date cannot be before start date';
              return null;
            }
          : null,
      onTap: () async {
        final now = DateTime.now();
        final chosen = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1950), lastDate: DateTime(2100));
        if (chosen != null) entry.fields[key]!.text = '${chosen.year.toString().padLeft(4, '0')}-${chosen.month.toString().padLeft(2, '0')}-${chosen.day.toString().padLeft(2, '0')}';
      },
    ),
  );

  Widget _addButton(String label, IconData icon, VoidCallback onPressed) => OutlinedButton.icon(
    onPressed: onPressed, icon: Icon(icon), label: Text(label),
    style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 13)),
  );

  void _removeEntry(List<_ResumeEntry> list, _ResumeEntry entry) => setState(() { list.remove(entry); entry.dispose(); });

  Widget _input(TextEditingController controller, String label, {bool required = false, String? hint, TextInputType? type, TextCapitalization capitalization = TextCapitalization.none, int lines = 1, String? Function(String?)? validator}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller, keyboardType: type, textCapitalization: capitalization, minLines: lines, maxLines: lines,
      decoration: InputDecoration(labelText: required ? '$label *' : label, hintText: hint),
      validator: validator ?? (required ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null : null),
    ),
  );
}

class _EducationEntry {
  final degree = TextEditingController();
  final college = TextEditingController();
  final branch = TextEditingController();
  final startYear = TextEditingController();
  final endYear = TextEditingController();
  final score = TextEditingController();
  final school = TextEditingController();
  final schoolScore = TextEditingController();
  final intermediate = TextEditingController();
  final intermediateScore = TextEditingController();
  Map<String, String> toMap() => {
    'degree': degree.text.trim(), 'college': college.text.trim(), 'branch': branch.text.trim(),
    'startYear': startYear.text.trim(), 'endYear': endYear.text.trim(), 'score': score.text.trim(),
    'school': school.text.trim(), 'schoolPercentage': schoolScore.text.trim(),
    'intermediateCollege': intermediate.text.trim(), 'intermediatePercentage': intermediateScore.text.trim(),
  };
  void dispose() { degree.dispose(); college.dispose(); branch.dispose(); startYear.dispose(); endYear.dispose(); score.dispose(); school.dispose(); schoolScore.dispose(); intermediate.dispose(); intermediateScore.dispose(); }
}

class _ResumeEntry {
  _ResumeEntry(List<String> keys) : fields = {for (final key in keys) key: TextEditingController()};
  final Map<String, TextEditingController> fields;
  String? choice;
  bool ongoing = false;

  Map<String, Object?> toMap() => {
    for (final entry in fields.entries)
      if (entry.value.text.trim().isNotEmpty) entry.key: entry.value.text.trim(),
    if (choice != null) 'employmentType': choice,
    if (ongoing) 'ongoing': true,
  };

  void dispose() { for (final controller in fields.values) { controller.dispose(); } }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline, color: AppColors.accent, size: 19), const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: AppColors.ink, height: 1.4, fontSize: 13))),
    ]),
  );
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({super.key, required this.entry, required this.index, this.onRemove});
  final _EducationEntry entry;
  final int index;
  final VoidCallback? onRemove;

  static const degrees = _ResumeEditorPageState._degrees;
  static const branches = _ResumeEditorPageState._branches;
  static const colleges = _ResumeEditorPageState._colleges;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppColors.sheet, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('Education ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink))),
        if (onRemove != null) IconButton(onPressed: onRemove, tooltip: 'Remove education', icon: const Icon(Icons.delete_outline), color: AppColors.muted)]),
      DropdownButtonFormField<String>(
        value: degrees.contains(entry.degree.text) ? entry.degree.text : null,
        decoration: const InputDecoration(labelText: 'Degree *'),
        items: degrees.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (value) => entry.degree.text = value ?? '',
        validator: (value) => value == null ? 'Choose a degree' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(controller: entry.college, readOnly: true, decoration: const InputDecoration(labelText: 'College / university *', hintText: 'Search or enter institution', suffixIcon: Icon(Icons.search)),
        onTap: () async { final value = await _searchCollege(context, entry.college.text); if (value != null) entry.college.text = value; },
        validator: (value) => value == null || value.trim().isEmpty ? 'College / university is required' : null),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: branches.contains(entry.branch.text) ? entry.branch.text : null,
        decoration: const InputDecoration(labelText: 'Branch / specialization *'),
        items: branches.map((value) => DropdownMenuItem(value: value, child: Text(value.trim()))).toList(),
        onChanged: (value) => entry.branch.text = value ?? '',
        validator: (value) => value == null ? 'Choose a branch or specialization' : null,
      ),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _yearField(entry.startYear, 'Start year *')), const SizedBox(width: 12), Expanded(child: _yearField(entry.endYear, 'End year *'))]),
      TextFormField(controller: entry.score, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'CGPA / percentage *', hintText: 'e.g. 8.5 CGPA or 85%'),
        validator: (value) => value == null || value.trim().isEmpty ? 'CGPA / percentage is required' : null),
    ]),
  );

  Widget _yearField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label, hintText: '2024'),
      validator: (value) { final year = int.tryParse(value?.trim() ?? ''); if (year == null || year < 1950 || year > 2100) return 'Enter a valid year'; if (label.startsWith('End') && int.tryParse(entry.startYear.text) != null && year < int.parse(entry.startYear.text)) return 'Must be after start'; return null; }),
  );

  Future<String?> _searchCollege(BuildContext context, String current) async {
    final search = TextEditingController(text: current);
    return showDialog<String>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) {
      final filtered = colleges.where((name) => name.toLowerCase().contains(search.text.toLowerCase())).toList();
      return AlertDialog(
        title: const Text('Find your college or university'),
        content: SizedBox(width: 420, height: 430, child: Column(children: [
          TextField(controller: search, autofocus: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search institutions or type a name'), onChanged: (_) => setDialogState(() {})),
          const SizedBox(height: 8),
          Expanded(child: ListView(children: [
            for (final name in filtered) ListTile(title: Text(name), onTap: () => Navigator.pop(dialogContext, name)),
            if (search.text.trim().isNotEmpty && !colleges.any((name) => name.toLowerCase() == search.text.trim().toLowerCase()))
              ListTile(leading: const Icon(Icons.add), title: Text('Use "${search.text.trim()}"'), subtitle: const Text('Enter an institution not listed'), onTap: () => Navigator.pop(dialogContext, search.text.trim())),
          ])),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel'))],
      );
    }));
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.number, required this.label, this.active = false, this.complete = false});
  final String number; final String label; final bool active; final bool complete;
  @override
  Widget build(BuildContext context) => Row(children: [
    CircleAvatar(radius: 13, backgroundColor: active || complete ? AppColors.accent : AppColors.line,
      child: complete ? const Icon(Icons.check, size: 15, color: Colors.white) : Text(number, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.muted))),
    const SizedBox(width: 7), Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? AppColors.ink : AppColors.muted)),
    const SizedBox(width: 12),
  ]);
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});
  final IconData icon; final String title;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: AppColors.accent, size: 20), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)))]);
}
