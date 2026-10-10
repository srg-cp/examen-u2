import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_field_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/failures/profile_failure.dart';
import '../state/profile_edit_state.dart';
import '../view_models/profile_view_model.dart';

class ProfileEditor extends ConsumerWidget {
  const ProfileEditor({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileViewModelProvider);
    if (profile.isLoading && !profile.hasError) {
      return const LoadingShimmer(
        isLoading: true,
        loadingLabel: 'Cargando tu perfil',
        radius: 22,
        child: SkeletonFormFields(fieldCount: 3),
      );
    }
    if (profile.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              'No se pudo cargar tu perfil. Reintenta.',
              style: TextStyle(fontSize: 16, color: Color(0xFFB53F48)),
            ),
          ),
          const SizedBox(height: 16),
          LoadingShimmer(
            isLoading: profile.isLoading,
            loadingLabel: 'Cargando perfil',
            child: OutlinedButton(
              style: primaryActionButtonStyle(context).copyWith(
                backgroundColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                foregroundColor: const WidgetStatePropertyAll(
                  Color(0xFF111111),
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: Color(0xFFE5E5EA)),
                ),
              ),
              onPressed: profile.isLoading
                  ? null
                  : () => ref.read(profileViewModelProvider.notifier).retry(),
              child: const Text('Reintentar'),
            ),
          ),
        ],
      );
    }
    final value = profile.requireValue;
    final model = ref.read(profileViewModelProvider.notifier);
    return ConfirmationToastHost(
      key: ValueKey(value.profile.userId),
      confirmed: value.saved,
      message: 'Cambios guardados',
      child: _ProfileFields(
        value: value,
        onEdit: model.edit,
        onSave: model.save,
        onDiscard: model.discard,
      ),
    );
  }
}

class _ProfileFields extends StatefulWidget {
  const _ProfileFields({
    required this.value,
    required this.onEdit,
    required this.onSave,
    required this.onDiscard,
  });
  final ProfileEditState value;
  final void Function({String? displayName, String? city}) onEdit;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  @override
  State<_ProfileFields> createState() => _ProfileFieldsState();
}

class _ProfileFieldsState extends State<_ProfileFields> {
  late final _name = TextEditingController(text: widget.value.displayName);
  late final _city = TextEditingController(text: widget.value.city);
  @override
  void didUpdateWidget(_ProfileFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final pair in [
      (_name, widget.value.displayName),
      (_city, widget.value.city),
    ]) {
      if (pair.$1.text != pair.$2) {
        pair.$1.value = TextEditingValue(
          text: pair.$2,
          selection: TextSelection.collapsed(offset: pair.$2.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.value;
    final nameError = state.issue == ProfileFailureKind.invalidName;
    final cityError = state.issue == ProfileFailureKind.invalidCity;
    const errorColor = Color(0xFFB53F48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldSurface(
          label: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          child: Semantics(
            label: 'Correo electrónico',
            child: SelectableText(
              state.profile.email ?? 'Correo no disponible',
              style: const TextStyle(
                fontSize: 16,
                height: 27 / 16,
                color: Color(0xFF6E6E73),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: nameError,
          child: AppTextField(
            label: 'Nombre',
            controller: _name,
            enabled: !state.isBusy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            hint: 'Tu nombre',
            icon: Icons.person_outline_rounded,
            errorText: nameError ? 'Usa hasta 120 caracteres.' : null,
            onChanged: (value) => widget.onEdit(displayName: value),
          ),
        ),
        const SizedBox(height: 20),
        ShakeField(
          errorId: state.errorId,
          hasError: cityError,
          child: AppTextField(
            label: 'Ciudad',
            controller: _city,
            enabled: !state.isBusy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.addressCity],
            hint: 'Tu ciudad',
            icon: Icons.location_city_outlined,
            errorText: cityError ? 'Usa hasta 120 caracteres.' : null,
            onChanged: (value) => widget.onEdit(city: value),
            onSubmitted: (_) {
              if (state.isDirty && !state.isBusy) widget.onSave();
            },
          ),
        ),
        const SizedBox(height: 24),
        LoadingShimmer(
          isLoading: state.isBusy,
          loadingLabel: 'Guardando perfil',
          child: FilledButton(
            style: primaryActionButtonStyle(context, isLoading: state.isBusy),
            onPressed: state.isBusy || !state.isDirty ? null : widget.onSave,
            child: const Text('Guardar cambios'),
          ),
        ),
        if (state.issue != null && !nameError && !cityError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(switch (state.issue) {
                ProfileFailureKind.signedOut =>
                  'Tu sesión cambió. Vuelve a ingresar.',
                ProfileFailureKind.missing =>
                  'Tu perfil no está disponible. Reintenta.',
                ProfileFailureKind.forbidden =>
                  'No se pudo guardar tu perfil. Reintenta.',
                _ =>
                  'No se pudo guardar. Conservamos tus cambios para reintentar.',
              }, style: const TextStyle(fontSize: 16, color: errorColor)),
            ),
          ),
        if (state.isDirty)
          TextButton(
            onPressed: state.isBusy ? null : widget.onDiscard,
            child: const Text('Descartar cambios'),
          ),
      ],
    );
  }
}
