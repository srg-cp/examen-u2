import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/pet_photo.dart';
import '../view_models/pet_photos_view_model.dart';

class PetPhotoGallery extends ConsumerStatefulWidget {
  const PetPhotoGallery({
    required this.petId,
    required this.existing,
    this.editable = false,
    this.locked = false,
    this.tileSize = 112,
    super.key,
  });
  final String petId;
  final bool existing;
  final bool editable;
  final bool locked;
  final double tileSize;
  @override
  ConsumerState<PetPhotoGallery> createState() => _PetPhotoGalleryState();
}

class _PetPhotoGalleryState extends ConsumerState<PetPhotoGallery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(petPhotosViewModelProvider(widget.petId).notifier)
            .ensureInitialized(widget.existing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(petPhotosViewModelProvider(widget.petId));
    final model = ref.read(petPhotosViewModelProvider(widget.petId).notifier);
    final disabled = widget.locked || state.busy || state.loading;
    if (!widget.editable &&
        !state.loading &&
        state.photos.isEmpty &&
        state.pending.isEmpty &&
        state.issue == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.editable) ...[
          const Text(
            'Fotos',
            style: TextStyle(fontSize: 16, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 8),
        ],
        LoadingShimmer(
          isLoading: state.busy || state.loading,
          loadingLabel: state.loading
              ? 'Consultando fotos'
              : 'Preparando fotos',
          radius: 22,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (state.loading)
                  for (var i = 0; i < 2; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: widget.tileSize,
                        height: widget.tileSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5EA),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                for (final photo in state.photos)
                  _tile(
                    id: photo.id,
                    child: photo.uri == null
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFF6E6E73),
                            ),
                          )
                        : Image.network(
                            photo.uri.toString(),
                            width: widget.tileSize,
                            height: widget.tileSize,
                            fit: BoxFit.cover,
                            cacheWidth:
                                (widget.tileSize *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .ceil(),
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF6E6E73),
                              ),
                            ),
                          ),
                    remove: widget.editable && !disabled
                        ? () => model.remove(photo.id, true)
                        : null,
                    pending: !photo.ready,
                  ),
                for (final draft in state.pending)
                  _tile(
                    id: draft.id,
                    child: Image.memory(
                      draft.bytes,
                      width: widget.tileSize,
                      height: widget.tileSize,
                      fit: BoxFit.cover,
                      cacheWidth:
                          (widget.tileSize *
                                  MediaQuery.devicePixelRatioOf(context))
                              .ceil(),
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                    remove: widget.editable && !disabled
                        ? () => model.remove(draft.id, widget.existing)
                        : null,
                  ),
                if (widget.editable &&
                    state.photos.length + state.pending.length < 3)
                  Material(
                    color: const Color(0xFFF5F5F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: Color(0xFFE5E5EA)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: disabled
                          ? null
                          : () => model.choose(widget.existing),
                      child: SizedBox(
                        width: widget.tileSize,
                        height: widget.tileSize,
                        child: Semantics(
                          label: 'Añadir foto de mascota',
                          button: true,
                          child: Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 30,
                              color: Color(0xFF6E6E73),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (state.recovered)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Foto recuperada. Guarda para añadirla.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E6E73)),
            ),
          ),
        if (state.issue != null) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(switch (state.issue!) {
              PetPhotoFailureKind.invalidPhoto => 'Elige una imagen válida.',
              PetPhotoFailureKind.galleryUnavailable =>
                'No se pudo abrir la galería. Inténtalo de nuevo.',
              PetPhotoFailureKind.limit => 'Puedes añadir hasta tres fotos.',
              _ =>
                state.pending.isEmpty
                    ? 'No se pudieron consultar las fotos.'
                    : 'No se pudieron guardar las fotos. Reintenta al guardar.',
            }, style: const TextStyle(fontSize: 14, color: Color(0xFFB53F48))),
          ),
          if (state.pending.isEmpty &&
              state.issue == PetPhotoFailureKind.unavailable)
            TextButton(
              onPressed: disabled
                  ? null
                  : () => model.initialize(widget.existing),
              child: const Text('Reintentar consulta'),
            ),
        ],
      ],
    );
  }

  Widget _tile({
    required String id,
    required Widget child,
    VoidCallback? remove,
    bool pending = false,
  }) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: widget.tileSize,
        height: widget.tileSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: const Color(0xFFF5F5F7), child: child),
            if (pending)
              const Align(
                alignment: Alignment.bottomCenter,
                child: ColoredBox(
                  color: Color(0xD924282A),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Pendiente',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ),
            if (remove != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'Quitar foto',
                  onPressed: remove,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xD924282A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
