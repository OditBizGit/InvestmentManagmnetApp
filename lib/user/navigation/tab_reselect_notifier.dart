import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maribel_wellness_centre_application/core/utils/go_to_top_button.dart';

/// Fires when the user taps the already-selected bottom navigation item.
class TabReselectNotifier extends ChangeNotifier {
  void notifyReselect() => notifyListeners();
}

/// Binds a [TabReselectNotifier] to a [ScrollController] for scroll-to-top.
class TabReselectScrollBinder {
  TabReselectScrollBinder({
    required this.listenable,
    required this.scrollController,
  }) {
    listenable.addListener(_onReselect);
  }

  final Listenable listenable;
  final ScrollController scrollController;

  void _onReselect() => GoToTopButton.animateToTop(scrollController);

  void dispose() => listenable.removeListener(_onReselect);
}
