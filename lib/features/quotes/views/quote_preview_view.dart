import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/qf_buttons.dart';
import '../../../core/widgets/qf_headers.dart';
import '../../../core/widgets/qf_states.dart';
import '../data/models/sent_via.dart';
import '../viewmodels/quote_preview_viewmodel.dart';

class QuotePreviewView extends ConsumerWidget {
  const QuotePreviewView({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quotePreviewViewModelProvider(quoteId);
    final async = ref.watch(provider);
    final s = async.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          QfNavBar(
            backLabel: 'Back',
            title: 'Preview',
            subtitle: s == null ? null : '${s.quote.number} · ${s.quote.customerName}',
          ),
          Expanded(
            child: async.when(
              skipLoadingOnReload: true,
              loading: () => const QfLoading(),
              error: (e, _) => QfError(error: e, onRetry: () => ref.invalidate(provider)),
              data: (s) => _PdfView(state: s),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: s == null ? null : _SendDock(quoteId: quoteId, state: s),
    );
  }
}

/// Full-width PDF viewer: pinch / double-tap zoom, pan, and − · fit · + controls.
class _PdfView extends StatefulWidget {
  const _PdfView({required this.state});

  final QuotePreviewState state;

  @override
  State<_PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<_PdfView> {
  final _controller = PdfViewerController();
  int _page = 1;
  int _pages = 1;

  void _fit() {
    if (!_controller.isReady) return;
    _controller.goToPage(pageNumber: _page, anchor: PdfPageAnchor.all);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: PdfViewer.data(
          widget.state.pdf,
          // Unique per generated PDF so the viewer reloads after edits.
          sourceName: '${widget.state.file.path}#${widget.state.pdf.hashCode}',
          controller: _controller,
          params: PdfViewerParams(
            backgroundColor: AppColors.soft,
            margin: 12,
            pageDropShadow: const BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 2)),
            sizeDelegateProvider: const PdfViewerSizeDelegateProviderLegacy(maxScale: 8),
            onViewerReady: (doc, _) => setState(() => _pages = doc.pages.length),
            onPageChanged: (p) => setState(() => _page = p ?? _page),
            loadingBannerBuilder: (_, _, _) => const QfLoading(),
          ),
        ),
      ),
      Positioned(
        right: 12,
        bottom: 12,
        child: _ZoomBar(
          page: '$_page / $_pages',
          onZoomOut: () => _controller.zoomDown(),
          onFit: _fit,
          onZoomIn: () => _controller.zoomUp(),
        ),
      ),
    ]);
  }
}

class _ZoomBar extends StatelessWidget {
  const _ZoomBar({required this.page, required this.onZoomOut, required this.onFit, required this.onZoomIn});

  final String page;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onZoomIn;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, String label, VoidCallback onTap) => Semantics(
          button: true,
          label: label,
          child: InkResponse(
            onTap: onTap,
            radius: 22,
            child: SizedBox.square(dimension: AppSpacing.tap, child: Icon(icon, size: 20, color: AppColors.onInk)),
          ),
        );
    return Material(
      color: AppColors.ink.withValues(alpha: 0.88),
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(page, style: AppText.caption.copyWith(color: AppColors.onInk)),
          ),
          btn(LucideIcons.zoomOut, 'Zoom out', onZoomOut),
          btn(LucideIcons.maximize, 'Fit page', onFit),
          btn(LucideIcons.zoomIn, 'Zoom in', onZoomIn),
        ]),
      ),
    );
  }
}

class _SendDock extends ConsumerWidget {
  const _SendDock({required this.quoteId, required this.state});

  final String quoteId;
  final QuotePreviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quotePreviewViewModelProvider(quoteId).notifier);

    Future<void> email() async {
      try {
        await vm.sendByEmail();
      } catch (e) {
        if (context.mounted) showQfToast(context, failureMessage(e));
      }
    }

    final reason = state.disabledReason;
    return QfDock(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'PDF attached · you tap Send in your mail app',
          style: AppText.callout.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        QfPillButton(
          label: 'Email',
          icon: LucideIcons.mail,
          busy: state.sending == SentVia.email,
          onPressed: state.canEmail ? email : null,
        ),
        if (reason != null) ...[
          const SizedBox(height: 8),
          Text(reason, style: AppText.micro, textAlign: TextAlign.center),
        ],
      ]),
    );
  }
}
