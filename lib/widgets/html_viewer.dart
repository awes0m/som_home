import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewer extends StatefulWidget {
  final String assetPath;
  final String title;

  const HtmlViewer({super.key, required this.assetPath, required this.title});

  @override
  State<HtmlViewer> createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  late WebViewController _controller;
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

    try {
      final String htmlContent = await rootBundle.loadString(widget.assetPath);
      await _controller.loadHtmlString(htmlContent);
      if (mounted) {
        setState(() {
          _isLoading = false;
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
    } catch (e) {
      debugPrint('Error loading HTML asset: $e');
      await _controller.loadHtmlString('''
        <html>
          <body style="font-family: Arial, sans-serif; padding: 20px; text-align: center;">
            <h2>Error Loading Content</h2>
            <p>Could not load ${widget.assetPath}</p>
            <p>Error: $e</p>
          </body>
        </html>
      ''');
      
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Only show WebView after controller is initialized
          if (_isControllerInitialized) WebViewWidget(controller: _controller),
          if (_isLoading || !_isControllerInitialized)
            Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
