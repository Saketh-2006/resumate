import 'package:flutter/material.dart';

import 'api_service.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class EditResumeScreen extends StatefulWidget {
  final ResumeData resumeData;

  const EditResumeScreen({super.key, required this.resumeData});

  @override
  State<EditResumeScreen> createState() => _EditResumeScreenState();
}

class _EditResumeScreenState extends State<EditResumeScreen> {
  ResumeData get resume => widget.resumeData;

  Future<void> _improve(TextEditingController controller) async {
    final original = controller.text.trim();
    if (original.isEmpty) return;
    try {
      final response = await ApiService.improveText(original);
      if (!mounted) return;
      final suggested = response['suggested'] as String? ?? '';
      if (suggested.isEmpty || suggested == original) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No wording changes were suggested.')),
        );
        return;
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Review wording suggestion'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Original'),
                  SelectableText(original),
                  const SizedBox(height: 14),
                  const Text('Suggested'),
                  SelectableText(suggested),
                  const SizedBox(height: 12),
                  const Text(
                    'Check that the wording remains accurate before accepting it.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Accept suggestion'),
            ),
          ],
        ),
      );
      if (accepted == true) controller.text = suggested;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI wording help is unavailable: $error')),
      );
    }
  }

  Future<void> _generateSummary(TextEditingController controller) async {
    try {
      final resumeFacts = resume.toJson()
        ..remove('id')
        ..remove('updatedAt')
        ..remove('email')
        ..remove('phone')
        ..remove('location')
        ..remove('linkedin')
        ..remove('github')
        ..remove('portfolio')
;
      final response = await ApiService.generateSummary(resumeFacts);
      if (!mounted) return;
      final suggested = response['summary'] as String? ?? '';
      if (suggested.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No summary was returned.')),
        );
        return;
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Review professional summary'),
          content: SelectableText(suggested),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Accept summary'),
            ),
          ],
        ),
      );
      if (accepted == true) controller.text = suggested;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Summary generation is unavailable: $error')),
      );
    }
  }

  Future<Map<String, String>?> _fields(
    String title,
    Map<String, String> values,
  ) async {
    final controllers = {
      for (final entry in values.entries)
        entry.key: TextEditingController(text: entry.value),
    };
    final formKey = GlobalKey<FormState>();
    const educationRequiredFields = {
      'Degree',
      'Branch / specialization',
      'Institution',
      'Location',
      'Start year',
      'End year',
      'CGPA / percentage',
    };
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in controllers.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: entry.value,
                            minLines:
                                entry.key == 'Description' || entry.key == 'Summary'
                                    ? 2
                                    : 1,
                            maxLines:
                                entry.key == 'Description' || entry.key == 'Summary'
                                    ? 5
                                    : 1,
                            decoration: InputDecoration(
                              labelText: (title == 'Personal information' &&
                                          {'Name', 'Email', 'Phone', 'Location *'}
                                              .contains(entry.key)) ||
                                      (title == 'Education' &&
                                          educationRequiredFields.contains(entry.key))
                                  ? '${entry.key}${entry.key.endsWith('*') ? '' : ' *'}'
                                  : entry.key,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (text) {
                              final value = text?.trim() ?? '';
                              if ((entry.key == 'Name' ||
                                      (title == 'Education' &&
                                          educationRequiredFields.contains(entry.key))) &&
                                  (text == null || text.trim().isEmpty)) {
                                return 'This field is required';
                              }
                              if (title == 'Personal information' &&
                                  entry.key == 'Location *' &&
                                  value.isEmpty) {
                                return 'Please enter your city and country/region';
                              }
                              if (title == 'Personal information' && entry.key == 'Email') {
                                if (value.isEmpty ||
                                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                              }
                              if (title == 'Personal information' && entry.key == 'Phone') {
                                if (value.replaceAll(RegExp(r'\D'), '').length < 7) {
                                  return 'Enter a valid phone number';
                                }
                              }
                              if (title == 'Education' &&
                                  (entry.key == 'Start year' || entry.key == 'End year') &&
                                  !RegExp(r'^\d{4}$').hasMatch(value)) {
                                return 'Enter a valid 4-digit year';
                              }
                              if (title == 'Education' && entry.key == 'End year') {
                                final startYear = int.tryParse(
                                  controllers['Start year']!.text.trim(),
                                );
                                final endYear = int.tryParse(value);
                                if (startYear != null && endYear != null && endYear < startYear) {
                                  return 'End year must be the same as or later than start year';
                                }
                              }
                              if (title == 'Education' && entry.key == 'CGPA / percentage') {
                                final score = double.tryParse(value.replaceAll('%', ''));
                                if (score == null || score <= 0 || score > 100) {
                                  return 'Enter a score greater than 0 and at most 100';
                                }
                              }
                              return null;
                            },
                          ),
                          if (entry.key == 'Description')
                            TextButton.icon(
                              onPressed: () => _improve(entry.value),
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Suggest clearer wording'),
                            ),
                          if (entry.key == 'Summary')
                            TextButton.icon(
                              onPressed: () => _generateSummary(entry.value),
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Generate from my resume details'),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  dialogContext,
                  {
                    for (final entry in controllers.entries)
                      entry.key: entry.value.text.trim(),
                  },
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    return result;
  }

  Future<void> _editPersonal() async {
    final result = await _fields('Personal information', {
      'Name': resume.name,
      'Email': resume.email,
      'Phone': resume.phone,
      'Location *': resume.location,
      'LinkedIn': resume.linkedin,
      'GitHub': resume.github,
      'Portfolio': resume.portfolio,
      'School name (10th)': resume.schoolName,
      '10th percentage / marks': resume.tenthPercentage,
      'Intermediate college / school': resume.intermediateInstitution,
      'Intermediate marks / percentage': resume.intermediateMarks,
      'Summary': resume.summary,
    });
    if (result == null) return;
    resume
      ..name = result['Name'] ?? ''
      ..email = result['Email'] ?? ''
      ..phone = result['Phone'] ?? ''
      ..location = result['Location *'] ?? ''
      ..linkedin = result['LinkedIn'] ?? ''
      ..github = result['GitHub'] ?? ''
      ..portfolio = result['Portfolio'] ?? ''
      ..schoolName = result['School name (10th)'] ?? ''
      ..tenthPercentage = result['10th percentage / marks'] ?? ''
      ..intermediateInstitution = result['Intermediate college / school'] ?? ''
      ..intermediateMarks = result['Intermediate marks / percentage'] ?? ''
      ..summary = result['Summary'] ?? '';
    setState(() {});
  }

  Future<void> _editEducation(int? index) async {
    final current = index == null ? EducationData() : resume.education[index];
    final result = await _fields('Education', {
      'Degree': current.degree,
      'Branch / specialization': current.branch,
      'Institution': current.college,
      'Location': current.location,
      'Start year': current.startYear,
      'End year': current.endYear,
      'CGPA / percentage': current.cgpa,
    });
    if (result == null) return;
    final item = EducationData(
      degree: result['Degree'] ?? '',
      branch: result['Branch / specialization'] ?? '',
      college: result['Institution'] ?? '',
      location: result['Location'] ?? '',
      startYear: result['Start year'] ?? '',
      endYear: result['End year'] ?? '',
      cgpa: result['CGPA / percentage'] ?? '',
    );
    setState(() {
      if (index == null) {
        resume.education.add(item);
      } else {
        resume.education[index] = item;
      }
    });
  }

  Future<void> _editProject(int? index) async {
    final current = index == null ? ProjectData() : resume.projects[index];
    final result = await _fields('Project', {
      'Name': current.name,
      'Description': current.description,
      'Technologies': current.technologies,
      'Project URL': current.projectLink,
    });
    if (result == null) return;
    final item = ProjectData(
      name: result['Name'] ?? '',
      description: result['Description'] ?? '',
      technologies: result['Technologies'] ?? '',
      projectLink: result['Project URL'] ?? '',
    );
    setState(() {
      if (index == null) {
        resume.projects.add(item);
      } else {
        resume.projects[index] = item;
      }
    });
  }

  Future<void> _editExperience(int? index) async {
    final current = index == null ? ExperienceData() : resume.experiences[index];
    final result = await _fields('Experience', {
      'Role': current.jobTitle,
      'Company': current.company,
      'Employment type': current.employmentType,
      'Location': current.location,
      'Start date': current.startDate,
      'End date': current.endDate,
      'Currently working (yes/no)': current.currentlyWorking ? 'yes' : 'no',
      'Description': current.description,
    });
    if (result == null) return;
    final item = ExperienceData(
      jobTitle: result['Role'] ?? '',
      company: result['Company'] ?? '',
      employmentType: result['Employment type'] ?? '',
      location: result['Location'] ?? '',
      startDate: result['Start date'] ?? '',
      endDate: result['End date'] ?? '',
      currentlyWorking:
          (result['Currently working (yes/no)'] ?? '').toLowerCase() == 'yes',
      description: result['Description'] ?? '',
    );
    setState(() {
      if (index == null) {
        resume.experiences.add(item);
      } else {
        resume.experiences[index] = item;
      }
    });
  }

  Future<void> _editCertification(int? index) async {
    final current =
        index == null ? CertificationData() : resume.certifications[index];
    final result = await _fields('Certification', {
      'Name': current.name,
      'Organization': current.organization,
      'Issue date': current.issueDate,
      'Credential ID': current.credentialId,
      'Credential URL': current.credentialUrl,
    });
    if (result == null) return;
    final item = CertificationData(
      name: result['Name'] ?? '',
      organization: result['Organization'] ?? '',
      issueDate: result['Issue date'] ?? '',
      credentialId: result['Credential ID'] ?? '',
      credentialUrl: result['Credential URL'] ?? '',
    );
    setState(() {
      if (index == null) {
        resume.certifications.add(item);
      } else {
        resume.certifications[index] = item;
      }
    });
  }

  Future<void> _editAchievement(int? index) async {
    final current =
        index == null ? AchievementData() : resume.achievements[index];
    final result = await _fields('Achievement', {
      'Name': current.title,
      'Organization / event': current.organization,
      'Date': current.date,
      'Description': current.description,
    });
    if (result == null) return;
    final item = AchievementData(
      title: result['Name'] ?? '',
      organization: result['Organization / event'] ?? '',
      date: result['Date'] ?? '',
      description: result['Description'] ?? '',
    );
    setState(() {
      if (index == null) {
        resume.achievements.add(item);
      } else {
        resume.achievements[index] = item;
      }
    });
  }

  Future<void> _addSkill() async {
    final result = await _fields('Add a skill', {'Name': ''});
    final skill = result?['Name']?.trim() ?? '';
    if (skill.isEmpty) return;
    setState(() {
      if (!resume.skills.any((item) => item.toLowerCase() == skill.toLowerCase())) {
        resume.skills.add(skill);
      }
    });
  }

  Future<void> _delete<T>(List<T> items, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this item?'),
        content: const Text('This change will be saved with your resume.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => items.removeAt(index));
  }

  Widget _section(String title, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );

  Widget _recordTile(String title, String subtitle, VoidCallback edit, VoidCallback remove) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: edit,
        trailing: IconButton(
          tooltip: 'Remove',
          onPressed: remove,
          icon: const Icon(Icons.delete_outline),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit resume')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _section('Personal information', [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(resume.name.isEmpty ? 'Add your name' : resume.name),
                      subtitle: Text([resume.email, resume.phone, resume.location]
                          .where((item) => item.isNotEmpty)
                          .join(' · ')),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: _editPersonal,
                    ),
                  ]),
                  if (resume.schoolName.isNotEmpty ||
                      resume.tenthPercentage.isNotEmpty ||
                      resume.intermediateInstitution.isNotEmpty ||
                      resume.intermediateMarks.isNotEmpty)
                    _section('Schooling', [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(resume.schoolName.isEmpty
                            ? 'School details'
                            : resume.schoolName),
                        subtitle: Text([
                          if (resume.tenthPercentage.isNotEmpty)
                            '10th: ${resume.tenthPercentage}',
                          if (resume.intermediateInstitution.isNotEmpty)
                            resume.intermediateInstitution,
                          if (resume.intermediateMarks.isNotEmpty)
                            'Intermediate: ${resume.intermediateMarks}',
                        ].join(' · ')),
                        trailing: const Icon(Icons.edit_outlined),
                        onTap: _editPersonal,
                      ),
                    ]),
                  _section('Education', [
                    for (var i = 0; i < resume.education.length; i++)
                      _recordTile(
                        resume.education[i].degree,
                        resume.education[i].college,
                        () => _editEducation(i),
                        () => _delete(resume.education, i),
                      ),
                    TextButton.icon(
                      onPressed: () => _editEducation(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add education'),
                    ),
                  ]),
                  _section('Skills', [
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final skill in resume.skills)
                          InputChip(
                            label: Text(skill),
                            onDeleted: () => setState(() => resume.skills.remove(skill)),
                          ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add),
                      label: const Text('Add skill'),
                    ),
                  ]),
                  _section('Projects', [
                    for (var i = 0; i < resume.projects.length; i++)
                      _recordTile(
                        resume.projects[i].name,
                        resume.projects[i].description,
                        () => _editProject(i),
                        () => _delete(resume.projects, i),
                      ),
                    TextButton.icon(
                      onPressed: () => _editProject(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add project'),
                    ),
                  ]),
                  _section('Experience', [
                    for (var i = 0; i < resume.experiences.length; i++)
                      _recordTile(
                        resume.experiences[i].jobTitle,
                        resume.experiences[i].company,
                        () => _editExperience(i),
                        () => _delete(resume.experiences, i),
                      ),
                    TextButton.icon(
                      onPressed: () => _editExperience(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add experience'),
                    ),
                  ]),
                  _section('Certifications', [
                    for (var i = 0; i < resume.certifications.length; i++)
                      _recordTile(
                        resume.certifications[i].name,
                        resume.certifications[i].organization,
                        () => _editCertification(i),
                        () => _delete(resume.certifications, i),
                      ),
                    TextButton.icon(
                      onPressed: () => _editCertification(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add certification'),
                    ),
                  ]),
                  _section('Achievements', [
                    for (var i = 0; i < resume.achievements.length; i++)
                      _recordTile(
                        resume.achievements[i].title,
                        resume.achievements[i].organization,
                        () => _editAchievement(i),
                        () => _delete(resume.achievements, i),
                      ),
                    TextButton.icon(
                      onPressed: () => _editAchievement(null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add achievement'),
                    ),
                  ]),
                  FilledButton.icon(
                    onPressed: () async {
                      await DraftStorage().save(resume);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
