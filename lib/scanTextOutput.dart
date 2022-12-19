// import 'dart:convert';

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_application/firebase_api.dart';
import 'package:ocr_application/firebase_ml_api.dart';
import 'package:ocr_application/index.dart';
import 'package:ocr_application/main.dart';
import 'package:ocr_application/temp.dart';
import 'package:ocr_application/tempharshi.dart';
import 'package:ocr_application/tempharshi2.dart';
import 'package:ocr_application/text_area_widget.dart';
import 'package:ocr_application/text_recognisation_widget.dart';
import 'package:ocr_application/userProfile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'save_file_mobile.dart' if (dart.library.html) 'save_file_web.dart';
import 'package:intl/intl.dart';

// import 'dart:html' as html;

class ScanTextOutput extends StatefulWidget {
  String text;
  ScanTextOutput({required this.text});
  // const ScanTextOutput({Key? key}) : super(key: key);

  @override
  State<ScanTextOutput> createState() => _ScanTextOutputState();
}

class _ScanTextOutputState extends State<ScanTextOutput> {
  int counter = 0;
  String path = "";

  bool _isDownloadDone = false;

  late String scannedText;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _searchValue;

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final File file = File('${directory.path}/my_file.txt');
    print(file);
    await file.writeAsString(text);

    var data = await FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.displayName}")
        .listAll();
    data.items.forEach(
      (element) => {
        print("here it is"),
        setState(() {
          counter = counter + 1;
        }),
      },
    );
    final destination =
        '${FirebaseAuth.instance.currentUser!.displayName}/$counter.txt';

    final task = FirebaseApi.uploadFile(destination, file);

    final snapshot = await task!.whenComplete(() => {
          print("done"),
        });
    final urlDownload = await snapshot.ref.getDownloadURL();
    _download(urlDownload);
    setState(() {
      counter = 0;
    });
    // _download('https://i.imgur.com/YhT0HJ2.jpg');

    // _download('${directory.path}/my_file.txt');
    // _download('assets/test.png');
  }
  // static var httpClient = new HttpClient();
  // Future<File> _downloadFile(String url, String filename) async {
  //   var request = await httpClient.getUrl(Uri.parse(url));
  //   var response = await request.close();
  //   var bytes = await consolidateHttpClientResponseBytes(response);
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   File file = new File('$dir/$filename');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }

  void copyToClipboard() {
    if (widget.text.trim() != '') {
      FlutterClipboard.copy(widget.text);
    }
  }

  Future<void> generateInvoice() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result = drawHeader(page, pageSize, grid);
    //Draw grid
    // drawGrid(page, grid, result);
    //Add invoice footer
    drawFooter(page, pageSize);
    //Save the PDF document
    final List<int> bytes = document.save();
    //Dispose the document.
    document.dispose();
    //Save and launch the file.
    await saveAndLaunchFile(bytes, 'Invoice.pdf');
  }

  //Draws the invoice header
  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'Extracted PDF', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    // page.graphics.drawRectangle(
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
    //     brush: PdfSolidBrush(PdfColor(65, 104, 205)));

    // page.graphics.drawString(r'$' + getTotalAmount(grid).toString(),
    //     PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
    //     brush: PdfBrushes.white,
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    // page.graphics.drawString('Amount', contentFont,
    //     brush: PdfBrushes.white,
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.bottom));
    //Create data foramt and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    final String invoiceNumber = 'Date: ${format.format(DateTime.now())}';
    final Size contentSize = contentFont.measureString(invoiceNumber);
    // ignore: leading_newlines_in_multiline_strings
    String address = '''${widget.text}''';
    // String address = '''Test''';

    PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));

    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(
            50, 120, pageSize.width + 30, pageSize.height - 120))!;
  }

  //Draws the grid
  // void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
  //   Rect? totalPriceCellBounds;
  //   Rect? quantityCellBounds;
  //   //Invoke the beginCellLayout event.
  //   grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
  //     final PdfGrid grid = sender as PdfGrid;
  //     if (args.cellIndex == grid.columns.count - 1) {
  //       totalPriceCellBounds = args.bounds;
  //     } else if (args.cellIndex == grid.columns.count - 2) {
  //       quantityCellBounds = args.bounds;
  //     }
  //   };
  //   //Draw the PDF grid and get the result.
  //   result = grid.draw(
  //       page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

  //   //Draw grand total.
  //   page.graphics.drawString('Grand Total',
  //       PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
  //       bounds: Rect.fromLTWH(
  //           quantityCellBounds!.left,
  //           result.bounds.bottom + 10,
  //           quantityCellBounds!.width,
  //           quantityCellBounds!.height));
  //   page.graphics.drawString(getTotalAmount(grid).toString(),
  //       PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
  //       bounds: Rect.fromLTWH(
  //           totalPriceCellBounds!.left,
  //           result.bounds.bottom + 10,
  //           totalPriceCellBounds!.width,
  //           totalPriceCellBounds!.height));
  // }

  //Draw the invoice footer data.
  void drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));

    const String footerContent =
        // ignore: leading_newlines_in_multiline_strings
        '''Created with <3 at IITJ''';

    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  //Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Product Id';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Quantity';
    headerRow.cells[4].value = 'Total';
    // //Add rows
    // addProducts('CA-1098', 'AWC Logo Cap', 8.99, 2, 17.98, grid);
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 3, 149.97, grid);
    // addProducts('So-B909-M', 'Mountain Bike Socks,M', 9.5, 2, 19, grid);
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 4, 199.96, grid);
    // addProducts('FK-5136', 'ML Fork', 175.49, 6, 1052.94, grid);
    // addProducts('HL-U509', 'Sports-100 Helmet,Black', 34.99, 1, 34.99, grid);
    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }
