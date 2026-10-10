import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Content loading never renders a loading text or circular indicator', () {
    final visibleLoading = RegExp(
      r'''\bText\s*\(\s*(?:\w+\s*\?\s*)?['"](?:Cargando|Preparando)\b''',
    );
    final circular = RegExp(r'\bCircularProgressIndicator\b');
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final code = file.readAsStringSync();
      if (visibleLoading.hasMatch(code) || circular.hasMatch(code)) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Use content skeletons or retained content with top progress; accessible labels remain allowed.',
    );
  });
  test('UI loading labels never end in suspension dots', () {
    final literals = RegExp(r''''(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"''');
    final dots = RegExp(r'(?:…|\.\.\.)\s*$');
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') ||
          !file.path.replaceAll('\\', '/').contains('/presentation/')) {
        continue;
      }
      for (final match in literals.allMatches(file.readAsStringSync())) {
        final literal = match.group(0)!;
        if (dots.hasMatch(literal.substring(1, literal.length - 1))) {
          violations.add(file.path);
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Loading uses LoadingShimmer with stable labels: $violations',
    );
  });
  test('Project UI never uses SnackBar or its display APIs', () {
    final forbidden = RegExp(
      r'\b(?:SnackBar|SnackBarAction|SnackBarBehavior|showSnackBar|hideCurrentSnackBar|removeCurrentSnackBar|snackbar)\b',
    );
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (file.path.endsWith('.dart') &&
          forbidden.hasMatch(file.readAsStringSync())) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Forbidden notification component: ${violations.join(', ')}',
    );
  });
  test('Layers respect dependency direction and SDKs stay in data sources', () {
    final violations = <String>[];
    final directives = RegExp(r'''(?:import|export|part)\s+(?!of\b)([^;]+);''');
    final uris = RegExp(r'''['"]([^'"]+)['"]''');
    final appRoot = Directory('lib').absolute.path.replaceAll('\\', '/');
    for (final file in Directory(
      'lib/features',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final path = file.absolute.path.replaceAll('\\', '/');
      final isDomain = path.contains('/domain/');
      final isPresentation = path.contains('/presentation/');
      final isData = path.contains('/data/');
      final isProvider = path.contains('/providers/');
      for (final match
          in directives
              .allMatches(file.readAsStringSync())
              .expand((directive) => uris.allMatches(directive.group(1)!))) {
        final imported = match.group(1)!;
        if (imported.startsWith('dart:')) {
          if (isDomain &&
              ['dart:io', 'dart:ui', 'dart:ffi'].contains(imported)) {
            violations.add('${file.path} -> $imported');
          }
          continue;
        }
        final String target;
        if (imported.startsWith('package:flutter_application_entrehuellas/')) {
          target =
              '$appRoot/${imported.substring('package:flutter_application_entrehuellas/'.length)}';
        } else if (imported.startsWith('package:')) {
          final isDataSdk = RegExp(
            r'^package:(supabase|gotrue|postgrest|storage_client|realtime_client|http|drift|sqflite|image_picker|image/|shared_preferences|cross_file)',
          ).hasMatch(imported);
          if (isDomain ||
              (isDataSdk && !path.contains('/data/data_sources/')) ||
              (isData && imported.startsWith('package:flutter/'))) {
            violations.add('${file.path} -> $imported');
          }
          continue;
        } else {
          target = file.absolute.uri
              .resolve(imported)
              .toFilePath()
              .replaceAll('\\', '/');
        }
        if ((isDomain && !target.contains('/domain/')) ||
            (isPresentation &&
                (target.contains('/data/') ||
                    target.contains('/app/') ||
                    target.contains('/domain/repositories/'))) ||
            (isData &&
                (target.contains('/presentation/') ||
                    target.contains('/providers/') ||
                    target.contains('/app/'))) ||
            (isProvider &&
                (target.contains('/data/') ||
                    target.contains('/presentation/') ||
                    target.contains('/app/')))) {
          violations.add('${file.path} -> $imported');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
