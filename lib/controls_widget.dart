import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr_application/firebase_ml_api.dart';
import 'package:ocr_application/textToSpeech.dart';

class ControlsWidget extends StatelessWidget {
  File? image;
  final VoidCallback onClickedPickImage;
  final VoidCallback onClickedScanText;
  final VoidCallback onClickedClear;

  ControlsWidget({
    required this.image,
    required this.onClickedPickImage,
    required this.onClickedScanText,
    required this.onClickedClear,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            // onPressed: onClickedPickImage,
            onPressed: () async {
              final text = await FirebaseMLApi.recogniseText(image!);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TextToSpeech(
                            newVoiceText: text.toString(),
                          )));
            },
            child: Text('Text to Audio', style: TextStyle(color: Colors.white)),
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
          const SizedBox(width: 12),
          RaisedButton(
            onPressed: onClickedScanText,
            child: Text('Scan for Text', style: TextStyle(color: Colors.white)),
            color: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
          const SizedBox(width: 12),
          // RaisedButton(
          //   onPressed: onClickedClear,
          //   child: Text('Clear'),
          // )
        ],
      );
}
