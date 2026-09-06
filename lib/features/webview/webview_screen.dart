import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError  = false;
  int  _loadingProgress = 0;

  static const MethodChannel _customTabChannel =
      MethodChannel('com.arivon.app/customtabs');

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  // ✅ Detect links WebView can't render inline (pdf/downloads/tel/mail/etc.)
  bool _shouldOpenExternally(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.pdf') ||
        lower.contains('.pdf?') ||
        lower.contains('/download') ||
        lower.contains('blob.core.windows.net') ||
        lower.startsWith('tel:') ||
        lower.startsWith('mailto:') ||
        lower.startsWith('whatsapp:') ||
        lower.startsWith('intent:');
  }

  // ✅ Opens link in a colored Chrome Custom Tab (Android) via MethodChannel.
  // Falls back to url_launcher for iOS / non-Android or if native call fails.
  Future<void> _openExternally(String url) async {
    if (Platform.isAndroid) {
      try {
        final ok = await _customTabChannel.invokeMethod<bool>('openCustomTab', {
          'url': url,
          'toolbarColor':
              '#${AppColors.primary.value.toRadixString(16).substring(2)}',
        });
        if (ok == true) return;
      } catch (_) {
        // fall through to url_launcher fallback below
      }
    }

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _loadingProgress = p),
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError  = false;
          }),
          // ✅ Intercept pdf/download links before WebView tries (and fails) to load them
          onNavigationRequest: (request) {
            if (_shouldOpenExternally(request.url)) {
              _openExternally(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            final isDark = _isDark;
            _controller.runJavaScript('''
              (function() {
                try {
                  var header = document.querySelector('header');
                  if (header) header.style.display = 'none';
                  var nav = document.querySelector('nav');
                  if (nav) nav.style.display = 'none';

                  // ✅ Hide footer (tag + common class/id patterns)
                  var footer = document.querySelector('footer');
                  if (footer) footer.style.display = 'none';
                  var footerSelectors = ['.footer', '#footer', '.site-footer', '[class*="Footer"]'];
                  footerSelectors.forEach(function(sel) {
                    document.querySelectorAll(sel).forEach(function(el) {
                      el.style.display = 'none';
                    });
                  });

                  ${isDark ? '''
                  var style = document.createElement('style');
                  style.id = '__arivon_dark__';
                  style.innerHTML = \`
                    html { filter: invert(1) hue-rotate(180deg) !important; background: #111318 !important; }
                    img, video, iframe, canvas, svg, picture { filter: invert(1) hue-rotate(180deg) !important; }
                  \`;
                  if (!document.getElementById('__arivon_dark__')) {
                    document.head.appendChild(style);
                  }
                  ''' : ''}
                } catch(e) {}
              })();
            ''');
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              setState(() { _isLoading = false; _hasError = true; });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-IN,en;q=0.9',
          'Cache-Control': 'no-cache',
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = _isDark;
    final barColor    = isDark ? const Color(0xFF1C1F26) : AppColors.white;
    final borderColor = isDark ? const Color(0xFF2C2F38) : AppColors.border;
    final bgColor     = isDark ? const Color(0xFF111318) : AppColors.bg;
    final textColor   = isDark ? Colors.white             : AppColors.text;
    final textSecColor= isDark ? const Color(0xFF8A8F9E)  : AppColors.textSec;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : AppColors.white,
      body: Column(
        children: [

          // ── Top bar ────────────────────────────────────────────────
          Container(
            color: barColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 6,
              left: 14, right: 14, bottom: 10,
            ),
            child: Row(
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: textColor, size: 15),
                  ),
                ),
                const SizedBox(width: 10),

                // URL bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 12, color: AppColors.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.url.replaceFirst('https://', ''),
                            style: TextStyle(
                                fontSize: 11, color: textSecColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Reload
                GestureDetector(
                  onTap: () {
                    setState(() { _isLoading = true; _hasError = false; });
                    _controller.reload();
                  },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      _isLoading
                          ? Icons.close_rounded
                          : Icons.refresh_rounded,
                      color: textSecColor, size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: borderColor,
              color: AppColors.primary,
              minHeight: 2,
            ),
          Divider(height: 1, color: borderColor),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: _hasError
                ? _ErrorView(
                    url: widget.url,
                    onRetry: () {
                      setState(() { _isLoading = true; _hasError = false; });
                      _controller.reload();
                    },
                  )
                : Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading && _loadingProgress < 30)
                        _Shimmer(isDark: isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String url;
  final VoidCallback onRetry;

  const _ErrorView({required this.url, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52,
                color: AppColors.textSec.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Unable to Load',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            const Text(
              'The site may be temporarily down\nor blocking in-app access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSec, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Try Again',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  final bool isDark;

  const _Shimmer({required this.isDark});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base      = widget.isDark
        ? const Color(0xFF1C1F26)
        : const Color(0xFFF1F5F9);
    final highlight = widget.isDark
        ? const Color(0xFF2C2F38)
        : const Color(0xFFE2E8F0);
    final bg        = widget.isDark
        ? const Color(0xFF111318)
        : AppColors.white;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(80, double.infinity, base, highlight),
            const SizedBox(height: 12),
            _box(14, 220, base, highlight),
            const SizedBox(height: 8),
            _box(14, 180, base, highlight),
            const SizedBox(height: 8),
            _box(14, 250, base, highlight),
            const SizedBox(height: 20),
            _box(80, double.infinity, base, highlight),
            const SizedBox(height: 12),
            _box(80, double.infinity, base, highlight),
            const SizedBox(height: 12),
            _box(80, double.infinity, base, highlight),
          ],
        ),
      ),
    );
  }

  Widget _box(double h, double w, Color base, Color highlight) {
    return Container(
      height: h, width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end:   Alignment(_anim.value,     0),
          colors: [base, highlight, base],
        ),
      ),
    );
  }
}
