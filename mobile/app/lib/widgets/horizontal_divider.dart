import 'package:flutter/material.dart';

class HorizontalDivider extends StatelessWidget {
  final String text;

  const HorizontalDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}
