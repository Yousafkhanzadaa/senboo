import 'package:flutter/material.dart';

class InterestButton extends StatefulWidget {
  InterestButton(
      {Key? key, this.name, required this.interested, required this.onPressed})
      : super(key: key);
  final String? name;
  final bool interested;
  final Function() onPressed;

  @override
  _InterestButtonState createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            widget.interested ? Theme.of(context).primaryColor : Colors.white),
        shadowColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        elevation: MaterialStateProperty.all(0),
        side: widget.interested
            ? MaterialStateProperty.all(BorderSide.none)
            : MaterialStateProperty.all(
                BorderSide(color: Theme.of(context).primaryColor)),
      ),
      child: Text(
        widget.name!.toUpperCase(),
        style: widget.interested
            ? Theme.of(context).textTheme.subtitle2
            : Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
      ),
    );
  }
}
