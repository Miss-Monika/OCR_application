import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ShareFile extends StatefulWidget {
  @override
  State<ShareFile> createState() => _ShareFileState();
}

class _ShareFileState extends State<ShareFile> {
  final _controller = ScreenshotController();

  Future<void> share() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.displayName}/0.txt");

    await FlutterShare.share(
        title: 'HMI OCR Share',
        text: 'My File',
        linkUrl: (await ref.getDownloadURL()).toString(),
        chooserTitle: 'Example Chooser Title');
  }

  Future<void> shareFile() async {
    // final result = await FilePicker.platform.pickFiles();
    // final Directory directory = await getApplicationDocumentsDirectory();
    // final File result = File('${directory.path}/my_file.txt');
    var data = await FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.displayName}")
        .listAll();
    data.items.forEach(
      (element) async => {
        print("here it is"),
        await FlutterShare.shareFile(
          title: 'Example share',
          text: 'Example share text',
          filePath: element.fullPath,
        ),
      },
    );
    // final result = await ImagePicker.pickImage(
    //   source: ImageSource.gallery,
    //   maxWidth: 600,
    // );
    // print(result);
    // if (result == null) return null;

    // await FlutterShare.shareFile(
    //   title: 'Example share',
    //   text: 'Example share text',
    //   filePath: result.path,
    // );
  }

  // I/flutter (15908): File: '/storage/emulated/0/Android/data/com.example.ocr_application/files/Pictures/scaled_20220408_223025.jpg'
  Future<void> shareScreenshot() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final String localPath =
        '${directory!.path}/${DateTime.now().toIso8601String()}.png';

    await _controller.captureAndSave(localPath);

    await Future.delayed(Duration(seconds: 1));

    await FlutterShare.shareFile(
        title: 'Compartilhar comprovante',
        filePath: localPath,
        fileType: 'image/png');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Screenshot(
            controller: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: Text('Share text and link'),
                  onPressed: share,
                ),
                TextButton(
                  child: Text('Share local file'),
                  onPressed: shareFile,
                ),
                TextButton(
                  child: Text('Share screenshot'),
                  onPressed: shareScreenshot,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
