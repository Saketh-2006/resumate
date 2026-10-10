import 'package:flutter/material.dart';
import 'certifications_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class ExperienceScreen extends StatefulWidget {
  final ResumeData resumeData;

  const ExperienceScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<ExperienceFormData> experienceForms;

  @override
  void initState() {
    super.initState();

    if (widget.resumeData.experiences.isEmpty) {
      experienceForms = [ExperienceFormData()];
    } else {
      experienceForms = widget.resumeData.experiences.map((experience) {
        return ExperienceFormData(
          jobTitle: experience.jobTitle,
          company: experience.company,
          employmentType: experience.employmentType,
          location: experience.location,
          startDate: experience.startDate,
          endDate: experience.endDate,
          currentlyWorking: experience.currentlyWorking,
          description: experience.description,
        );
      }).toList();
    }
  }

  void _addExperience() {
    if (experienceForms.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add a maximum of 4 experiences.'),
        ),
      );
      return;
    }

    setState(() {
      experienceForms.add(ExperienceFormData());
    });
  }

  void _removeExperience(int index) {
    if (experienceForms.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one experience section is required.'),
        ),
      );
      return;
    }

    setState(() {
      experienceForms.removeAt(index);
    });
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final experiences = experienceForms.map((form) {
      final experience = ExperienceData()
        ..jobTitle = form.jobTitleController.text.trim()
        ..company = form.companyController.text.trim()
        ..employmentType = form.employmentTypeController.text.trim()
        ..location = form.locationController.text.trim()
        ..startDate = form.startDateController.text.trim()
        ..endDate = form.endDateController.text.trim()
        ..currentlyWorking = form.currentlyWorking
        ..description = form.descriptionController.text.trim();

      return experience;
    }).toList();

    widget.resumeData.experiences = experiences;
    await DraftStorage().save(widget.resumeData);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificationsScreen(
          resumeData: widget.resumeData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final form in experienceForms) {
      form.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add your work experience, internships, or other professional experience.',
                    ),

                    const SizedBox(height: 28),

                    ...List.generate(
                      experienceForms.length,
                      (index) {
                        final form = experienceForms[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Experience ${index + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    if (experienceForms.length > 1)
                                      IconButton(
                                        onPressed: () =>
                                            _removeExperience(index),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        tooltip: 'Remove experience',
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: form.jobTitleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Job Title / Role',
                                    hintText:
                                        'e.g. Software Developer Intern',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.jobTitle = value;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter your job title';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: form.companyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Company / Organization',
                                    hintText: 'e.g. ABC Technologies',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.company = value;
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter company name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller:
                                      form.employmentTypeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Employment Type',
                                    hintText:
                                        'e.g. Internship, Full-time',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.employmentType = value;
                                  },
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: form.locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Location',
                                    hintText:
                                        'e.g. Hyderabad, India',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.location = value;
                                  },
                                ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller: form.startDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Start Date',
                                    hintText: 'e.g. June 2025',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.startDate = value;
                                  },
                                ),

                                const SizedBox(height: 18),

                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Currently working here',
                                  ),
                                  value: form.currentlyWorking,
                                  onChanged: (value) {
                                    setState(() {
                                      form.currentlyWorking = value;

                                      if (value) {
                                        form.endDateController.clear();
                                        form.endDate = '';
                                      }
                                    });
                                  },
                                ),

                                const SizedBox(height: 8),

                                if (!form.currentlyWorking)
                                  TextFormField(
                                    controller:
                                        form.endDateController,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'End Date',
                                      hintText: 'e.g. August 2025',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      form.endDate = value;
                                    },
                                  ),

                                const SizedBox(height: 18),

                                TextFormField(
                                  controller:
                                      form.descriptionController,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    hintText:
                                        'Describe your responsibilities and work...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    form.description = value;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    OutlinedButton.icon(
                      onPressed: _addExperience,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another Experience'),
                    ),

                    const SizedBox(height: 28),

                    TextButton(
                      onPressed: () {
                        widget.resumeData.experiences.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CertificationsScreen(
                              resumeData: widget.resumeData,
                            ),
                          ),
                        );
                      },
                      child: const Text('Skip experience'),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _saveExperience,
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

class ExperienceFormData {
  String jobTitle;
  String company;
  String employmentType;
  String location;
  String startDate;
  String endDate;
  bool currentlyWorking;
  String description;

  final TextEditingController jobTitleController;
  final TextEditingController companyController;
  final TextEditingController employmentTypeController;
  final TextEditingController locationController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController descriptionController;

  ExperienceFormData({
    this.jobTitle = '',
    this.company = '',
    this.employmentType = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.currentlyWorking = false,
    this.description = '',
  })  : jobTitleController = TextEditingController(text: jobTitle),
        companyController = TextEditingController(text: company),
        employmentTypeController =
            TextEditingController(text: employmentType),
        locationController = TextEditingController(text: location),
        startDateController =
            TextEditingController(text: startDate),
        endDateController =
            TextEditingController(text: endDate),
        descriptionController =
            TextEditingController(text: description);

  void dispose() {
    jobTitleController.dispose();
    companyController.dispose();
    employmentTypeController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
  }
}
