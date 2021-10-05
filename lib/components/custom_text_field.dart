import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField(
      {Key? key,
      required this.controller,
      this.label,
      required this.hint,
      this.onChange,
      this.maxLines = 1,
      this.validator})
      : super(key: key);
  final TextEditingController controller;
  final String? label;
  final String hint;
  final int? maxLines;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: Theme.of(context).textTheme.bodyText1,
      // autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.maxLines! > 1 ? 25 : 35),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.maxLines! > 1 ? 25 : 35),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1),
        ),
        prefix: SizedBox(
          width: 10,
        ),
        alignLabelWithHint: true,
        fillColor: Theme.of(context).cardColor,
        filled: true,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.black38),
        labelText: widget.label?.toUpperCase(),
        labelStyle:
            Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 13),
      ),
      validator: widget.validator,
      onChanged: widget.onChange,
      maxLines: widget.maxLines,
      // maxLines: 12,
      cursorColor: Theme.of(context).primaryColor,
    );
  }
}
