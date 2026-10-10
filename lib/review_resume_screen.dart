import 'package:flutter/material.dart';
import 'resume_data.dart';

class ReviewResumeScreen extends StatelessWidget {
  final ResumeData resumeData;

  const ReviewResumeScreen({
    super.key,
    required this.resumeData,
  });

  Widget buildSection(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> educationItems = [];

    for (final education in resumeData.education) {
      educationItems.add(
        'Degree: ${education.degree}',
      );
      educationItems.add(
        'Branch / Course: ${education.branch}',
      );
      educationItems.add(
        'College: ${education.college}',
      );

      if (education.location.isNotEmpty) {
        educationItems.add(
          'Location: ${education.location}',
        );
      }

      if (education.startYear.isNotEmpty) {
        educationItems.add(
          'Start Year: ${education.startYear}',
        );
      }

      if (education.endYear.isNotEmpty) {
        educationItems.add(
          'End Year: ${education.endYear}',
        );
      }

      if (education.cgpa.isNotEmpty) {
        educationItems.add(
          'CGPA / Percentage: ${education.cgpa}',
        );
      }

      educationItems.add('');
    }

    final List<String> skillItems =
        List<String>.from(resumeData.skills);

    final List<String> projectItems = [];

    for (final project in resumeData.projects) {
      projectItems.add(
        'Project Name: ${project.name}',
      );

      if (project.description.isNotEmpty) {
        projectItems.add(
          'Description: ${project.description}',
        );
      }

      if (project.technologies.isNotEmpty) {
        projectItems.add(
          'Technologies: ${project.technologies}',
        );
      }

      if (project.projectLink.isNotEmpty) {
        projectItems.add(
          'Link: ${project.projectLink}',
        );
      }

      projectItems.add('');
    }

    final List<String> experienceItems = [];

    for (final experience in resumeData.experiences) {
      experienceItems.add(
        'Job Title: ${experience.jobTitle}',
      );

      experienceItems.add(
        'Company: ${experience.company}',
      );

      if (experience.employmentType.isNotEmpty) {
        experienceItems.add(
          'Employment Type: ${experience.employmentType}',
        );
      }

      if (experience.location.isNotEmpty) {
        experienceItems.add(
          'Location: ${experience.location}',
        );
      }

      if (experience.startDate.isNotEmpty) {
        experienceItems.add(
          'Start Date: ${experience.startDate}',
        );
      }

      if (experience.currentlyWorking) {
        experienceItems.add(
          'End Date: Present',
        );
      } else if (experience.endDate.isNotEmpty) {
        experienceItems.add(
          'End Date: ${experience.endDate}',
        );
      }

      if (experience.description.isNotEmpty) {
        experienceItems.add(
          'Description: ${experience.description}',
        );
      }

      experienceItems.add('');
    }

    final List<String> certificationItems = [];

    for (final certification
        in resumeData.certifications) {
      certificationItems.add(
        'Certification: ${certification.name}',
      );

      certificationItems.add(
        'Organization: ${certification.organization}',
      );

      if (certification.issueDate.isNotEmpty) {
        certificationItems.add(
          'Issue Date: ${certification.issueDate}',
        );
      }

      if (certification.credentialId.isNotEmpty) {
        certificationItems.add(
          'Credential ID: ${certification.credentialId}',
        );
      }

      if (certification.credentialUrl.isNotEmpty) {
        certificationItems.add(
          'Credential URL: ${certification.credentialUrl}',
        );
      }

      certificationItems.add('');
    }

    final List<String> achievementItems = [];

    for (final achievement
        in resumeData.achievements) {
      achievementItems.add(
        'Title: ${achievement.title}',
      );

      if (achievement.organization.isNotEmpty) {
        achievementItems.add(
          'Organization / Event: '
          '${achievement.organization}',
        );
      }

      if (achievement.date.isNotEmpty) {
        achievementItems.add(
          'Date: ${achievement.date}',
        );
      }

      if (achievement.description.isNotEmpty) {
        achievementItems.add(
          'Description: ${achievement.description}',
        );
      }

      achievementItems.add('');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Resume'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Your Resume',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Review all your information before '
                    'generating your resume.',
                  ),

                  const SizedBox(height: 28),

                  buildSection(
                    context,
                    'Personal Information',
                    [
                      if (resumeData.name.isNotEmpty)
                        'Name: ${resumeData.name}',
                      if (resumeData.email.isNotEmpty)
                        'Email: ${resumeData.email}',
                      if (resumeData.phone.isNotEmpty)
                        'Phone: ${resumeData.phone}',
                      if (resumeData.location.isNotEmpty)
                        'Location: ${resumeData.location}',
                      if (resumeData.linkedin.isNotEmpty)
                        'LinkedIn: ${resumeData.linkedin}',
                      if (resumeData.github.isNotEmpty)
                        'GitHub: ${resumeData.github}',
                      if (resumeData.portfolio.isNotEmpty)
                        'Portfolio: ${resumeData.portfolio}',
                      if (resumeData.leetcode.isNotEmpty)
                        'LeetCode: ${resumeData.leetcode}',
                    ],
                  ),

                  buildSection(
                    context,
                    'Education',
                    educationItems,
                  ),

                  buildSection(
                    context,
                    'Skills',
                    skillItems,
                  ),

                  buildSection(
                    context,
                    'Projects',
                    projectItems,
                  ),

                  buildSection(
                    context,
                    'Experience',
                    experienceItems,
                  ),

                  buildSection(
                    context,
                    'Certifications',
                    certificationItems,
                  ),

                  buildSection(
                    context,
                    'Achievements',
                    achievementItems,
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Resume information collected successfully!',
                            ),
                          ),
                        );
                      },
                      child: const Text('Continue'),
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