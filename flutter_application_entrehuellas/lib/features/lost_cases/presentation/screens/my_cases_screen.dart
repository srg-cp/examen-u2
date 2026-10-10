import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../view_models/case_read_view_model.dart';
import '../widgets/case_screen_shell.dart';

class MyCasesScreen extends ConsumerWidget {
  const MyCasesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myCasesViewModelProvider);
    final model = ref.read(myCasesViewModelProvider.notifier);
    return CaseScreenShell(
      title: 'Mis casos',
      loading: state.isLoading,
      child: state.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : state.hasError
          ? Column(
              children: [
                const Text('No pudimos consultar tus casos.'),
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.requireValue.refreshing)
                  const LinearProgressIndicator(minHeight: 2),
                if (state.requireValue.refreshFailed)
                  const Text(
                    'No pudimos actualizar. Se conserva la última consulta.',
                    style: TextStyle(color: Color(0xFFB53F48)),
                  ),
                if (state.requireValue.cases.isEmpty)
                  const Text(
                    'Todavía no has publicado casos de mascotas perdidas.',
                  ),
                for (final item in state.requireValue.cases)
                  StaggerRevealItem(
                    order: state.requireValue.cases.indexOf(item),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.petName.isEmpty ? 'Mascota perdida' : item.petName,
                      ),
                      subtitle: Text(
                        item.status == 'active'
                            ? 'Búsqueda activa'
                            : 'Caso resuelto',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/home/cases/${item.id}'),
                    ),
                  ),
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Volver a consultar'),
                ),
                FilledButton(
                  style: primaryActionButtonStyle(context),
                  onPressed: () => context.push('/home/lost-cases/new'),
                  child: const Text('Reportar mascota perdida'),
                ),
              ],
            ),
    );
  }
}
