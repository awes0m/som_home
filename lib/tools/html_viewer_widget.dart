import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/utils/responsive.dart';

class HtmlViewerWidget extends StatefulWidget {
  final String assetPath;
  final String title;

  const HtmlViewerWidget({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<HtmlViewerWidget> createState() => _HtmlViewerWidgetState();
}

class _HtmlViewerWidgetState extends State<HtmlViewerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() async {
    _controller = WebViewController();
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
    }

    await _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      final String htmlContent = await rootBundle.loadString(widget.assetPath);

      if (kIsWeb) {
        await _controller.loadHtmlString(htmlContent);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isControllerInitialized = true;
          });
        }
      } else {
        final String dataUrl =
            'data:text/html;charset=utf-8,${Uri.encodeComponent(htmlContent)}';
        await _controller.loadRequest(Uri.parse(dataUrl));
        if (mounted) {
          setState(() {
            _isControllerInitialized = true;
          });
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading HTML from assets: $e');
      const String errorHtml = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>Error</title>
          <style>
            body { 
              font-family: Arial, sans-serif; 
              text-align: center; 
              padding: 50px; 
              background-color: #f5f5f5;
            }
            .error { 
              color: #d32f2f; 
              font-size: 18px;
            }
          </style>
        </head>
        <body>
          <div class="error">
            <h2>Error Loading Content</h2>
            <p>Unable to load the HTML file from assets.</p>
          </div>
        </body>
        </html>
      ''';

      if (kIsWeb) {
        await _controller.loadHtmlString(errorHtml);
      } else {
        final String errorDataUrl =
            'data:text/html;charset=utf-8,${Uri.encodeComponent(errorHtml)}';
        await _controller.loadRequest(Uri.parse(errorDataUrl));
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isControllerInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading || !_isControllerInitialized)
        ? Container(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.8),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 400),
                  Text('Loading...'),
                ],
              ),
            ),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.isDesktop(context)
                      ? 1200
                      : ResponsiveHelper.isTablet(context)
                      ? 800
                      : double.infinity,
                  maxHeight: MediaQuery.of(context).size.height - 80,
                ),
                // Only show WebView after controller is initialized
                child: WebViewWidget(controller: _controller),
              ),
            ),
          );
  }
}
