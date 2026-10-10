import '../resume_data.dart';

/// Builds a small, self-contained LaTeX resume supported by the PDF compiler.
class LatexResumeService {
  static String _escape(String value) {
    const replacements = {
      '\\': r'\textbackslash{}', '&': r'\&', '%': r'\%', r'$': r'\$',
      '#': r'\#', '_': r'\_', '{': r'\{', '}': r'\}',
      '~': r'\textasciitilde{}', '^': r'\textasciicircum{}',
    };
    final result = StringBuffer();
    for (final character in value.split('')) {
      result.write(replacements[character] ?? character);
    }
    return result.toString();
  }

  static String create(ResumeData resume) {
    final accent = (resume.customAccentColor ?? 0xFF4559B8)
        .toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
    final contact = [resume.email, resume.phone, resume.location, resume.linkedin, resume.github, resume.portfolio]
        .where((value) => value.trim().isNotEmpty).map(_escape).join(r' \textbar{} ');
    final lines = <String>[
      r'\documentclass[10pt,a4paper]{article}',
      r'\usepackage[margin=0.7in]{geometry}',
      r'\usepackage[T1]{fontenc}',
      r'\usepackage{xcolor}',
      r'\usepackage{hyperref}',
      '\\definecolor{accent}{HTML}{$accent}',
      r'\setlength{\parindent}{0pt}',
      r'\begin{document}',
      r'{\Huge\bfseries ' + _escape(resume.name) + r'}\par',
      if (contact.isNotEmpty) r'{\small ' + contact + r'}\par',
      r'\vspace{8pt}',
    ];
    void section(String title, Iterable<String> entries) {
      final values = entries.where((value) => value.trim().isNotEmpty).toList();
      if (values.isEmpty) return;
      lines.add('\\section*{\\color{accent}${_escape(title)}}');
      lines.addAll(values);
    }
    section('Profile', [if (resume.summary.trim().isNotEmpty) _escape(resume.summary) + r'\par']);
    section('Education', [
      if (resume.schoolName.isNotEmpty || resume.tenthPercentage.isNotEmpty)
        r'\textbf{Secondary School}\\ ' + _escape([resume.schoolName, resume.tenthPercentage].where((s) => s.isNotEmpty).join(' | ')) + r'\par',
      if (resume.intermediateInstitution.isNotEmpty || resume.intermediateMarks.isNotEmpty)
        r'\textbf{Intermediate}\\ ' + _escape([resume.intermediateInstitution, resume.intermediateMarks].where((s) => s.isNotEmpty).join(' | ')) + r'\par',
      ...resume.education.map((e) => r'\textbf{' + _escape([e.degree, e.branch].where((s) => s.isNotEmpty).join(' — ')) + r'}\\ ' + _escape([e.college, e.location, [e.startYear, e.endYear].where((s) => s.isNotEmpty).join('–'), e.cgpa].where((s) => s.isNotEmpty).join(' | ')) + r'\par'),
    ]);
    section('Skills', [if (resume.skills.isNotEmpty) _escape(resume.skills.join(', ')) + r'\par']);
    section('Experience', resume.experiences.map((e) => r'\textbf{' + _escape([e.jobTitle, e.company].where((s) => s.isNotEmpty).join(' — ')) + r'}\\ ' + _escape([e.location, [e.startDate, e.currentlyWorking ? 'Present' : e.endDate].where((s) => s.isNotEmpty).join('–'), e.description].where((s) => s.isNotEmpty).join(' | ')) + r'\par'));
    section('Projects', resume.projects.map((e) => r'\textbf{' + _escape(e.name) + r'}\\ ' + _escape([e.description, if (e.technologies.isNotEmpty) 'Technologies: ${e.technologies}', e.projectLink].where((s) => s.isNotEmpty).join(' | ')) + r'\par'));
    section('Certifications', resume.certifications.map((e) => r'\textbf{' + _escape(e.name) + r'}\\ ' + _escape([e.organization, e.issueDate, e.credentialUrl].where((s) => s.isNotEmpty).join(' | ')) + r'\par'));
    section('Achievements', resume.achievements.map((e) => r'\textbf{' + _escape(e.title) + r'}\\ ' + _escape([e.organization, e.date, e.description].where((s) => s.isNotEmpty).join(' | ')) + r'\par'));
    lines.add(r'\end{document}');
    return lines.join('\n');
  }
}