// You need to import these 2 libraries besides another libraries to work with this code

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void _download(String url) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        fileName:
            "OCR_Download ${FirebaseAuth.instance.currentUser!.displayName}.txt",
        showNotification: true,
        openFileFromNotification: true,
      );
      setState(() {
        _isDownloadDone = true;
        Timer(Duration(seconds: 3), () {
          _isDownloadDone = false;
        });
      });
    } else {
      print('Permission Denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "1",
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                onPressed: copyToClipboard,
                child: Icon(Icons.copy, color: Colors.white),
              ),
              SizedBox(width: 10),

              FloatingActionButton(
                heroTag: "2",
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                onPressed: generateInvoice,
                child: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                heroTag: "3",
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                onPressed: () async {
                  _write(widget.text);
                  // final status = await Permission.storage.request();
                  // if (status.isGranted) {
                  //   final externalDir = await getExternalStorageDirectory();
                  //   final id = await FlutterDownloader.enqueue(
                  //     // url:
                  //     //     "https://firebasestorage.googleapis.com/v0/b/storage-3cff8.appspot.com/o/2020-05-29%2007-18-34.mp4?alt=media&token=841fffde-2b83-430c-87c3-2d2fd658fd41",
                  //     url: "https://i.imgur.com/YhT0HJ2.jpg",
                  //     savedDir: externalDir!.path,
                  //     fileName: "download",
                  //     showNotification: true,
                  //     openFileFromNotification: true,
                  //   );
                  // }
                },
                child: !_isDownloadDone
                    ? Icon(Icons.download, color: Colors.white)
                    : Icon(Icons.download_done, color: Colors.white),
              ),
              // FloatingActionButton(
              //   onPressed: () {},
              //   child: Icon(
              //     Icons.photo_album_rounded,
              //   ),
              // ),
              SizedBox(width: 10),

              FloatingActionButton(
                heroTag: "4",
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                onPressed: () async {
                  await FlutterShare.share(
                      title: 'HMI OCR Share',
                      text: widget.text,
                      // linkUrl: (await ref.getDownloadURL()).toString(),
                      chooserTitle: 'Example Chooser Title');
                },
                child: Icon(Icons.share, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(
                child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    "Your scanned text",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Container(
                  //   height: 46,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade200,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Form(
                  //     key: _formKey,
                  //     child: TextFormField(
                  //       validator: (input) {
                  //         if (input != null && input.isEmpty)
                  //           return "Search Something";
                  //       },
                  //       cursorColor: Colors.black,
                  //       decoration: InputDecoration(
                  //         prefixIcon: Icon(
                  //           Icons.search,
                  //           color: Colors.grey.shade700,
                  //         ),
                  //         border: InputBorder.none,
                  //         hintText: "Search ",
                  //         hintStyle: TextStyle(color: Colors.grey.shade500),
                  //       ),
                  //       onSaved: (input) => _searchValue = input!,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ))
          ];
        },
        body: Container(
          child: TextAreaWidget(
            text: widget.text,
            onClickedCopy: copyToClipboard,
          ),
        ),
        // body: Container(
        //   child: ListView.builder(
        //     scrollDirection: Axis.vertical,
        //     shrinkWrap: true,
        //     itemCount: 1,
        //     itemBuilder: (BuildContext context, int ScanTextOutput) {
        //       return Card(
        //         elevation: 8.0,
        //         margin:
        //             new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        //         // shape: ,
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(
        //               10,
        //             ),
        //           ),
        //           child: ListTile(
        //             contentPadding:
        //                 EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        //             leading: Container(
        //               padding: EdgeInsets.only(right: 12.0),
        //               decoration: new BoxDecoration(
        //                   // borderRadius: BorderRadius.circular(
        //                   //           50,
        //                   //         ),
        //                   border: new Border(
        //                       right: new BorderSide(
        //                           width: 1.0, color: Colors.black))),
        //               child: Icon(Icons.autorenew, color: Colors.black),
        //             ),
        //             title: Text(
        //               "Document",
        //               style: TextStyle(
        //                   color: Colors.black, fontWeight: FontWeight.bold),
        //             ),
        //             // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        //             subtitle: Row(
        //               children: <Widget>[
        //                 Icon(Icons.linear_scale, color: Colors.black),
        //                 Text("Date", style: TextStyle(color: Colors.black))
        //               ],
        //             ),
        //             trailing: Icon(Icons.keyboard_arrow_right,
        //                 color: Colors.black, size: 30.0),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ),
      bottomNavigationBar: Container(
        height: 55.0,
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home, color: Colors.black),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Index()));
                },
              ),
              // IconButton(
              //   icon: Icon(Icons.camera_alt_rounded, color: Colors.black),
              //   onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => HomePage()));
              //   },
              // ),
              // IconButton(
              //   icon: Icon(Icons.photo, color: Colors.black),
              //   onPressed: () {},
              // ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompleteProfileScreen()));
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  showAlertDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    // Widget logOutButton = SalomonBottomBarItem(
    //   icon: Icon(Icons.logout),
    //   title: Text("LogOut"),
    //   selectedColor: Colors.redAccent,
    // );
    Widget okButton = TextButton(
      child: Text("Logout"),
      onPressed: () {
        _auth.signOut();
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LandingPage()),
            (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout Alert!!"),
      content: Text("Are you sure you want to logout?"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
