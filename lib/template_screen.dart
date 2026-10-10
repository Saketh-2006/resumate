import 'package:flutter/material.dart';

import 'resume_data.dart';
import 'resume_templates.dart';

class TemplateScreen extends StatefulWidget {
  final ResumeData resumeData;

  const TemplateScreen({super.key, required this.resumeData});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  late String _selected;
  int? _selectedAccent;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _selected = widget.resumeData.templateId;
    _selectedAccent = widget.resumeData.customAccentColor;
    _fontScale = widget.resumeData.fontScale;
  }

  Color get _selectedColor {
    final template = resumeTemplates.firstWhere(
      (item) => item.id == _selected,
      orElse: () => resumeTemplates.first,
    );
    return Color(_selectedAccent ?? template.color.toARGB32());
  }

  void _preview() {
    widget.resumeData.templateId = _selected;
    widget.resumeData.customAccentColor = _selectedAccent;
    widget.resumeData.fontScale = _fontScale;
    Navigator.pop(context);
  }

  Future<void> _customize() async {
    final template = resumeTemplates.firstWhere(
      (item) => item.id == _selected,
      orElse: () => resumeTemplates.first,
    );
    final result = await showModalBottomSheet<(int?, double)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        int? accent = _selectedAccent;
        var scale = _fontScale;
        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customize your style', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 18),
                  Text('Accent color', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: [
                      ...const [
                        Color(0xFF4559B8), Color(0xFF176B87), Color(0xFF287A63),
                        Color(0xFF7D43A3), Color(0xFFC05B45), Color(0xFF374151),
                      ].map((color) => IconButton(
                            tooltip: 'Choose accent color',
                            onPressed: () => setSheetState(() => accent = color.toARGB32()),
                            icon: CircleAvatar(
                              backgroundColor: color,
                              child: accent == color.toARGB32()
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          )),
                      IconButton(
                        tooltip: 'Use template default color',
                        onPressed: () => setSheetState(() => accent = null),
                        icon: CircleAvatar(
                          backgroundColor: template.color,
                          child: accent == null ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Text size', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(value: .9, label: Text('Compact')),
                      ButtonSegment(value: 1.0, label: Text('Standard')),
                      ButtonSegment(value: 1.1, label: Text('Large')),
                    ],
                    selected: {scale},
                    onSelectionChanged: (values) => setSheetState(() => scale = values.first),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, (accent, scale)),
                      child: const Text('Apply customization'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedAccent = result.$1;
        _fontScale = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a resume style')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                  child: Text(
                    'Choose a layout. You can change it later.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 760
                          ? 3
                          : constraints.maxWidth > 500
                              ? 2
                              : 1;
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: constraints.maxWidth < 500 ? 2.1 : 1.25,
                        ),
                        itemCount: resumeTemplates.length,
                        itemBuilder: (context, index) {
                          final item = resumeTemplates[index];
                          final selected = item.id == _selected;
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => setState(() => _selected = item.id),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: selected ? 3 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: selected
                                      ? (item.id == _selected ? _selectedColor : item.color)
                                      : Theme.of(context).colorScheme.outlineVariant,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    _MiniResumePreview(
                                      color: item.id == _selected ? _selectedColor : item.color,
                                      layout: item.layout,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(item.description),
                                          if (item.id == _selected &&
                                              (_selectedAccent != null || _fontScale != 1.0))
                                            Text(
                                              'Customized · ${_fontScale == 1.0 ? 'Standard' : _fontScale < 1 ? 'Compact' : 'Large'} text',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _selectedColor),
                                            ),
                                          const SizedBox(height: 8),
                                          if (selected)
                                            Row(
                                              children: [
                                                Icon(Icons.check_circle, color: _selectedColor, size: 18),
                                                const SizedBox(width: 6),
                                                Text('Selected', style: TextStyle(color: _selectedColor)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _customize,
                          icon: const Icon(Icons.tune),
                          label: const Text('Customize'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _preview,
                            child: const Text('Use this template'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniResumePreview extends StatelessWidget {
  final Color color;
  final String layout;

  const _MiniResumePreview({required this.color, required this.layout});

  @override
  Widget build(BuildContext context) => Container(
        width: 84,
        height: 114,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E5EC)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: _layoutPreview(),
      );

  Widget _layoutPreview() {
    Widget line(double width, {double height = 2, Color? color}) => Container(
          width: width,
          height: height,
          color: color ?? const Color(0xFFE4E7ED),
        );

    Widget lines() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            line(56, height: 4, color: color),
            const SizedBox(height: 7),
            line(60, height: 2, color: const Color(0xFFCBD0D9)),
            const SizedBox(height: 8),
            for (var i = 0; i < 5; i++) ...[
              line(i.isEven ? 62 : 47),
              const SizedBox(height: 5),
            ],
          ],
        );

    if (layout == 'sidebar') {
      return Row(
        children: [
          Container(width: 20, height: 94, color: color),
          const SizedBox(width: 7),
          Expanded(child: lines()),
        ],
      );
    }
    if (layout == 'banner') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 25, width: double.infinity, color: color),
          const SizedBox(height: 8),
          line(58, height: 3, color: const Color(0xFFCBD0D9)),
          const SizedBox(height: 8),
          line(58),
          const SizedBox(height: 5),
          line(44),
          const SizedBox(height: 8),
          line(58, color: color.withValues(alpha: .45)),
          const SizedBox(height: 5),
          line(48),
        ],
      );
    }
    if (layout == 'centered') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: line(42, height: 5, color: color)),
          const SizedBox(height: 5),
          Center(child: line(58, height: 2, color: const Color(0xFFCBD0D9))),
          const SizedBox(height: 7),
          line(58, color: color.withValues(alpha: .45)),
          const SizedBox(height: 7),
          line(58),
          const SizedBox(height: 5),
          line(45),
          const SizedBox(height: 5),
          line(58),
        ],
      );
    }
    if (layout == 'split') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [line(38, height: 5, color: color), const SizedBox(height: 7), line(38), const SizedBox(height: 5), line(30)],
            ),
          ),
          const SizedBox(width: 5),
          Container(width: 2, height: 86, color: color.withValues(alpha: .45)),
          const SizedBox(width: 5),
          Expanded(child: lines()),
        ],
      );
    }
    if (layout == 'editorial') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(52, height: 6, color: color),
          const SizedBox(height: 4),
          Container(width: 64, height: 1, color: color),
          const SizedBox(height: 9),
          line(58, color: const Color(0xFFCBD0D9)),
          const SizedBox(height: 7),
          for (var i = 0; i < 5; i++) ...[
            line(i.isEven ? 62 : 47),
            const SizedBox(height: 5),
          ],
        ],
      );
    }
    return lines();
  }
}
