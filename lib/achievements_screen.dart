
import 'package:flutter/material.dart';
import 'photo_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class AchievementsScreen extends StatefulWidget {
  final ResumeData resumeData;

  const AchievementsScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<AchievementsScreen> createState() =>
      _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _formKey = GlobalKey<FormState>();

  final achievementTitleController = TextEditingController();
  final organizationController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    achievementTitleController.dispose();
    organizationController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  bool _addCurrentAchievement({bool clearForm = false}) {
    if (!_formKey.currentState!.validate()) return false;
    widget.resumeData.achievements.add(
      AchievementData(
        title: achievementTitleController.text.trim(),
        organization: organizationController.text.trim(),
        date: dateController.text.trim(),
        description: descriptionController.text.trim(),
      ),
    );
    if (clearForm) {
      achievementTitleController.clear();
      organizationController.clear();
      dateController.clear();
      descriptionController.clear();
      _formKey.currentState!.reset();
      setState(() {});
    }
    return true;
  }

  Future<void> saveAchievement() async {
    final title = achievementTitleController.text.trim();
    if (title.isNotEmpty && !_addCurrentAchievement()) return;
    if (widget.resumeData.achievements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add an achievement or continue without one.'),
        ),
      );
      return;
    }
    await DraftStorage().save(widget.resumeData);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoScreen(resumeData: widget.resumeData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add achievements, awards, or important accomplishments.',
                    ),

                    const SizedBox(height: 28),

                    if (widget.resumeData.achievements.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          '${widget.resumeData.achievements.length} achievement(s) added',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),

                    TextFormField(
                      controller: achievementTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Achievement Title',
                        hintText: 'e.g. Hackathon Finalist',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter achievement title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Organization / Event',
                        hintText: 'e.g. College Hackathon',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'e.g. September 2026',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your achievement',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 28),

                    OutlinedButton.icon(
                      onPressed: () => _addCurrentAchievement(clearForm: true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add another achievement'),
                    ),

                    TextButton(
                      onPressed: () {
                        if (widget.resumeData.achievements.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoScreen(
                                resumeData: widget.resumeData,
                              ),
                            ),
                          );
                        } else {
                          saveAchievement();
                        }
                      },
                      child: const Text('Skip achievements'),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: saveAchievement,
                        child: const Text(
                          'Save & Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
