import 'package:flutter/material.dart';
import 'achievements_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';

class CertificationsScreen extends StatefulWidget {
  final ResumeData resumeData;

  const CertificationsScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<CertificationsScreen> createState() =>
      _CertificationsScreenState();
}

class _CertificationsScreenState
    extends State<CertificationsScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<CertificationFormData> certificationForms = [];

  @override
  void initState() {
    super.initState();

    // Load existing certifications if available.
    if (widget.resumeData.certifications.isNotEmpty) {
      for (final certification
          in widget.resumeData.certifications) {
        certificationForms.add(
          CertificationFormData(
            name: certification.name,
            organization: certification.organization,
            issueDate: certification.issueDate,
            credentialId: certification.credentialId,
            credentialUrl: certification.credentialUrl,
          ),
        );
      }
    } else {
      // Start with one empty certification form.
      certificationForms.add(CertificationFormData());
    }
  }

  @override
  void dispose() {
    for (final certification in certificationForms) {
      certification.dispose();
    }
    super.dispose();
  }

  void addCertification() {
    if (certificationForms.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can add up to 5 certifications.',
          ),
        ),
      );
      return;
    }

    setState(() {
      certificationForms.add(CertificationFormData());
    });
  }

  void removeCertification(int index) {
    if (certificationForms.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least one certification section is required.',
          ),
        ),
      );
      return;
    }

    setState(() {
      certificationForms[index].dispose();
      certificationForms.removeAt(index);
    });
  }

  Future<void> saveCertifications() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<CertificationData> certifications = [];

    for (final form in certificationForms) {
      certifications.add(
        CertificationData()
          ..name = form.nameController.text.trim()
          ..organization =
              form.organizationController.text.trim()
          ..issueDate = form.issueDateController.text.trim()
          ..credentialId =
              form.credentialIdController.text.trim()
          ..credentialUrl =
              form.credentialUrlController.text.trim(),
      );
    }

    widget.resumeData.certifications = certifications;
    await DraftStorage().save(widget.resumeData);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(
          resumeData: widget.resumeData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications'),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certifications',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add certifications you have actually completed.',
                    ),

                    const SizedBox(height: 28),

                    ...List.generate(
                      certificationForms.length,
                      (index) =>
                          _buildCertificationCard(index),
                    ),

                    const SizedBox(height: 4),

                    OutlinedButton.icon(
                      onPressed: addCertification,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add Another Certification',
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextButton(
                      onPressed: () {
                        widget.resumeData.certifications.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AchievementsScreen(
                              resumeData: widget.resumeData,
                            ),
                          ),
                        );
                      },
                      child: const Text('Skip certifications'),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: saveCertifications,
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

  Widget _buildCertificationCard(int index) {
    final form = certificationForms[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
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
                    'Certification ${index + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                if (certificationForms.length > 1)
                  IconButton(
                    onPressed: () =>
                        removeCertification(index),
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    tooltip: 'Remove certification',
                  ),
              ],
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: form.nameController,
              decoration: const InputDecoration(
                labelText: 'Certification Name',
                hintText:
                    'e.g. Python for Data Science',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter certification name';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller:
                  form.organizationController,
              decoration: const InputDecoration(
                labelText: 'Issuing Organization',
                hintText: 'e.g. Coursera',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter issuing organization';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: form.issueDateController,
              decoration: const InputDecoration(
                labelText: 'Issue Date',
                hintText: 'e.g. September 2026',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: form.credentialIdController,
              decoration: const InputDecoration(
                labelText: 'Credential ID',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: form.credentialUrlController,
              decoration: const InputDecoration(
                labelText: 'Credential URL',
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

class CertificationFormData {
  final TextEditingController nameController;
  final TextEditingController organizationController;
  final TextEditingController issueDateController;
  final TextEditingController credentialIdController;
  final TextEditingController credentialUrlController;

  CertificationFormData({
    String name = '',
    String organization = '',
    String issueDate = '',
    String credentialId = '',
    String credentialUrl = '',
  })  : nameController =
            TextEditingController(text: name),
        organizationController =
            TextEditingController(text: organization),
        issueDateController =
            TextEditingController(text: issueDate),
        credentialIdController =
            TextEditingController(text: credentialId),
        credentialUrlController =
            TextEditingController(text: credentialUrl);

  void dispose() {
    nameController.dispose();
    organizationController.dispose();
    issueDateController.dispose();
    credentialIdController.dispose();
    credentialUrlController.dispose();
  }
}
