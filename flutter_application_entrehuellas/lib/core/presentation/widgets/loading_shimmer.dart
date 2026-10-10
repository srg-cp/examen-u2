import 'package:flutter/material.dart';

/// Keeps the action label and size while a subtle sheen announces real work.
/// Reduced motion uses a static sheen; semantics still announce the operation.
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    required this.isLoading,
    required this.loadingLabel,
    required this.child,
    this.radius = 24,
    this.highlight = const Color(0x44FFFFFF),
    super.key,
  });
  final bool isLoading;
  final String loadingLabel;
  final Widget child;
  final double radius;
  final Color highlight;
  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduced = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(LoadingShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.isLoading && !_reduced) {
      if (!_controller.isAnimating) {
        _controller.value = 0;
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = widget.isLoading ? .5 : 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    return Semantics(
      button: true,
      enabled: false,
      liveRegion: true,
      label: widget.loadingLabel,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: CustomPaint(
              foregroundPainter: _ShimmerPainter(_controller, widget.highlight),
              child: Opacity(opacity: .72, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter(this.animation, this.highlight) : super(repaint: animation);
  final Animation<double> animation;
  final Color highlight;
  @override
  void paint(Canvas canvas, Size size) {
    final span = size.width * .55;
    final x = -span + (size.width + span) * animation.value;
    final rect = Rect.fromLTWH(x, 0, span, size.height);
    final shader = LinearGradient(
      colors: [highlight.withAlpha(0), highlight, highlight.withAlpha(0)],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.animation != animation || old.highlight != highlight;
}
