import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchShortcuts extends StatelessWidget {
  final FocusNode searchFocusNode;
  final Widget child;

  const SearchShortcuts({
    super.key,
    required this.searchFocusNode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.slash): const _FocusSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) {
              searchFocusNode.requestFocus();
              return null;
            },
          ),
        },
        // Regroupe la navigation Tab dans un ordre de lecture cohérent
        // pour cet écran, sans casser l'ordre naturel du reste de l'app.
        child: FocusTraversalGroup(child: child),
      ),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}