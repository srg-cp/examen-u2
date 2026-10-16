import 'dart:math' show pi;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'selection_pill_surface.dart';
import 'loading_shimmer.dart';

/// Anchored filter disclosure that preserves the surrounding content layout.
class FilterExpansion<T> extends StatefulWidget {
  const FilterExpansion({
    required this.label,
    required this.editorBuilder,
    required this.onApply,
    this.enabled = true,
    this.applying = false,
    this.icon = Icons.tune_rounded,
    this.panelWidth,
    this.alignPanelToEnd = false,
    super.key,
  });
  final String label;
  final Widget Function(BuildContext, ValueChanged<T>) editorBuilder;
  final ValueChanged<T> onApply;
  final bool enabled, applying;
  final IconData icon;
  final double? panelWidth;
  final bool alignPanelToEnd;
  @override
  State<FilterExpansion<T>> createState() => _FilterExpansionState<T>();
}

class _FilterExpansionState<T> extends State<FilterExpansion<T>>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _anchor = GlobalKey();
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 280),
  );
  late final _progress = CurvedAnimation(
    parent: _motion,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInOutCubic,
  );
  bool _open = false;
  bool _closing = false;

  Future<void> _close() async {
    if (!_open || _closing) return;
    setState(() => _closing = true);
    FocusScope.of(context).unfocus();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 0;
    } else {
      try {
        await _motion.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (!mounted) return;
    _portal.hide();
    setState(() {
      _open = false;
      _closing = false;
    });
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      setState(() => _open = true);
      _portal.show();
      if (MediaQuery.disableAnimationsOf(context)) {
        _motion.value = 1;
      } else {
        _motion.forward(from: 0);
      }
    }
  }

  @override
  void didUpdateWidget(covariant FilterExpansion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _close();
  }

  void _apply(T value) {
    if (!_open || _closing || !widget.enabled) return;
    _close();
    widget.onApply(value);
  }

  @override
  void dispose() {
    _progress.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_open,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _close();
    },
    child: OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _overlay,
      child: CompositedTransformTarget(
        key: _anchor,
        link: _link,
        child: LoadingShimmer(
          isLoading: widget.applying,
          loadingLabel: 'Aplicando filtros',
          radius: 32,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, child) {
              final progress = _progress.value;
              final foreground = Color.lerp(
                SelectionPillSurface.selected,
                Colors.white,
                progress,
              )!;
              return SelectionPillSurface(
                child: Material(
                  // Follow the shared timeline without a second implicit animation.
                  animationDuration: Duration.zero,
                  color: Color.lerp(
                    SelectionPillSurface.background,
                    SelectionPillSurface.selected,
                    progress,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onTap: widget.enabled ? _toggle : null,
                    borderRadius: BorderRadius.circular(26),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(widget.icon, size: 20, color: foreground),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: -pi * progress,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _overlay(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final box = _anchor.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return const SizedBox.shrink();
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
      final sourceRect = origin & box.size;
      final bottom = sourceRect.bottom;
      final media = MediaQuery.of(context);
      final inset = media.viewInsets.bottom > media.padding.bottom
          ? media.viewInsets.bottom
          : media.padding.bottom;
      final height = (constraints.maxHeight - bottom - inset - 20).clamp(
        0.0,
        constraints.maxHeight,
      );
      return AnimatedBuilder(
        animation: _progress,
        child: SizedBox(
          width: widget.panelWidth ?? box.size.width,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Material(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(16),
                child: widget.editorBuilder(context, _apply),
              ),
            ),
          ),
        ),
        builder: (context, panel) {
          final progress = _progress.value;
          return Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _FilterBackdropClipper(sourceRect),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 16 * progress,
                      sigmaY: 16 * progress,
                    ),
                    child: Semantics(
                      label: 'Cerrar filtros',
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _close,
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: .28 * progress),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: widget.alignPanelToEnd
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  followerAnchor: widget.alignPanelToEnd
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  offset: const Offset(0, 8),
                  child: IgnorePointer(
                    ignoring: _closing,
                    child: Opacity(
                      opacity: progress,
                      child: Transform.scale(
                        alignment: Alignment.topCenter,
                        scaleX: .94 + .06 * progress,
                        scaleY: .86 + .14 * progress,
                        child: panel,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Leaves the actual trigger visible and interactive through the backdrop.
class _FilterBackdropClipper extends CustomClipper<Path> {
  const _FilterBackdropClipper(this.source);
  final Rect source;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRRect(RRect.fromRectAndRadius(source, const Radius.circular(32)));

  @override
  bool shouldReclip(_FilterBackdropClipper oldClipper) =>
      source != oldClipper.source;
}
