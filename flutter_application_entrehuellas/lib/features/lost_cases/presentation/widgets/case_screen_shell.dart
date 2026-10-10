import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';

class CaseScreenShell extends StatefulWidget {
  const CaseScreenShell({
    required this.title,
    required this.child,
    this.onBack,
    this.stage = 'content',
    this.loading = false,
    super.key,
  });
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final Object stage;
  final bool loading;
  @override
  State<CaseScreenShell> createState() => _CaseScreenShellState();
}

class _CaseScreenShellState extends State<CaseScreenShell> {
  final _scroll = ScrollController(keepScrollOffset: false);
  @override
  void didUpdateWidget(CaseScreenShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.paddingOf(context).top + 76,
                  24,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthStageTransition(
                      stage: widget.stage,
                      startCovered: true,
                      enabled: !widget.loading,
                      builder: (play) => ContentReveal(
                        loading: widget.loading,
                        count: 8,
                        play: play,
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF111111),
                            height: 1.5,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 4,
                left: 24,
                child: GlassNavigationButton(
                  tooltip: 'Volver',
                  onPressed:
                      widget.onBack ??
                      () => context.canPop()
                          ? context.pop()
                          : context.go('/home'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
