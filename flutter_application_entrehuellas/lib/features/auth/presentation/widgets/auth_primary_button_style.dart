import 'package:flutter/material.dart';

/// Shared dimensions and typography for credential form actions.
ButtonStyle authPrimaryButtonStyle(BuildContext context) =>
    FilledButton.styleFrom(
      backgroundColor: const Color(0xFF24282A),
      minimumSize: const Size(double.infinity, 60),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
