import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/entities/search_place.dart';
import '../view_models/place_search_view_model.dart';

class PlaceSearchFields extends ConsumerStatefulWidget {
  const PlaceSearchFields({
    required this.onSelect,
    this.initialLabel = '',
    this.citiesOnly = false,
    this.enabled = true,
    this.invalid = false,
    this.onQueryChanged,
    super.key,
  });
  final ValueChanged<SearchPlace> onSelect;
  final String initialLabel;
  final bool citiesOnly, enabled, invalid;
  final ValueChanged<String>? onQueryChanged;
  @override
  ConsumerState<PlaceSearchFields> createState() => _PlaceSearchFieldsState();
}

class _PlaceSearchFieldsState extends ConsumerState<PlaceSearchFields> {
  late final _controller = TextEditingController(text: widget.initialLabel);
  @override
  void didUpdateWidget(covariant PlaceSearchFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLabel != oldWidget.initialLabel &&
        _controller.text != widget.initialLabel) {
      _controller.text = widget.initialLabel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.text == widget.initialLabel) {
          ref
              .read(
                placeSearchByModeViewModelProvider(widget.citiesOnly).notifier,
              )
              .clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = placeSearchByModeViewModelProvider(widget.citiesOnly);
    final state = ref.watch(provider);
    final model = ref.read(provider.notifier);
    return ConfirmationToastHost(
      confirmed: state.notice != null,
      isError: true,
      message: state.notice ?? '',
      noticeId: state.noticeId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: widget.citiesOnly ? 'Ciudad' : 'Ciudad o dirección',
            hint: 'Por ejemplo, Miraflores, Lima',
            icon: Icons.search_rounded,
            controller: _controller,
            enabled: widget.enabled,
            invalid: widget.invalid,
            textInputAction: TextInputAction.search,
            onChanged: (query) {
              widget.onQueryChanged?.call(query);
              model.queryChanged(query);
            },
            onSubmitted: (_) => model.search(_controller.text),
          ),
          if (state.busy)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LoadingShimmer(
                isLoading: true,
                isAction: false,
                loadingLabel: 'Consultando lugares',
                child: SkeletonFormFields(fieldCount: 1),
              ),
            ),
          for (final place in state.places)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFFF5F5F7),
                ),
                onPressed: !widget.enabled
                    ? null
                    : () {
                        _controller.text = place.label;
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.onSelect(place);
                        model.clear();
                      },
                icon: const Icon(Icons.location_on_outlined),
                label: Text(place.label),
              ),
            ),
        ],
      ),
    );
  }
}
