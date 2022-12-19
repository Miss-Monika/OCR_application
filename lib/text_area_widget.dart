import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClickedCopy;

  const TextAreaWidget({
    required this.text,
    required this.onClickedCopy,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        // floatingActionButton: Container(
        //   child: Align(
        //     alignment: Alignment.bottomRight,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        // FloatingActionButton(
        //   backgroundColor: Colors.black,
        //   shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(15.0))),
        //   onPressed: onClickedCopy,
        //   child: Icon(Icons.copy, color: Colors.white),
        // ),
        //         // SizedBox(width: 10),
        //         // FloatingActionButton(
        //         //   backgroundColor: Colors.black,
        //         //   shape: RoundedRectangleBorder(
        //         //       borderRadius: BorderRadius.all(Radius.circular(15.0))),
        //         //   onPressed: () async {},
        //         //   child: Icon(
        //         //     Icons.photo,
        //         //   ),
        //         // ),
        //         // FloatingActionButton(
        //         //   onPressed: () {},
        //         //   child: Icon(
        //         //     Icons.photo_album_rounded,
        //         //   ),
        //         // ),
        //       ],
        //     ),
        //   ),
        // ),
        body: Row(
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                // height: 100,
                decoration: BoxDecoration(border: Border.all()),
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                child: SelectableText(
                  text.isEmpty ? 'Press Scan for Text to get text' : text,
                  // textAlign: TextAlign.center,
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            // IconButton(
            //   icon: Icon(Icons.copy, color: Colors.black),
            //   color: Colors.grey[200],
            //   onPressed: onClickedCopy,
            // ),
          ],
        ),
      );
}
