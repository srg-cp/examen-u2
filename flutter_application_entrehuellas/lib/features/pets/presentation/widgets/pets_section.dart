import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import 'pet_registration_button.dart';
import '../view_models/pet_list_view_model.dart';
import 'pet_load_feedback.dart';
import 'pet_card_content.dart';
import 'pet_skeleton.dart';
import '../../domain/failures/pet_failure.dart';
import 'swipe_pet_card.dart';
import 'pet_deletion_dialog.dart';
import '../view_models/pet_deletion_view_model.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';

class PetsSection extends ConsumerStatefulWidget {
  const PetsSection({super.key});
  @override
  ConsumerState<PetsSection> createState() => _PetsSectionState();
}

class _PetsSectionState extends ConsumerState<PetsSection> {
  bool _sawSkeleton = false;
  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petListViewModelProvider);
    final deletion = ref.watch(petDeletionViewModelProvider);
    final showData =
        pets.hasValue &&
        !pets.hasError &&
        (!pets.isLoading || pets.isRefreshing);
    final loading = pets.isLoading && !showData;
    _sawSkeleton |= loading;
    return ConfirmationToastHost(
      confirmed: deletion.confirmed || deletion.issue != null,
      noticeId: deletion.noticeId,
      isError: deletion.issue != null,
      message: deletion.issue == null
          ? 'Mascota eliminada'
          : deletion.issue == PetFailureKind.conflict
          ? 'La ficha cambió. Actualiza la lista antes de eliminarla.'
          : 'No se pudo eliminar la mascota. Desliza para reintentar.',
      actionLabel: deletion.issue == PetFailureKind.conflict
          ? 'Actualizar lista'
          : null,
      onAction: deletion.issue == PetFailureKind.conflict
          ? () => ref.read(petListViewModelProvider.notifier).reload()
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaggerRevealItem(
            order: 0,
            child: _PetsHeader(
              hasPets: showData && pets.requireValue.isNotEmpty,
            ),
          ),
          const SizedBox(height: 24),
          StaggerRevealItem(
            order: 1,
            enabled: !_sawSkeleton,
            child: PetRefreshProgress(
              refreshing: showData && pets.isLoading,
              child: pets.isLoading && !showData
                  ? const PetSkeleton()
                  : pets.hasError
                  ? PetLoadFeedback(
                      error: pets.error,
                      onRetry: () =>
                          ref.read(petListViewModelProvider.notifier).reload(),
                    )
                  : pets.requireValue.isEmpty
                  ? const _PetsEmptyState()
                  : Column(
                      children: [
                        for (final pet in pets.requireValue)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SwipePetCard(
                                  key: ValueKey(pet.id),
                                  busy: deletion.busyId == pet.id,
                                  disabled: deletion.busyId != null,
                                  onOpen: () =>
                                      context.push('/home/pets/${pet.id}'),
                                  onDelete: (origin) async {
                                    if (await confirmPetDeletion(
                                          context,
                                          pet.fields.name,
                                          origin: origin,
                                          source: PetCardContent(pet: pet),
                                        ) &&
                                        context.mounted) {
                                      await ref
                                          .read(
                                            petDeletionViewModelProvider
                                                .notifier,
                                          )
                                          .delete(pet);
                                    }
                                  },
                                  contentBuilder: (foreground, secondary) =>
                                      PetCardContent(
                                        pet: pet,
                                        foreground: foreground,
                                        secondary: secondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetsHeader extends StatelessWidget {
  const _PetsHeader({required this.hasPets});
  final bool hasPets;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const title = Text(
        'Mis mascotas',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111111),
        ),
      );
      const action = PetRegistrationButton(compact: true);
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(32) > 42) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            if (hasPets) ...[
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerRight, child: action),
            ],
          ],
        );
      }
      return Row(
        children: [
          const Expanded(child: title),
          const SizedBox(width: 12),
          hasPets ? action : const SizedBox.square(dimension: 56),
        ],
      );
    },
  );
}

class _PetsEmptyState extends StatelessWidget {
  const _PetsEmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const ExcludeSemantics(
          child: Icon(Icons.pets_outlined, size: 88, color: Color(0xFF6E6E73)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Aún no tienes mascotas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Registra a tu mascota para tener su información a mano.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: const PetRegistrationButton(),
        ),
      ],
    ),
  );
}
