import 'package:divine/components/custom_card.dart';
import 'package:divine/utilities/common_utility.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class PasswordFormBuilder extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final String? whichPage;

  final bool? enabled;
  final bool obscureText;

  final TextInputType? textInputType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode, nextFocusNode;
  final VoidCallback? submitAction;
  final FormFieldValidator<String>? validateFunction;

  final void Function(String)? onSaved, onChange;

  final CommonUtility commonUtility = CommonUtility();

  // ignore: overridden_fields
  @override
  final Key? key;
  final IconData? prefix;
  final IconData? suffix;

  PasswordFormBuilder(
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
      this.key})
      : super(key: key);

  @override
  State<PasswordFormBuilder> createState() => _PasswordFormBuilderState();
}

class _PasswordFormBuilderState extends State<PasswordFormBuilder> {
  String? error;

  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                textCapitalization: TextCapitalization.none,
                initialValue: widget.initialValue,
                enabled: widget.enabled,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 18.0,
                  fontFamily: GoogleFonts.ubuntu().fontFamily,
                  height: 1.2,
                ),
                onChanged: (value) => {
                      error = widget.validateFunction!(value),
                      setState(() {}),
                      widget.onChange!(value)
                    },
                onFieldSubmitted: (term) {
                  if (widget.nextFocusNode != null) {
                    widget.focusNode!.unfocus();
                    FocusScope.of(context).requestFocus(widget.nextFocusNode);
                  } else {
                    widget.submitAction!();
                  }
                },
                obscureText: obscureText,
                keyboardType: widget.textInputType,
                validator: widget.validateFunction,
                onSaved: (val) {
                  error = widget.validateFunction!(val);
                  setState(() {});
                  widget.onSaved!(val!);
                },
                textInputAction: widget.textInputAction,
                focusNode: widget.focusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(widget.prefix,
                      size: 25.0,
                      color: widget.whichPage == 'login'
                          ? Colors.orange
                          : Colors.blue),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => obscureText = !obscureText);
                    },
                    child: Icon(
                        obscureText ? widget.suffix : Ionicons.eye_off_outline,
                        size: 25.0,
                        color: widget.whichPage == 'login'
                            ? Colors.orange
                            : Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
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
                ))),
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
      )
    ]);
  }
}
