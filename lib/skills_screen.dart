import 'package:flutter/material.dart';
import 'projects_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class SkillsScreen extends StatefulWidget {
  final ResumeData resumeData;

  const SkillsScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final skillController = TextEditingController();

  late List<String> skills;

  static const skillCategories = <String, List<String>>{
    'Programming languages': ['Python', 'Java', 'C', 'C++', 'JavaScript', 'Dart'],
    'Data and databases': ['SQL', 'MySQL', 'PostgreSQL', 'MongoDB', 'Excel'],
    'AI and ML tools': ['TensorFlow', 'Scikit-learn', 'PyTorch', 'OpenAI', 'Gemini'],
    'Soft skills': ['Communication', 'Leadership', 'Teamwork', 'Problem Solving'],
  };

  @override
  void initState() {
    super.initState();

    skills = List<String>.from(widget.resumeData.skills);
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = skillController.text.trim();

    if (skill.isEmpty) {
      return;
    }

    final alreadyExists = skills.any(
      (existingSkill) =>
          existingSkill.toLowerCase() == skill.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This skill has already been added.'),
        ),
      );
      return;
    }

    setState(() {
      skills.add(skill);
      skillController.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
    });
  }

  void _toggleSuggestedSkill(String skill, bool selected) {
    setState(() {
      skills.removeWhere(
        (item) => item.toLowerCase() == skill.toLowerCase(),
      );
      if (selected) skills.add(skill);
    });
  }

  Future<void> _saveAndContinue() async {
    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill.'),
        ),
      );
      return;
    }

    widget.resumeData.skills = List<String>.from(skills);
    await DraftStorage().save(widget.resumeData);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsScreen(
          resumeData: widget.resumeData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Skills',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Add the technical and professional skills '
                    'you actually have.',
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: skillController,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Enter a skill',
                            hintText: 'e.g. Python',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _addSkill,
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose only skills you actually have',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          for (final category in skillCategories.entries) ...[
                            Text(
                              category.key,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final skill in category.value)
                                  FilterChip(
                                    label: Text(skill),
                                    selected: skills.any(
                                      (item) =>
                                          item.toLowerCase() == skill.toLowerCase(),
                                    ),
                                    onSelected: (selected) =>
                                        _toggleSuggestedSkill(skill, selected),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Added Skills',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text('${skills.length} skills'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (skills.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text('No skills added yet'),
                          Text('Add your first skill above.'),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return InputChip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saveAndContinue,
                      child: const Text('Save & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
