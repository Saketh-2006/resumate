import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../resume_data.dart';
import '../resume_templates.dart';

class PdfExportService {
  static Future<Uint8List> create(ResumeData resume) async {
    if (resume.name.trim().isEmpty) {
      throw StateError('Add your full name before exporting the resume.');
    }

    final document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 42;
    var page = document.pages.add();
    var y = 0.0;
    final width = page.getClientSize().width;
    final profilePhoto = await _circularPhoto(resume.photoPath);
    final template = resumeTemplates.firstWhere(
      (item) => item.id == resume.templateId,
      orElse: () => resumeTemplates.first,
    );
    final color = Color(resume.customAccentColor ?? template.color.toARGB32());
    final accent = PdfColor(
      (color.r * 255).round().clamp(0, 255).toInt(),
      (color.g * 255).round().clamp(0, 255).toInt(),
      (color.b * 255).round().clamp(0, 255).toInt(),
    );
    final leftInset = template.layout == 'sidebar'
        ? 18.0
        : template.layout == 'split'
        ? 9.0
        : 0.0;
    if (template.layout == 'banner') {
      page.graphics.drawRectangle(
        brush: PdfSolidBrush(accent),
        bounds: Rect.fromLTWH(0, 0, width, 112),
      );
    } else if (template.layout == 'sidebar' || template.layout == 'split') {
      page.graphics.drawRectangle(
        brush: PdfSolidBrush(accent),
        bounds: Rect.fromLTWH(0, 0, leftInset == 18 ? 7.0 : 2.0, 790),
      );
    }
    if (profilePhoto != null) {
      const photoSize = 54.0;
      final x = template.layout == 'centered'
          ? (width - photoSize) / 2
          : width - photoSize;
      final photoY = template.layout == 'banner' ? 27.0 : 0.0;
      page.graphics.drawImage(
        profilePhoto,
        Rect.fromLTWH(x, photoY, photoSize, photoSize),
      );
      if (template.layout == 'centered') y = photoSize + 8;
    }

    PdfLayoutResult write(
      String text, {
      double size = 10,
      bool bold = false,
      PdfColor? color,
      double gap = 6,
      double? textWidth,
      PdfTextAlignment alignment = PdfTextAlignment.left,
    }) {
      final font = PdfStandardFont(
        template.layout == 'editorial'
            ? PdfFontFamily.timesRoman
            : PdfFontFamily.helvetica,
        size * resume.fontScale,
        style: bold ? PdfFontStyle.bold : PdfFontStyle.regular,
      );
      final result =
          PdfTextElement(
            text: text,
            font: font,
            brush: PdfSolidBrush(color ?? PdfColor(39, 46, 60)),
            format: PdfStringFormat(alignment: alignment),
          ).draw(
            page: page,
            bounds: Rect.fromLTWH(
              leftInset,
              y,
              textWidth ?? width - leftInset,
              760 - y,
            ),
            format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
          );
      if (result == null) {
        throw StateError('Could not lay out resume text in the PDF.');
      }
      page = result.page;
      y = result.bounds.bottom + gap;
      if (y > 740) y = 0;
      return result;
    }

    final nameColor = template.layout == 'banner'
        ? PdfColor(255, 255, 255)
        : accent;
    write(
      resume.name,
      size: 23,
      bold: true,
      color: nameColor,
      gap: 5,
      textWidth: profilePhoto == null || template.layout == 'centered'
          ? null
          : width - 64,
      alignment: template.layout == 'centered'
          ? PdfTextAlignment.center
          : PdfTextAlignment.left,
    );
    final contact = <String>[
      resume.email,
      resume.phone,
      resume.location,
      resume.linkedin,
      resume.github,
      resume.portfolio,
    ].where((value) => value.trim().isNotEmpty).join('  |  ');
    if (contact.isNotEmpty) {
      write(
        contact,
        size: 9,
        gap: 14,
        textWidth: profilePhoto == null || template.layout == 'centered'
            ? null
            : width - 64,
        color: template.layout == 'banner' ? PdfColor(255, 255, 255) : null,
        alignment: template.layout == 'centered'
            ? PdfTextAlignment.center
            : PdfTextAlignment.left,
      );
    }
    if (template.layout == 'banner' && y < 112) y = 112;

    void heading(String title) {
      write(title.toUpperCase(), size: 11, bold: true, color: accent, gap: 4);
      page.graphics.drawLine(
        PdfPen(accent, width: 0.8),
        Offset(leftInset, y - 2),
        Offset(width, y - 2),
      );
      y += 5;
    }

    if (resume.summary.trim().isNotEmpty) {
      heading('Profile');
      write(resume.summary);
    }
    if (resume.education.isNotEmpty ||
        resume.schoolName.isNotEmpty ||
        resume.tenthPercentage.isNotEmpty ||
        resume.intermediateInstitution.isNotEmpty ||
        resume.intermediateMarks.isNotEmpty) {
      heading('Education');
      if (resume.schoolName.isNotEmpty || resume.tenthPercentage.isNotEmpty) {
        write('Secondary School', bold: true, gap: 2);
        if (resume.schoolName.isNotEmpty) write(resume.schoolName, gap: 2);
        if (resume.tenthPercentage.isNotEmpty) {
          write('10th: ${resume.tenthPercentage}', size: 9);
        }
      }
      if (resume.intermediateInstitution.isNotEmpty ||
          resume.intermediateMarks.isNotEmpty) {
        write('Intermediate', bold: true, gap: 2);
        if (resume.intermediateInstitution.isNotEmpty) {
          write(resume.intermediateInstitution, gap: 2);
        }
        if (resume.intermediateMarks.isNotEmpty) {
          write('Marks: ${resume.intermediateMarks}', size: 9);
        }
      }
      for (final item in resume.education) {
        final degree = [
          item.degree,
          item.branch,
        ].where((value) => value.isNotEmpty).join(' - ');
        write(degree, bold: true, gap: 2);
        write(item.college, gap: 2);
        final details = [
          if (item.location.isNotEmpty) item.location,
          if (item.startYear.isNotEmpty || item.endYear.isNotEmpty)
            '${item.startYear} - ${item.endYear}',
          if (item.cgpa.isNotEmpty) item.cgpa,
        ].join('  |  ');
        if (details.isNotEmpty) write(details, size: 9);
      }
    }

    if (resume.skills.isNotEmpty) {
      heading('Skills');
      write(resume.skills.join('  •  '));
    }
    if (resume.projects.isNotEmpty) {
      heading('Projects');
      for (final item in resume.projects) {
        write(item.name, bold: true, gap: 2);
        if (item.description.isNotEmpty) write(item.description, gap: 3);
        if (item.technologies.isNotEmpty) {
          write('Technologies: ${item.technologies}', size: 9, gap: 2);
        }
        if (item.projectLink.isNotEmpty) {
          write('Project link: ${item.projectLink}', size: 9);
        }
      }
    }
    if (resume.experiences.isNotEmpty) {
      heading('Experience');
      for (final item in resume.experiences) {
        write('${item.jobTitle} - ${item.company}', bold: true, gap: 2);
        final dates = [
          if (item.location.isNotEmpty) item.location,
          if (item.startDate.isNotEmpty) item.startDate,
          if (item.currentlyWorking)
            'Present'
          else if (item.endDate.isNotEmpty)
            item.endDate,
        ].join('  |  ');
        if (dates.isNotEmpty) write(dates, size: 9, gap: 2);
        if (item.description.isNotEmpty) write(item.description);
      }
    }
    if (resume.certifications.isNotEmpty) {
      heading('Certifications');
      for (final item in resume.certifications) {
        final details = [
          item.name,
          item.organization,
          item.issueDate,
          item.credentialUrl,
        ].where((value) => value.isNotEmpty).join('  |  ');
        write(details);
      }
    }
    if (resume.achievements.isNotEmpty) {
      heading('Achievements');
      for (final item in resume.achievements) {
        write(item.title, bold: true, gap: 2);
        final details = [
          item.organization,
          item.date,
          item.description,
        ].where((value) => value.isNotEmpty).join('  |  ');
        if (details.isNotEmpty) write(details);
      }
    }

    try {
      return Uint8List.fromList(await document.save());
    } finally {
      document.dispose();
    }
  }

