import 'package:flutter/material.dart';

class ClickableSearchWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? text;
  final Widget? prefixIcon;


  const ClickableSearchWidget({Key? key, this.onTap, this.text,this.prefixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: prefixIcon ?? const Icon(Icons.search, color: Colors.grey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text ?? "Search",
                    style: TextStyle(
                        color: text != null ? Colors.black : Colors.grey,
                        fontSize: text != null ? 16 : 18),
                  )
                ],
              )
            ]),
          )),
    );
  }
}
