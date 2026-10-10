import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PaperButton extends StatelessWidget {
  const PaperButton({super.key, required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    ),
  );
}
