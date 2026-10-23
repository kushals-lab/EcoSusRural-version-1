/// Small widgets + helpers for the rural intelligence search-first screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBarSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVoice;
  final VoidCallback onSearch;

  const SearchBarSection({
    super.key,
    required this.controller,
    required this.onVoice,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch(),
                decoration: const InputDecoration(
                  hintText: 'Ask the Rural Intelligence engine',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onVoice,
              icon: const Icon(Icons.mic_none_rounded),
              tooltip: 'Voice input',
            ),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}

void _showShortcut(String message, {required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

VoidCallback onVoice(BuildContext context, WidgetRef ref) => () {
      _showShortcut(
        'Voice input requires a speech plugin or server-side STT endpoint; routed to a documented adapter.',
        context: context,
      );
    };
