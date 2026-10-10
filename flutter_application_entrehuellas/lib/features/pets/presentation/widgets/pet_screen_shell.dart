import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';

class PetScreenShell extends StatelessWidget {
  const PetScreenShell({
    this.title,
    this.onBack,
    this.navigationEnabled = true,
    required this.loading,
    required this.child,
    this.count = 9,
    super.key,
  });
  final String? title;
  final VoidCallback? onBack;
  final bool navigationEnabled;
  final bool loading;
  final Widget child;
  final int count;
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
              _content(context),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 4,
                left: 24,
                child: GlassNavigationButton(
                  tooltip: 'Volver a mis mascotas',
                  onPressed: !navigationEnabled
                      ? null
                      : onBack ??
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
  Widget _content(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      MediaQuery.paddingOf(context).top + 72,
      24,
      32,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 28),
        ],
        AuthStageTransition(
          enabled: !loading,
          stage: 'content',
          startCovered: true,
          builder: (play) => ContentReveal(
            loading: loading,
            count: count,
            play: play,
            child: child,
          ),
        ),
      ],
    ),
  );
}
