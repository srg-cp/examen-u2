import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/failures/preference_failure.dart';
import '../state/preference_view_state.dart';
import '../view_models/alert_preferences_view_model.dart';

class PreferenceOptions extends ConsumerWidget {
  const PreferenceOptions({super.key, required this.state});
  final PreferenceViewState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(alertPreferencesViewModelProvider.notifier);
    final choices = state.draft;
    Widget toggle(
      String label,
      String description,
      bool value,
      void Function(bool) change,
    ) => SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
      ),
      value: value,
      onChanged: state.busy ? null : change,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerRevealItem(
          order: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Elige qué avisos quieres recibir. Puedes pausarlos sin perder tu selección.',
                style: TextStyle(fontSize: 18, color: Color(0xFF6E6E73)),
              ),
              const SizedBox(height: 12),
              toggle(
                'Recibir alertas',
                'Desactiva para pausar todos los tipos y canales.',
                choices.enabled,
                (value) => vm.edit(enabled: value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tipos de aviso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              toggle(
                'Mascotas perdidas',
                'Nuevos casos en tus zonas de interés.',
                choices.lostPets,
                (value) => vm.edit(lostPets: value),
              ),
              toggle(
                'Mascotas encontradas',
                'Mascotas encontradas en tus zonas de interés.',
                choices.foundPets,
                (value) => vm.edit(foundPets: value),
              ),
              toggle(
                'Novedades de casos',
                'Avistamientos y cierre de los casos que sigues.',
                choices.caseUpdates,
                (value) => vm.edit(caseUpdates: value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Canales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              toggle(
                'Bandeja de la app',
                'Consultar avisos dentro de Entre Huellas.',
                choices.inApp,
                (value) => vm.edit(inApp: value),
              ),
              toggle(
                'Notificaciones del teléfono',
                'Preferencia para recibir avisos fuera de la app.',
                choices.push,
                (value) => vm.edit(push: value),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guardaremos tu selección. La recepción en la bandeja y el teléfono se habilitará cuando estén disponibles las alertas.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF6E6E73),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        StaggerRevealItem(
          order: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.issue != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(switch (state.issue!) {
                    PreferenceFailureKind.invalidTypes =>
                      'Elige al menos un tipo de aviso o desactiva Recibir alertas.',
                    PreferenceFailureKind.invalidChannels =>
                      'Elige al menos un canal o desactiva Recibir alertas.',
                    PreferenceFailureKind.conflict =>
                      'Las preferencias cambiaron en otro dispositivo. Consulta la versión actual antes de volver a guardar.',
                    PreferenceFailureKind.signedOut =>
                      'Tu sesión cambió. Vuelve a ingresar para guardar.',
                    PreferenceFailureKind.unavailable =>
                      'No se pudo completar la operación. Tu selección se conserva; puedes reintentar.',
                  }, style: const TextStyle(fontSize: 16, color: Color(0xFFB53F48))),
                ),
                if (state.issue == PreferenceFailureKind.conflict)
                  TextButton(
                    onPressed: state.busy
                        ? null
                        : () async {
                            if (await confirmDiscardAction(
                              context,
                              '¿Consultar versión actual?',
                              'Se descartará la selección sin guardar.',
                              'Consultar',
                            )) {
                              if (context.mounted) {
                                vm.refresh(discardDraft: true);
                              }
                            }
                          },
                    child: const Text('Consultar versión actual'),
                  ),
                const SizedBox(height: 16),
              ],
              LoadingShimmer(
                isLoading: state.saving,
                loadingLabel: 'Guardando preferencias',
                child: FilledButton(
                  style: primaryActionButtonStyle(context),
                  onPressed:
                      !state.busy &&
                          state.dirty &&
                          state.issue != PreferenceFailureKind.conflict
                      ? vm.save
                      : null,
                  child: const Text('Guardar preferencias'),
                ),
              ),
              if (state.dirty)
                TextButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          if (await confirmDiscardAction(
                            context,
                            '¿Descartar cambios?',
                            'Tu selección sin guardar se perderá.',
                            'Descartar',
                          )) {
                            if (context.mounted) vm.discard();
                          }
                        },
                  child: const Text('Descartar cambios'),
                ),
              TextButton.icon(
                onPressed: state.busy
                    ? null
                    : () async {
                        if (!state.dirty ||
                            await confirmDiscardAction(
                              context,
                              '¿Consultar versión actual?',
                              'Se descartará la selección sin guardar.',
                              'Consultar',
                            )) {
                          if (context.mounted) vm.refresh(discardDraft: true);
                        }
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualizar preferencias'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
