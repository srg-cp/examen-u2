import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/case_read_view_model.dart';
import '../widgets/case_screen_shell.dart';
import '../widgets/case_public_content.dart';

class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publicCaseViewModelProvider(id));
    final model = ref.read(publicCaseViewModelProvider(id).notifier);
    return CaseScreenShell(
      title: 'Ficha pública',
      loading: state.isLoading,
      child: state.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : state.hasError
          ? Column(
              children: [
                const Text('No pudimos consultar el caso.'),
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : state.requireValue.value == null
          ? const Text('Este caso no está disponible públicamente.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.requireValue.refreshing)
                  const LinearProgressIndicator(minHeight: 2),
                const StaggerRevealItem(
                  order: 0,
                  child: Text('Búsqueda activa'),
                ),
                if (state.requireValue.refreshFailed)
                  const Text(
                    'No pudimos actualizar. Se conserva la última consulta.',
                    style: TextStyle(color: Color(0xFFB53F48)),
                  ),
                const SizedBox(height: 16),
                StaggerRevealItem(
                  order: 1,
                  child: CasePublicContent(value: state.requireValue.value!),
                ),
                TextButton(
                  onPressed: state.requireValue.refreshing ? null : model.retry,
                  child: const Text('Volver a consultar'),
                ),
              ],
            ),
    );
  }
}
