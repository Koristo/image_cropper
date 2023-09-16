

import 'package:flutter/cupertino.dart';

class Link extends StatelessWidget {

  final Widget?          child;
  final bool             isDisabled;
  final void Function()? onTap;
  final Function?        onClick;

  const Link({
    Key? key,
    this.child,
    this.onTap,
    this.onClick,
    this.isDisabled = false
  }): super(
    key: key
  );

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child : GestureDetector(
        behavior : HitTestBehavior.translucent,
        child    : child,
        onTap    : isDisabled ? null : onTap,
        onTapDown: isDisabled ? null : (_) => onClick?.call(),
      ),
    );
  }
}