import 'package:flutter/material.dart';

class ClickableSearchWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? text;

  const ClickableSearchWidget({Key? key, this.onTap, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 16),
              Text(
                text ?? "Search",
                style: TextStyle(
                    color: text != null ? Colors.black : Colors.grey,
                    fontSize: 18),
              )
            ]),
          )),
    );
  }
}
