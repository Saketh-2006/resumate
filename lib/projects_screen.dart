
import 'package:flutter/material.dart';
import 'experience_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class ProjectsScreen extends StatefulWidget {
  final ResumeData resumeData;

  const ProjectsScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<ProjectFormData> projectForms = [];

  @override
  void initState() {
    super.initState();

    // Create one project form initially.
    _addProjectForm();
  }

  void _addProjectForm() {
    if (projectForms.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add a maximum of 4 projects.'),
        ),
      );
      return;
    }

    setState(() {
      projectForms.add(ProjectFormData());
    });
  }

  void _removeProjectForm(int index) {
    if (projectForms.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one project is required.'),
        ),
      );
      return;
    }

    setState(() {
      projectForms[index].dispose();
      projectForms.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final project in projectForms) {
      project.dispose();
    }

    super.dispose();
  }

  bool _saveProjects() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    widget.resumeData.projects.clear();

    for (final project in projectForms) {
      final projectData = ProjectData();

      projectData.name =
          project.projectNameController.text.trim();

      projectData.description =
          project.descriptionController.text.trim();

      projectData.technologies =
          project.technologiesController.text.trim();

      projectData.projectLink =
          project.linkController.text.trim();

      widget.resumeData.projects.add(projectData);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
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
                      'Projects',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add up to 4 projects you have actually worked on.',
                    ),

                    const SizedBox(height: 28),

                    ...List.generate(
                      projectForms.length,
                      (index) => _buildProjectCard(index),
                    ),

                    const SizedBox(height: 12),

                    if (projectForms.length < 4)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _addProjectForm,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Add Project (${projectForms.length}/4)',
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    TextButton(
                      onPressed: () {
                        widget.resumeData.projects.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExperienceScreen(
                              resumeData: widget.resumeData,
                            ),
                          ),
                        );
                      },
                      child: const Text('Skip projects'),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () async {
                          if (_saveProjects()) {
                            await DraftStorage().save(widget.resumeData);
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExperienceScreen(
                                  resumeData: widget.resumeData,
                                ),
                              ),
                            );
                          }
                        },
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

  Widget _buildProjectCard(int index) {
    final project = projectForms[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Project ${index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                if (projectForms.length > 1)
                  IconButton(
                    tooltip: 'Remove project',
                    onPressed: () {
                      _removeProjectForm(index);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: project.projectNameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText:
                    'e.g. AI-Based Smart Soil Fertility Prediction System',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter project name';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: project.descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Project Description',
                hintText:
                    'Describe what you built and what it does.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter project description';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: project.technologiesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Technologies Used',
                hintText:
                    'e.g. Python, Flutter, Firebase',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter technologies used';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: project.linkController,
              decoration: const InputDecoration(
                labelText: 'Project / GitHub Link',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// PROJECT FORM DATA
// =====================================================

class ProjectFormData {
  final TextEditingController projectNameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController technologiesController =
      TextEditingController();

  final TextEditingController linkController =
      TextEditingController();

  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    technologiesController.dispose();
    linkController.dispose();
  }
}
