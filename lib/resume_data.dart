/// Serializable resume draft shared by the form, preview, and persistence layers.
class ResumeData {
  String id;
  String updatedAt;
  String name;
  String email;
  String phone;
  String location;
  String linkedin;
  String github;
  String portfolio;
  String photoPath;
  String schoolName;
  String tenthPercentage;
  String intermediateInstitution;
  String intermediateMarks;
  String summary;
  String templateId;
  int? customAccentColor;
  double fontScale;
  List<EducationData> education;
  List<String> skills;
  List<ExperienceData> experiences;
  List<ProjectData> projects;
  List<CertificationData> certifications;
  List<AchievementData> achievements;

  ResumeData({
    this.id = '',
    this.updatedAt = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.github = '',
    this.portfolio = '',
    this.photoPath = '',
    this.schoolName = '',
    this.tenthPercentage = '',
    this.intermediateInstitution = '',
    this.intermediateMarks = '',
    this.summary = '',
    this.templateId = 'modern',
    this.customAccentColor,
    this.fontScale = 1.0,
    List<EducationData>? education,
    List<String>? skills,
    List<ExperienceData>? experiences,
    List<ProjectData>? projects,
    List<CertificationData>? certifications,
    List<AchievementData>? achievements,
  })  : education = education ?? <EducationData>[],
        skills = skills ?? <String>[],
        experiences = experiences ?? <ExperienceData>[],
        projects = projects ?? <ProjectData>[],
        certifications = certifications ?? <CertificationData>[],
        achievements = achievements ?? <AchievementData>[];

  Map<String, dynamic> toJson() => {
        'id': id,
        'updatedAt': updatedAt,
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedin': linkedin,
        'github': github,
        'portfolio': portfolio,
        'photoPath': photoPath,
        'schoolName': schoolName,
        'tenthPercentage': tenthPercentage,
        'intermediateInstitution': intermediateInstitution,
        'intermediateMarks': intermediateMarks,
        'summary': summary,
        'templateId': templateId,
        'customAccentColor': customAccentColor,
        'fontScale': fontScale,
        'education': education.map((item) => item.toJson()).toList(),
        'skills': skills,
        'experiences': experiences.map((item) => item.toJson()).toList(),
        'projects': projects.map((item) => item.toJson()).toList(),
        'certifications':
            certifications.map((item) => item.toJson()).toList(),
        'achievements': achievements.map((item) => item.toJson()).toList(),
      };

  factory ResumeData.fromJson(Map<String, dynamic> json) => ResumeData(
        id: _string(json['id']),
        updatedAt: _string(json['updatedAt']),
        name: _string(json['name']),
        email: _string(json['email']),
        phone: _string(json['phone']),
        location: _string(json['location']),
        linkedin: _string(json['linkedin']),
        github: _string(json['github']),
        portfolio: _string(json['portfolio']),
        photoPath: _string(json['photoPath']),
        schoolName: _string(json['schoolName']),
        tenthPercentage: _string(json['tenthPercentage']),
        intermediateInstitution: _string(json['intermediateInstitution']),
        intermediateMarks: _string(json['intermediateMarks']),
        summary: _string(json['summary']),
        templateId: _string(json['templateId'], fallback: 'modern'),
        customAccentColor: json['customAccentColor'] is int
            ? json['customAccentColor'] as int
            : null,
        fontScale: json['fontScale'] is num
            ? (json['fontScale'] as num).toDouble().clamp(.9, 1.1).toDouble()
            : 1.0,
        education: _list(json['education'], EducationData.fromJson),
        skills: _stringList(json['skills']),
        experiences: _list(json['experiences'], ExperienceData.fromJson),
        projects: _list(json['projects'], ProjectData.fromJson),
        certifications: _list(json['certifications'], CertificationData.fromJson),
        achievements: _list(json['achievements'], AchievementData.fromJson),
      );
}

class EducationData {
  String degree;
  String branch;
  String college;
  String location;
  String startYear;
  String endYear;
  String cgpa;

  EducationData({
    this.degree = '',
    this.branch = '',
    this.college = '',
    this.location = '',
    this.startYear = '',
    this.endYear = '',
    this.cgpa = '',
  });

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'branch': branch,
        'college': college,
        'location': location,
        'startYear': startYear,
        'endYear': endYear,
        'cgpa': cgpa,
      };

  factory EducationData.fromJson(Map<String, dynamic> json) => EducationData(
        degree: _string(json['degree']),
        branch: _string(json['branch']),
        college: _string(json['college']),
        location: _string(json['location']),
        startYear: _string(json['startYear']),
        endYear: _string(json['endYear']),
        cgpa: _string(json['cgpa']),
      );
}

class ExperienceData {
  String jobTitle;
  String company;
  String employmentType;
  String location;
  String startDate;
  String endDate;
  bool currentlyWorking;
  String description;

  ExperienceData({
    this.jobTitle = '',
    this.company = '',
    this.employmentType = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.currentlyWorking = false,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'jobTitle': jobTitle,
        'company': company,
        'employmentType': employmentType,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'currentlyWorking': currentlyWorking,
        'description': description,
      };

  factory ExperienceData.fromJson(Map<String, dynamic> json) => ExperienceData(
        jobTitle: _string(json['jobTitle']),
        company: _string(json['company']),
        employmentType: _string(json['employmentType']),
        location: _string(json['location']),
        startDate: _string(json['startDate']),
        endDate: _string(json['endDate']),
        currentlyWorking: json['currentlyWorking'] == true,
        description: _string(json['description']),
      );
}

class ProjectData {
  String name;
  String description;
  String technologies;
  String projectLink;

  ProjectData({
    this.name = '',
    this.description = '',
    this.technologies = '',
    this.projectLink = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'technologies': technologies,
        'projectLink': projectLink,
      };

  factory ProjectData.fromJson(Map<String, dynamic> json) => ProjectData(
        name: _string(json['name']),
        description: _string(json['description']),
        technologies: _string(json['technologies']),
        projectLink: _string(json['projectLink']),
      );
}

class CertificationData {
  String name;
  String organization;
  String issueDate;
  String credentialId;
  String credentialUrl;

  CertificationData({
    this.name = '',
    this.organization = '',
    this.issueDate = '',
    this.credentialId = '',
    this.credentialUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'organization': organization,
        'issueDate': issueDate,
        'credentialId': credentialId,
        'credentialUrl': credentialUrl,
      };

  factory CertificationData.fromJson(Map<String, dynamic> json) =>
      CertificationData(
        name: _string(json['name']),
        organization: _string(json['organization']),
        issueDate: _string(json['issueDate']),
        credentialId: _string(json['credentialId']),
        credentialUrl: _string(json['credentialUrl']),
      );
}

class AchievementData {
  String title;
  String organization;
  String date;
  String description;

  AchievementData({
    this.title = '',
    this.organization = '',
    this.date = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'organization': organization,
        'date': date,
        'description': description,
      };

  factory AchievementData.fromJson(Map<String, dynamic> json) =>
      AchievementData(
        title: _string(json['title']),
        organization: _string(json['organization']),
        date: _string(json['date']),
        description: _string(json['description']),
      );
}

String _string(Object? value, {String fallback = ''}) =>
    value is String ? value : fallback;

List<String> _stringList(Object? value) => value is List
    ? value.whereType<String>().toList()
    : <String>[];

List<T> _list<T>(
  Object? value,
  T Function(Map<String, dynamic>) decode,
) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((item) => decode(Map<String, dynamic>.from(item)))
      .toList();
}
