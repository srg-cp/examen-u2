import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/explore_case_preview.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import '../view_models/explore_case_preview_view_model.dart';

class ExploreMapCasePreview extends ConsumerWidget {
  const ExploreMapCasePreview({
    required this.item,
    this.scrollable = true,
    super.key,
  });
  final ExploreCase item;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = exploreCasePreviewViewModelProvider(item);
    final state = ref.watch(provider);
    return ConfirmationToastHost(
      confirmed: state.hasError,
      isError: true,
      noticeId: state.error,
      message: 'No pudimos completar la vista previa del caso.',
      actionLabel: 'Reintentar',
      onAction: () => ref.invalidate(provider),
      child: ExploreMapPreviewContent(
        item: item,
        scrollable: scrollable,
        detail: state.asData?.value,
        loading: state.isLoading,
        failed: state.hasError,
      ),
    );
  }
}

/// Public case summary sharing the photo renderer used by case cards.
class ExploreMapPreviewContent extends StatelessWidget {
  const ExploreMapPreviewContent({
    required this.item,
    this.detail,
    this.loading = false,
    this.failed = false,
    this.scrollable = true,
    super.key,
  });
  final ExploreCase item;
  final ExploreCasePreview? detail;
  final bool loading, failed, scrollable;

  @override
  Widget build(BuildContext context) {
    final photo = detail?.photoUri ?? item.coverUri;
    final date = caseDateOnlyLabel(detail?.occurredAt ?? item.occurredAt);
    final event = item.kind == ExploreKind.lost
        ? 'Desaparición'
        : item.kind == ExploreKind.sighting
        ? 'Avistamiento'
        : 'Encuentro';
    final size = switch (detail?.size) {
      'small' => 'Pequeño',
      'medium' => 'Mediano',
      'large' => 'Grande',
      _ => failed ? 'Tamaño no disponible' : 'Tamaño no registrado',
    };
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: const ValueKey('map-preview-photo'),
          height: 136,
          child: photo == null
              ? const ColoredBox(
                  color: Color(0xFFE5E5EA),
                  child: Center(child: Icon(Icons.pets_outlined)),
                )
              : CasePhotoView.network(
                  photo,
                  semanticLabel: 'Foto principal del caso',
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.name.isEmpty ? 'Sin nombre' : item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final scaledWidth =
                      MediaQuery.textScalerOf(context).scale(12) * 7;
                  final columnWidth = (constraints.maxWidth - 16) / 3;
                  final factWidth = columnWidth < scaledWidth
                      ? scaledWidth
                      : columnWidth;
                  return SingleChildScrollView(
                    key: const ValueKey('map-preview-facts'),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: factWidth,
                          child: _PreviewFact(
                            icon: Icons.straighten_rounded,
                            value: loading
                                ? const LoadingShimmer(
                                    isLoading: true,
                                    isAction: false,
                                    loadingLabel:
                                        'Consultando detalles del caso',
                                    child: SizedBox(
                                      height: 14,
                                      child: ColoredBox(
                                        color: Color(0xFFE5E5EA),
                                      ),
                                    ),
                                  )
                                : Text(size),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: factWidth,
                          child: const _PreviewFact(
                            icon: Icons.pets_outlined,
                            value: Text('Raza no registrada'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: factWidth,
                          child: _PreviewFact(
                            icon: Icons.calendar_today_outlined,
                            value: Text('$event: $date'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

class _PreviewFact extends StatelessWidget {
  const _PreviewFact({required this.icon, required this.value});
  final IconData icon;
  final Widget value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ExcludeSemantics(
        child: Icon(icon, size: 18, color: const Color(0xFF6E6E73)),
      ),
      const SizedBox(height: 6),
      DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
        child: value,
      ),
    ],
  );
}
