import 'package:divine/utilities/common_utility.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_card.dart';

class TextFormBuilder extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final String? whichPage;

  final TextInputType? textInputType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  final bool capitalization;
  final bool obscureText;
  final bool? enabled;

  final FocusNode? focusNode, nextFocusNode;
  final VoidCallback? submitAction;

  final double? iconSize;

  final FormFieldValidator<String>? validateFunction;

  final void Function(String)? onSaved, onChange;

  final CommonUtility commonUtility = CommonUtility();

  // ignore: overridden_fields
  @override
  final Key? key;
  final IconData? prefix;
  final IconData? suffix;

  TextFormBuilder(
      {this.prefix,
      this.suffix,
      this.initialValue,
      this.enabled,
      this.hintText,
      this.textInputType,
      this.controller,
      this.textInputAction,
      this.nextFocusNode,
      this.focusNode,
      this.submitAction,
      this.obscureText = false,
      this.validateFunction,
      this.onSaved,
      this.onChange,
      required this.whichPage,
      required this.capitalization,
      this.key,
      this.iconSize})
      : super(key: key);

  @override
  State<TextFormBuilder> createState() => _TextFormBuilderState();
}

class _TextFormBuilderState extends State<TextFormBuilder> {
  String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomCard(
          borderRadius: BorderRadius.circular(20.0),
          child: Theme(
            data: ThemeData(
              primaryColor: Theme.of(context).colorScheme.secondary,
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Theme.of(context).colorScheme.secondary),
            ),
            child: TextFormField(
              cursorColor: Theme.of(context).colorScheme.secondary,
              textCapitalization: widget.capitalization == false
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              initialValue: widget.initialValue,
              enabled: widget.enabled,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 18,
                fontFamily: GoogleFonts.ubuntu().fontFamily,
                height: 1.2,
              ),
              onChanged: (value) => {
                error = widget.validateFunction!(value),
                setState(() {}),
                widget.onChange!(value)
              },
              key: widget.key,
              obscureText: widget.obscureText,
              validator: widget.validateFunction,
              controller: widget.controller,
              onSaved: (value) {
                error = widget.validateFunction!(value!);
                setState(() {});
                widget.onSaved!(value);
              },
              textInputAction: widget.textInputAction,
              focusNode: widget.focusNode,
              onFieldSubmitted: (term) {
                if (widget.nextFocusNode != null) {
                  widget.focusNode!.unfocus();
                  FocusScope.of(context).requestFocus(widget.nextFocusNode);
                } else {
                  widget.submitAction!();
                }
              },
              keyboardType: widget.textInputType,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  widget.prefix,
                  size: 25.0,
                  color:
                      widget.whichPage == "login" ? Colors.orange : Colors.blue,
                ),
                suffixIcon: Icon(
                  widget.suffix,
                  size: 25.0,
                  color:
                      widget.whichPage == "login" ? Colors.orange : Colors.blue,
                ),
                fillColor: Colors.grey[200],
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                  fontFamily: GoogleFonts.ubuntu().fontFamily,
                  height: 1.2,
                ),
                contentPadding: const EdgeInsets.all(15.0),
                border: widget.commonUtility.border(context),
                enabledBorder: widget.commonUtility.border(context),
                focusedBorder: widget.commonUtility.focusBorder(context),
                errorStyle: const TextStyle(height: 10.0, fontSize: 0.0),
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ),
        Visibility(
          visible: error != null,
          child: Text(
            '$error',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 15.0,
            ),
          ),
        ),
      ],
    );
  }
}