  static Future<PdfBitmap?> _circularPhoto(String path) async {
    if (path.isEmpty) return null;
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await instantiateImageCodec(
        bytes,
        targetWidth: 256,
        targetHeight: 256,
      );
      final frame = await codec.getNextFrame();
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 256, 256));
      canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 256, 256)));
      final image = frame.image;
      final side = image.width < image.height
          ? image.width.toDouble()
          : image.height.toDouble();
      final src = Rect.fromLTWH(
        (image.width - side) / 2,
        (image.height - side) / 2,
        side,
        side,
      );
      canvas.drawImageRect(
        image,
        src,
        const Rect.fromLTWH(0, 0, 256, 256),
        Paint()..filterQuality = FilterQuality.high,
      );
      final png = await (await recorder.endRecording().toImage(
        256,
        256,
      )).toByteData(format: ImageByteFormat.png);
      codec.dispose();
      if (png == null) return null;
      return PdfBitmap(Uint8List.view(png.buffer));
    } catch (_) {
      // A missing or unsupported photo should never prevent PDF export.
      return null;
    }
  }

  static Future<Uri?> save(ResumeData resume) async {
    final bytes = await create(resume);
    final baseName = resume.name
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return FilePicker.saveFile(
      fileName: '${baseName.isEmpty ? 'Resume' : baseName}_Resume.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
      dialogTitle: 'Save your resume',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
  }
}
