import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatefulWidget{
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;

  const CustomText({
    super.key,
    required this.text,
    required this.size,
    required this.weight, required this.color});

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText>{
  List<String> getAllHashtags(String text) {
    RegExp regexp = RegExp(r"\B#\w\w+");

    List<String> hashtags = [];

    regexp.allMatches(text).forEach((element) {
      if (element.group(0) != null) {
        hashtags.add(element.group(0).toString());
      }
    });

    return hashtags;
  }

  List<String> getAllMentions(String text) {
    RegExp regexp = RegExp(r'\B@\w\w+');

    List<String> mentions = [];

    regexp.allMatches(text).forEach((element) {
      if (element.group(0) != null) {
        mentions.add(element.group(0).toString());
      }
    });

    return mentions;
  }

  String cleanText(String text) {
    text = text.replaceAllMapped(
        RegExp(r'\w#+'), (Match m) => "${m[0]?.split('').join(" ")}");

    text = text.replaceAllMapped(
        RegExp(r'\w@+'), (Match m) => "${m[0]?.split('').join(" ")}");

    return text;
  }

  RichText buildHighlightedText(String text) {
    text = cleanText(text);

    List<String> hashtags = getAllHashtags(text);
    List<String> mentions = getAllMentions(text);

    List<TextSpan> textSpans = [];

    text.split(" ").forEach((value) {
      if (hashtags.contains(value)) {
        textSpans.add(TextSpan(
          text: '$value ',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: widget.weight,
            fontSize: widget.size,
            fontFamily: GoogleFonts.nunitoSans().fontFamily
          ),
        ));
      } else if (mentions.contains(value)) {
        textSpans.add(TextSpan(
          text: '$value ',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: widget.weight,
            fontSize: widget.size,
            fontFamily: GoogleFonts.nunitoSans().fontFamily
          ),
        ));
      } else {
        print(value);
        textSpans.add(TextSpan(
          text: '$value ',
          style: TextStyle(
            fontWeight: widget.weight,
            fontSize: widget.size,
            fontFamily: GoogleFonts.nunitoSans().fontFamily,
            color: widget.color
          )
        ));
      }
    });

    return RichText(text: TextSpan(children: textSpans));
  }

  @override
  Widget build(BuildContext context){
    return buildHighlightedText(widget.text);
  }
}