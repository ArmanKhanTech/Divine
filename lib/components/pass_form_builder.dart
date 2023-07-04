import 'package:divine/components/custom_card.dart';
import 'package:divine/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// This class will build password input fields for our forms.
class PasswordFormBuilder extends StatefulWidget {
  final String? initialValue;
  final bool? enabled;
  final String? hintText;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FocusNode? focusNode, nextFocusNode;
  final VoidCallback? submitAction;
  final FormFieldValidator<String>? validateFunction;
  final void Function(String)? onSaved, onChange;
  final String? whichPage;
  // ignore: overridden_fields
  @override
  final Key? key;
  final IconData? prefix;
  final IconData? suffix;

  const PasswordFormBuilder(
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
      this.key});

  @override
  State<PasswordFormBuilder> createState() => _PasswordFormBuilderState();
}

class _PasswordFormBuilderState extends State<PasswordFormBuilder> {
  String? error;
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CustomCard(
          borderRadius: BorderRadius.circular(20.0),
          child: Theme(
              data: ThemeData(
                primaryColor: Theme.of(context).colorScheme.secondary,
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Theme.of(context).colorScheme.secondary),
              ),
              child: TextFormField(
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  textCapitalization: TextCapitalization.none,
                  initialValue: widget.initialValue,
                  enabled: widget.enabled,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
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
                    prefixIcon: Icon(
                      widget.prefix,
                      size: 20.0,
                      color: widget.whichPage == 'login' ? Constants.orange : Colors.blue
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() => obscureText = !obscureText);
                      },
                      child: Icon(
                        obscureText ? widget.suffix : Ionicons.eye_off_outline,
                        size: 20.0,
                          color: widget.whichPage == 'login' ? Constants.orange : Colors.blue
                      ),
                    ),
                    filled: true,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    border: border(context),
                    enabledBorder: border(context),
                    focusedBorder: focusBorder(context),
                    errorStyle: const TextStyle(height: 10.0, fontSize: 0.0),
                  ))),
        ),
        Visibility(
          visible: error != null,
          child: Text(
            '$error',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 12.0,
            ),
          ),
        )
      ]),
    );
  }

  border(BuildContext context) {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30.0),
      ),
      borderSide: BorderSide(
        color: Colors.white,
        width: 0.0,
      ),
    );
  }

  focusBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(30.0),
      ),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 1.0,
      ),
    );
  }
}
