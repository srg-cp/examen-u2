import '../../../../core/presentation/widgets/shake_field.dart';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../domain/entities/lost_case.dart';
import '../state/case_editor_state.dart';
import '../view_models/case_editor_view_model.dart';
import '../widgets/case_public_content.dart';
import '../widgets/case_screen_shell.dart';

class CaseEditorScreen extends ConsumerStatefulWidget {
  const CaseEditorScreen({super.key});
  @override
  ConsumerState<CaseEditorScreen> createState() => _CaseEditorScreenState();
}

class _CaseEditorScreenState extends ConsumerState<CaseEditorScreen> {
  final _place = TextEditingController(),
      _lat = TextEditingController(),
      _lon = TextEditingController();
  bool _leaving = false, _canPop = false;
  @override
  void dispose() {
    _place.dispose();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final value = ref.read(caseEditorViewModelProvider).asData?.value;
    if (_leaving || value?.busy == true) return;
    _leaving = true;
    final leave =
        value?.dirty != true ||
        await confirmDiscardAction(
          context,
          '¿Salir del reporte?',
          value?.lockedDraft != null
              ? 'El envío pudo haber llegado al servidor. Consulta Mis casos antes de publicar otra vez.'
              : 'Se descartarán los datos que todavía no publicaste.',
          'Salir',
        );
    _leaving = false;
    if (!mounted || !leave) return;
    setState(() => _canPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _chooseTime(CaseEditorState value) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: value.occurredAt ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (!mounted || day == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value.occurredAt ?? now),
    );
    if (!mounted || time == null) return;
    ref
        .read(caseEditorViewModelProvider.notifier)
        .edit(
          occurredAt: DateTime(
            day.year,
            day.month,
            day.day,
            time.hour,
            time.minute,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(caseEditorViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.ownerId != next.asData?.value.ownerId) {
        _place.clear();
        _lat.clear();
        _lon.clear();
      }
    });
    final async = ref.watch(caseEditorViewModelProvider),
        value = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(caseEditorViewModelProvider.notifier);
    return PopScope(
      canPop: _canPop || (value?.dirty != true && value?.busy != true),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'Mascota perdida',
        loading: async.isLoading,
        stage: value?.stage ?? 'initial',
        onBack: _leave,
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 4)
            : async.hasError
            ? Column(
                children: [
                  const Text(
                    'No pudimos consultar tus mascotas. Revisa tu conexión y sesión.',
                  ),
                  TextButton(
                    onPressed: model.retry,
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            : value == null
            ? const SizedBox.shrink()
            : _content(value, model),
      ),
    );
  }

  Widget _shake(CaseEditorState value, CaseField field, Widget child) =>
      ShakeField(
        errorId: value.errorId,
        hasError: value.invalidFields.contains(field),
        child: child,
      );
  Widget _content(CaseEditorState value, CaseEditorViewModel model) {
    if (value.stage == CaseEditorStage.confirmed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StaggerRevealItem(
            order: 0,
            child: Text(
              'Caso publicado',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'La búsqueda está activa. Tu punto exacto permanece privado.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: primaryActionButtonStyle(context),
            onPressed: () =>
                context.pushReplacement('/home/cases/${value.published!.id}'),
            child: const Text('Ver ficha pública'),
          ),
        ],
      );
    }
    if (value.stage == CaseEditorStage.preview) {
      final pet = value.pet!;
      final preview = PublicLostCase(
        id: value.draftId,
        status: 'active',
        occurredAt: value.occurredAt!,
        latitude: (value.latitude! * 100).floor() / 100 + .005,
        longitude: min(179.995, (value.longitude! * 100).floor() / 100 + .005),
        fields: pet.fields,
        photos: value.photos
            .where((p) => value.selectedPhotos.contains(p.id))
            .map((p) => CasePhoto(id: p.id, uri: p.uri))
            .toList(),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StaggerRevealItem(
            order: 0,
            child: Text(
              'Vista previa pública',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          StaggerRevealItem(order: 1, child: CasePublicContent(value: preview)),
          const Text(
            'Al publicar, los datos y fotos mostrados podrán consultarse públicamente. Revisa que los rasgos y fotos no contengan datos personales, domicilio ni documentos.',
          ),
          if (value.issue != null) ...[
            const SizedBox(height: 16),
            Text(
              caseFailureLabel(value.issue),
              style: const TextStyle(color: Color(0xFFB53F48)),
            ),
          ],
          if (value.lockedDraft != null) ...[
            const SizedBox(height: 12),
            const Text(
              'El envío conserva su identificador. Reintentar verifica la misma publicación sin duplicarla.',
            ),
            TextButton(
              onPressed: value.busy
                  ? null
                  : () => context.push('/home/my-cases'),
              child: const Text('Consultar Mis casos'),
            ),
          ],
          const SizedBox(height: 24),
          LoadingShimmer(
            isLoading: value.busy,
            loadingLabel: 'Publicando caso',
            child: FilledButton(
              style: primaryActionButtonStyle(context, isLoading: value.busy),
              onPressed: value.busy ? null : model.publish,
              child: const Text('Publicar caso'),
            ),
          ),
          TextButton(
            onPressed: value.busy || value.lockedDraft != null
                ? null
                : model.backToForm,
            child: const Text('Editar reporte'),
          ),
        ],
      );
    }
    if (value.pets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Primero registra una mascota y guarda sus fotos para publicar su búsqueda.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: primaryActionButtonStyle(context),
            onPressed: () => context.push('/home/pets/new'),
            child: const Text('Registrar mascota'),
          ),
          TextButton(
            onPressed: model.retry,
            child: const Text('Consultar mis mascotas'),
          ),
        ],
      );
    }
    final editable = !value.busy && !value.loadingPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerRevealItem(
          order: 0,
          child: _shake(
            value,
            CaseField.pet,
            AppSelectField<String>(
              label: 'Mascota',
              errorText: value.invalidFields.contains(CaseField.pet)
                  ? 'Elige una mascota.'
                  : null,
              value: value.pet?.id,
              options: value.pets
                  .map(
                    (p) => AppSelectOption(
                      value: p.id,
                      label: p.fields.name,
                      icon: Icons.pets_outlined,
                    ),
                  )
                  .toList(),
              onChanged: editable ? model.selectPet : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (value.pet != null) ...[
          if (value.pet!.activeCaseCount > 0)
            const Text(
              'Esta mascota ya tiene una búsqueda activa.',
              style: TextStyle(color: Color(0xFFB53F48)),
            ),
          if (value.loadingPhotos)
            const SkeletonFormFields(fieldCount: 1)
          else ...[
            const Text(
              'Elige las fotos que se mostrarán públicamente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            for (final photo in value.photos)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: value.selectedPhotos.contains(photo.id),
                onChanged: editable ? (_) => model.togglePhoto(photo.id) : null,
                title: Text(
                  photo.isPrimary
                      ? 'Foto principal'
                      : 'Foto ${value.photos.indexOf(photo) + 1}',
                ),
                subtitle: photo.uri == null
                    ? const Text('Vista de foto no disponible')
                    : Image.network(
                        photo.uri.toString(),
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Text('Vista de foto no disponible'),
                      ),
              ),
            if (value.invalidFields.contains(CaseField.photos))
              const Text(
                'Elige al menos una foto.',
                style: TextStyle(color: Color(0xFFB53F48)),
              ),
            if (value.photos.isEmpty)
              const Text('Esta mascota necesita fotos guardadas.'),
            TextButton(
              onPressed: () => context.push('/home/pets/${value.pet!.id}/edit'),
              child: const Text('Editar mascota y fotos'),
            ),
            TextButton(
              onPressed: editable ? () => model.selectPet(value.pet!.id) : null,
              child: const Text('Volver a consultar fotos'),
            ),
          ],
          const SizedBox(height: 20),
        ],
        StaggerRevealItem(
          order: 2,
          child: _shake(
            value,
            CaseField.date,
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: editable ? () => _chooseTime(value) : null,
              icon: const Icon(Icons.schedule),
              label: Text(
                value.occurredAt == null
                    ? 'Fecha y hora de desaparición'
                    : caseDateLabel(value.occurredAt!),
              ),
            ),
          ),
        ),
        if (value.invalidFields.contains(CaseField.date))
          const Text(
            'Elige fecha y hora desde el año 2000, sin superar la hora actual.',
            style: TextStyle(color: Color(0xFFB53F48)),
          ),
        const SizedBox(height: 20),
        const StaggerRevealItem(
          order: 3,
          child: Text(
            'Lugar de desaparición',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toca el mapa o escribe coordenadas. No necesitas dar permiso de ubicación. La referencia y el punto exacto son privados.',
        ),
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: 4,
          child: ZoneMapPicker(
            latitude: value.latitude,
            longitude: value.longitude,
            radiusMeters: 0,
            onSelect: editable
                ? (lat, lon) {
                    model.edit(latitude: lat, longitude: lon);
                    _lat.text = lat.toStringAsFixed(6);
                    _lon.text = lon.toStringAsFixed(6);
                  }
                : null,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Latitud',
          controller: _lat,
          enabled: editable,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Longitud',
          controller: _lon,
          enabled: editable,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
        TextButton(
          onPressed: editable
              ? () => model.chooseCoordinates(_lat.text, _lon.text)
              : null,
          child: const Text('Usar coordenadas'),
        ),
        if (value.invalidFields.contains(CaseField.point))
          const Text(
            'Elige un punto válido en el mapa o usa coordenadas.',
            style: TextStyle(color: Color(0xFFB53F48)),
          ),
        if (value.latitude != null)
          Text(
            'Punto seleccionado: ${value.latitude!.toStringAsFixed(6)}, ${value.longitude!.toStringAsFixed(6)}',
          ),
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: 5,
          child: _shake(
            value,
            CaseField.place,
            AppTextField(
              label: 'Referencia privada del lugar',
              errorText: value.invalidFields.contains(CaseField.place)
                  ? 'Escribe una referencia de hasta 120 caracteres.'
                  : null,
              controller: _place,
              enabled: editable,
              onChanged: (v) => model.edit(placeReference: v),
              maxLines: 3,
            ),
          ),
        ),
        if (value.issue != null) ...[
          const SizedBox(height: 16),
          Text(
            caseFailureLabel(value.issue),
            style: const TextStyle(color: Color(0xFFB53F48)),
          ),
        ],
        const SizedBox(height: 24),
        StaggerRevealItem(
          order: 6,
          child: FilledButton(
            style: primaryActionButtonStyle(context),
            onPressed: editable ? model.preview : null,
            child: const Text('Revisar publicación'),
          ),
        ),
        TextButton(
          onPressed: () => context.push('/home/my-cases'),
          child: const Text('Mis casos'),
        ),
      ],
    );
  }
}
