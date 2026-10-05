import 'package:flutter/material.dart';
import 'soft_surface.dart';

/// Transparent app bar over the paper with a round soft back button.
class VellumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const VellumAppBar({super.key, required this.title, this.actions = const []});

  static const double _height = kToolbarHeight + 8;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      toolbarHeight: _height,
      automaticallyImplyLeading: false,
      leadingWidth: 68,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: SoftIconButton(
                  icon: Icons.arrow_back_ios_new,
                  iconSize: 18,
                  tooltip: 'Назад',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null,
      title: Text(title),
      actions: [
        ...actions,
        const SizedBox(width: 16),
      ],
    );
  }
}
