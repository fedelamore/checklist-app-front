import 'package:flutter/material.dart';

class ChecklistProgressBar extends StatelessWidget {
  const ChecklistProgressBar({super.key, required this.progress, this.label});

  final double progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: textTheme.titleSmall),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress.clamp(0, 1),
          ),
        ),
      ],
    );
  }
}
