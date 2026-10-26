import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Starts the scrolling viewport inside the header's lower margin, while
/// reserving the same space for the initial content and painting chrome last.
class HomeScrollLayout extends StatelessWidget {
  const HomeScrollLayout({
    required this.header,
    required this.child,
    required this.enabled,
    super.key,
  });

  static const overlap = 28.0;
  final Widget header, child;
  final bool enabled;

  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
    delegate: _HomeScrollLayoutDelegate(enabled ? overlap : 0),
    children: [
      LayoutId(id: 'content', child: child),
      LayoutId(id: 'header', child: header),
    ],
  );
}

class _HomeScrollLayoutDelegate extends MultiChildLayoutDelegate {
  _HomeScrollLayoutDelegate(this.overlap);
  final double overlap;

  @override
  void performLayout(Size size) {
    final header = layoutChild(
      'header',
      BoxConstraints.tightFor(width: size.width),
    );
    final top = math.max(0.0, header.height - overlap);
    layoutChild(
      'content',
      BoxConstraints.tight(Size(size.width, math.max(0, size.height - top))),
    );
    positionChild('content', Offset(0, top));
    positionChild('header', Offset.zero);
  }

  @override
  bool shouldRelayout(_HomeScrollLayoutDelegate oldDelegate) =>
      overlap != oldDelegate.overlap;
}

/// Dissolves scrolling Home content into the actual ambient background.
/// The header and navigation remain outside this layer and fully sharp.
class HomeScrollFade extends StatefulWidget {
  const HomeScrollFade({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  State<HomeScrollFade> createState() => _HomeScrollFadeState();
}

class _HomeScrollFadeState extends State<HomeScrollFade> {
  double _extent = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final metrics = notification.metrics;
    // Grow continuously with the real scroll, without veiling the initial
    // title or adding a separate animation (including with reduced motion).
    final extent = (metrics.pixels - metrics.minScrollExtent).clamp(0.0, 48.0);
    if (extent != _extent) setState(() => _extent = extent);
    return false; // Keep pull-to-refresh and other scroll observers working.
  }

  @override
  Widget build(BuildContext context) => !widget.enabled
      ? widget.child
      : NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) {
              final height = math.min(_extent, bounds.height * .4);
              if (height <= 0) {
                return const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ).createShader(bounds);
              }
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FFFFFF),
                  Color(0x0AFFFFFF),
                  Color(0x26FFFFFF),
                  Color(0x66FFFFFF),
                  Color(0xCCFFFFFF),
                  Colors.white,
                ],
                stops: [0, .18, .4, .65, .86, 1],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, height));
            },
            child: widget.child,
          ),
        );
}
