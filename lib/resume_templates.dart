import 'package:flutter/material.dart';

/// A resume style combines a color palette with a layout family. Templates
/// sharing a layout still have distinct palettes and names for different roles.
class ResumeTemplateOption {
  final String id;
  final String name;
  final String description;
  final Color color;
  final String layout;

  const ResumeTemplateOption(
    this.id,
    this.name,
    this.description,
    this.color, {
    this.layout = 'classic',
  });
}

const resumeTemplates = <ResumeTemplateOption>[
  ResumeTemplateOption('modern', 'Modern Blue', 'Clean header with a confident blue accent.', Color(0xFF4559B8), layout: 'banner'),
  ResumeTemplateOption('professional', 'Professional Navy', 'Traditional, balanced layout for internships and early careers.', Color(0xFF21436E), layout: 'classic'),
  ResumeTemplateOption('minimal', 'Minimal ATS', 'Quiet typography and a text-first, ATS-friendly structure.', Color(0xFF414852), layout: 'ats'),
  ResumeTemplateOption('creative', 'Creative Violet', 'Distinctive violet details for creative and technology roles.', Color(0xFF7D43A3), layout: 'sidebar'),
  ResumeTemplateOption('executive', 'Executive Teal', 'Refined spacing with understated teal accents.', Color(0xFF1F4D48), layout: 'editorial'),
  ResumeTemplateOption('swiss_grid', 'Swiss Grid', 'Precise alignment and a crisp geometric header.', Color(0xFF202A44), layout: 'split'),
  ResumeTemplateOption('academic', 'Academic Scholar', 'Formal hierarchy for education and research profiles.', Color(0xFF2F5D50), layout: 'centered'),
  ResumeTemplateOption('tech_engineer', 'Tech Engineer', 'Compact technical profile with a structured side rail.', Color(0xFF087E8B), layout: 'sidebar'),
  ResumeTemplateOption('product_manager', 'Product Manager', 'A decisive banner and clear achievement sections.', Color(0xFF4F46A5), layout: 'banner'),
  ResumeTemplateOption('data_analyst', 'Data Analyst', 'Cool blue-green palette with orderly information blocks.', Color(0xFF176B87), layout: 'split'),
  ResumeTemplateOption('graduate', 'Graduate Starter', 'Friendly, approachable layout for student applications.', Color(0xFF2563A6), layout: 'centered'),
  ResumeTemplateOption('corporate', 'Corporate Clean', 'Conservative charcoal styling for formal employers.', Color(0xFF374151), layout: 'classic'),
  ResumeTemplateOption('editorial', 'Editorial Serif', 'Elegant typography and editorial spacing.', Color(0xFF7C3F32), layout: 'editorial'),
  ResumeTemplateOption('product_designer', 'Product Designer', 'A vivid portfolio-ready style with a clear sidebar.', Color(0xFFB43D70), layout: 'sidebar'),
  ResumeTemplateOption('research', 'Research Profile', 'Structured sections for academic projects and publications.', Color(0xFF35654D), layout: 'classic'),
  ResumeTemplateOption('startup', 'Startup Builder', 'Energetic blue-green header for fast-moving teams.', Color(0xFF087F8C), layout: 'banner'),
  ResumeTemplateOption('finance', 'Finance Formal', 'Restrained forest-green details and compact typography.', Color(0xFF315644), layout: 'ats'),
  ResumeTemplateOption('consultant', 'Consultant Slate', 'Polished slate accents and clear section separation.', Color(0xFF53657D), layout: 'split'),
  ResumeTemplateOption('healthcare', 'Healthcare Professional', 'Calm, reassuring color palette and readable hierarchy.', Color(0xFF287A78), layout: 'classic'),
  ResumeTemplateOption('marketing', 'Marketing Creative', 'Warm coral accents with strong visual rhythm.', Color(0xFFC05B45), layout: 'banner'),
  ResumeTemplateOption('operations', 'Operations Pro', 'Practical, organized structure with a strong left rail.', Color(0xFF59636E), layout: 'sidebar'),
  ResumeTemplateOption('legal', 'Legal Classic', 'Traditional black-and-ink style with formal spacing.', Color(0xFF34343C), layout: 'editorial'),
  ResumeTemplateOption('portfolio', 'Portfolio Focus', 'Expressive purple profile for visual and digital work.', Color(0xFF7747A8), layout: 'split'),
  ResumeTemplateOption('ats_compact', 'ATS Compact', 'Maximum scanability with compact, high-contrast sections.', Color(0xFF3C4654), layout: 'ats'),
];
