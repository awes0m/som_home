import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/constants.dart';

class SearchBarWidget extends StatefulWidget {
  final bool autoFocus;
  final String? placeholder;
  
  const SearchBarWidget({
    super.key,
    this.autoFocus = false,
    this.placeholder,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      Future.delayed(Duration.zero, () {
        _focusNode.requestFocus();
      });
    }
  }

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      final url = Uri.parse('${AppConstants.googleSearchUrl}${Uri.encodeComponent(query)}');
      launchUrl(url, mode: LaunchMode.externalApplication);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(              color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (_) => _performSearch(),
        decoration: InputDecoration(
          hintText: widget.placeholder ?? 'Search Google or type a URL',
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.search),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}