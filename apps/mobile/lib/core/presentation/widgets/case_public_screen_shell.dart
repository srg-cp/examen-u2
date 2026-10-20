import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';
import 'app_scaffold.dart';
import 'confirmation_toast.dart';
import 'cover_reveal.dart';
import 'glass_navigation_button.dart';
import 'scroll_safe_area.dart';
import 'stagger_reveal.dart';

/// Persistent glass navigation above the scrollable public case cards.
class CasePublicScreenShell extends StatelessWidget {
  const CasePublicScreenShell({
    required this.child,
    required this.loading,
    this.trailingAction,
    this.notice,
    this.noticeId,
    this.onBack,
    super.key,
  });

  final Widget child;
  final Widget? trailingAction;
  final bool loading;
  final String? notice;
  final Object? noticeId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => ConfirmationToastHost(
    confirmed: notice != null,
    message: notice ?? '',
    noticeId: noticeId,
    isError: true,
    child: AppScaffold(
      body: ScrollSafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final top = MediaQuery.paddingOf(context).top + 4;
                final largeText =
                    MediaQuery.textScalerOf(context).scale(20) > 26;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    SingleChildScrollView(
                      key: const PageStorageKey('public-case-cards-scroll'),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        top,
                        16,
                        ScrollSafeArea.bottomPadding(context, 24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!largeText) ...[
                            SizedBox(
                              height: 52,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 56,
                                  ),
                                  child: Text(
                                    'Ficha pública',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.primaryTitle.copyWith(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (largeText) ...[
                            const SizedBox(height: 68),
                            Text(
                              'Ficha pública',
                              style: AppTypography.primaryTitle,
                            ),
                            const SizedBox(height: 16),
                          ],
                          AuthStageTransition(
                            enabled: !loading,
                            stage: 'public-case',
                            startCovered: true,
                            builder: (play) => ContentReveal(
                              loading: loading,
                              count: 5,
                              play: play,
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: Color(0xFF111111),
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: top,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          GlassNavigationButton(
                            tooltip: 'Volver',
                            onPressed:
                                onBack ??
                                () => context.canPop()
                                    ? context.pop()
                                    : context.go('/home'),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: trailingAction,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
