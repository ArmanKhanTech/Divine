import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final BorderRadius? borderRadius;
  final bool elevated;
  final Function()? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.elevated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Theme.of(context).colorScheme.surface),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
