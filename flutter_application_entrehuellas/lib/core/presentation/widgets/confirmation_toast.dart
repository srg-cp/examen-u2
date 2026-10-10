import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Screen-owned feedback. A new result announces it via activation or noticeId.
/// Disposal removes both the overlay and its timer, preventing stale notices.
class ConfirmationToastHost extends StatefulWidget {
  const ConfirmationToastHost({
    required this.confirmed,
    required this.message,
    required this.child,
    this.isError = false,
    this.noticeId,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final bool confirmed;
  final String message;
  final Widget child;
  final bool isError;
  final Object? noticeId;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  State<ConfirmationToastHost> createState() => _ConfirmationToastHostState();
}

class _ConfirmationToastHostState extends State<ConfirmationToastHost> {
  OverlayEntry? _entry;
  Timer? _timer;
  int _generation = 0;
  void _clear() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  @override
  void didUpdateWidget(ConfirmationToastHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confirmed == widget.confirmed &&
        (!widget.confirmed || oldWidget.noticeId == widget.noticeId)) {
      return;
    }
    final generation = ++_generation;
    _clear();
    if (!widget.confirmed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      final media = MediaQuery.of(context);
      _entry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 24,
          right: 24,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MediaQuery(
                data: media,
                child: _ConfirmationToast(
                  message: widget.message,
                  isError: widget.isError,
                  actionLabel: widget.actionLabel,
                  onAction: widget.onAction == null
                      ? null
                      : () {
                          final action = widget.onAction;
                          _clear();
                          action?.call();
                        },
                  onClose: _clear,
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context, rootOverlay: true).insert(_entry!);
      _timer = Timer(
        Duration(seconds: media.accessibleNavigation ? 6 : 3),
        _clear,
      );
    });
  }

  @override
  void dispose() {
    _generation++;
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ConfirmationToast extends StatefulWidget {
  const _ConfirmationToast({
    required this.message,
    required this.onClose,
    required this.isError,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  @override
  State<_ConfirmationToast> createState() => _ConfirmationToastState();
}

class _ConfirmationToastState extends State<_ConfirmationToast>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else if (_animation.value == 0 && !_animation.isAnimating) {
      _animation.forward();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, -.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A24282A),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xE6F5F5F7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xB3FFFFFF)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Semantics(
                  liveRegion: true,
                  button: true,
                  hint: 'Toca para cerrar',
                  onDismiss: widget.onClose,
                  child: InkWell(
                    onTap: widget.onClose,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0x0D24282A),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(
                                    widget.isError
                                        ? Icons.error_outline_rounded
                                        : Icons.check_rounded,
                                    color: widget.isError
                                        ? const Color(0xFFB53F48)
                                        : const Color(0xFF111111),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                  if (widget.actionLabel != null &&
                                      widget.onAction != null)
                                    TextButton(
                                      onPressed: widget.onAction,
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF111111,
                                        ),
                                      ),
                                      child: Text(widget.actionLabel!),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
