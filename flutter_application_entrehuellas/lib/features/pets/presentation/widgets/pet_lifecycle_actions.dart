import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/origin_dialog_transition.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../view_models/pet_lifecycle_view_model.dart';
import '../view_models/pet_list_view_model.dart';

class PetLifecycleActions extends ConsumerWidget {
  const PetLifecycleActions({required this.pet, super.key});
  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(petLifecycleViewModelProvider(pet.id));
    final label = pet.isArchived ? 'Restaurar mascota' : 'Archivar mascota';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pet.isArchived) ...[
          const Text(
            'Archivada. Su ficha y fotos se conservan.',
            style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
          ),
          const SizedBox(height: 12),
        ],
        LoadingShimmer(
          isLoading: state.busy,
          loadingLabel: pet.isArchived
              ? 'Restaurando mascota'
              : 'Archivando mascota',
          child: OutlinedButton.icon(
            onPressed: state.busy
                ? null
                : () async {
                    if (!pet.isArchived) {
                      final confirmed = await _confirmArchive(context, pet);
                      if (!confirmed || !context.mounted) return;
                    }
                    await ref
                        .read(petLifecycleViewModelProvider(pet.id).notifier)
                        .change(pet);
                  },
            icon: Icon(
              pet.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            label: Text(label, textAlign: TextAlign.center),
          ),
        ),
        if (state.issue != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(switch (state.issue!) {
              PetFailureKind.activeCase =>
                'Resuelve o cancela el caso activo antes de archivar.',
              PetFailureKind.conflict =>
                'La ficha cambió. Actualízala antes de continuar.',
              PetFailureKind.missing => 'Esta mascota ya no está disponible.',
              _ => 'No se pudo completar la acción. Puedes reintentar.',
            }, style: const TextStyle(fontSize: 16, color: Color(0xFFB53F48))),
          ),
          if (state.issue == PetFailureKind.conflict)
            TextButton(
              onPressed: () => ref
                  .read(petDetailViewModelProvider(pet.id).notifier)
                  .reload(),
              child: const Text('Actualizar ficha'),
            ),
        ],
      ],
    );
  }
}

Future<bool> _confirmArchive(BuildContext context, Pet pet) async =>
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          OriginDialogTransition(animation: animation, child: child),
      pageBuilder: (context, animation, secondaryAnimation) => Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: 'Confirmar archivo de mascota',
        explicitChildNodes: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Archivar mascota?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${pet.fields.name} pasará a Archivadas. Su ficha y fotos se conservarán y podrás restaurarla.',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Archivar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ??
    false;
