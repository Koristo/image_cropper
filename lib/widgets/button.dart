
import 'package:flutter/cupertino.dart';

import '/style.dart';
import './link.dart';

//****************************************************************************//

class Button extends StatelessWidget {

  final String    text;
  final double?   width;
  final double    height;
  final Color?    bgColor;
  final Color?    textColor;
  final Widget?   child;
  final Function? onClick;

  //-------------------------------------------------------------------------//

  const Button({
             Key? key,
    required this.text,
    required this.height,
             this.child,
             this.width,
             this.bgColor,
             this.textColor,
             this.onClick
  }) : super(
      key: key
  );

  @override
  Widget build(BuildContext context) {
    return Link(
      onClick: onClick,
      child  : Center(
        child: Container(
          alignment : Alignment.center,
          width     : width,
          height    : height,
          decoration: BoxDecoration(
            color       : bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child     : Text(text,
            style: StyleText.buttonText.apply(
              color: StyleColor.white,
            ),
          ),
        ),
      ),
    );
  }
}