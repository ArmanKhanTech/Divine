import 'package:flutter/material.dart';

class CommomUtility {
  InputBorder border(BuildContext context) {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20.0),
      ),
      borderSide: BorderSide(
        color: Colors.white,
        width: 0.0,
      ),
    );
  }

  InputBorder focusBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(20.0),
      ),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 1.0,
      ),
    );
  }
}
