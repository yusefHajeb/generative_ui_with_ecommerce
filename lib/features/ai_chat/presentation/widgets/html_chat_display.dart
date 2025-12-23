// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class HtmlChatDisplay extends StatelessWidget {
  final String htmlContent;

  const HtmlChatDisplay({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    debugPrint('[HTML_DISPLAY] Rendering HTML, length: ${htmlContent.length}');
    debugPrint('[HTML_DISPLAY] Full content:\n$htmlContent');

    if (htmlContent.trim().isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: const Text('Empty content received'),
      );
    }

    try {
      final document = html_parser.parse(htmlContent);
      final rootElement = document.body?.firstChild;

      if (rootElement != null && rootElement is dom.Element) {
        if (_isM2PCard(rootElement)) {
          return _buildM2PCard(context, rootElement);
        }
      }
    } catch (e) {
      debugPrint('[HTML_DISPLAY] Error parsing HTML: $e');
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Html(data: htmlContent, shrinkWrap: true),
    );
  }

  bool _isM2PCard(dom.Element element) {
    final style = element.attributes['style'] ?? '';
    return style.contains('linear-gradient') &&
        element.text.contains('M2P Nexa');
  }

  Widget _buildM2PCard(BuildContext context, dom.Element element) {
    final children = element.children;
    String title = '🤖 M2P Nexa';
    String description = 'Your AI-powered banking companion';
    String footer = 'Powered by M2P Fintech Solutions';

    if (children.isNotEmpty) {
      title = children[0].text;
    }
    if (children.length >= 2) {
      description = children[1].text;
    }
    if (children.length >= 3) {
      final footerDiv = children[2];
      if (footerDiv.children.isNotEmpty) {
        footer = footerDiv.children[0].text;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              ),
            ),
            child: Text(
              footer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
