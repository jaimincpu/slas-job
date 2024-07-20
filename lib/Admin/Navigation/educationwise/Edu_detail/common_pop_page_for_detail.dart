import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UserDetailsPage extends StatelessWidget {
  final String name;
  final String uid; // Received from the previous page

  const UserDetailsPage({
    required this.name,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Extracting user details from Firestore document
          final String address = userData['address'] ?? 'N/A';
          final String age = userData['age'] ?? 'N/A';
          final String phoneNo = userData['phoneNo'] ?? 'N/A';
          final String educationDetail = userData['Education detail'] ?? 'N/A';
          final String gender = userData['gender'] ?? 'N/A';
          final String workExperience = userData['workExperience'] ?? 'N/A';
          final String GovIDurl = userData['GovIDurl'] ?? 'N/A';
          final String itiMarkSheetUrl = userData['itiMarkSheetUrl'] ?? 'N/A';
          final String twelfthMarkSheetUrl =
              userData['twelfthMarkSheetUrl'] ?? 'N/A';
          final String pgUgMarkSheetUrl = userData['pgUgMarkSheetUrl'] ?? 'N/A';
          final String DiplomaMarkSheeturl =
              userData['DiplomaMarkSheeturl'] ?? 'N/A';
          final String tenMarkSheetUrl = userData['tenMarkSheetUrl'] ?? 'N/A';
           final String regnumber = (userData['REGID'] ?? 'N/A').toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Card(
                    elevation: 4.0, // Adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded edges
                    ),
                    color: Colors.blue[100], // Tile color
                    child: ListTile(
                      title: Text('Reg No: $regnumber'),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0), // Padding inside the tile
                    ),
                  ),
                  Card(
                    elevation: 4.0, // Adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Rounded edges
                    ),
                    color: Colors.blue[100], // Tile color
                    child: ListTile(
                      title: Text('Name: $name'),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0), // Padding inside the tile
                    ),
                  ),
                  //   SizedBox(height: 16.0),// Spa ce between tiles
                  // Repeat for each piece of information
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Address: $address'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Age: $age'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Phone Number: $phoneNo'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Education Detail: $educationDetail'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Gender: $gender'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.blue[100],
                    child: ListTile(
                      title: Text('Work Experience: $workExperience'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ), // ... Add more Cards for each piece of information ...
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFScreen(
                            govIDurl: GovIDurl,
                            itiMarkSheetUrl: itiMarkSheetUrl,
                            twelfthMarkSheetUrl: twelfthMarkSheetUrl,
                            pgUgMarkSheetUrl: pgUgMarkSheetUrl,
                            diplomaMarkSheetUrl: DiplomaMarkSheeturl,
                            tenMarkSheetUrl: tenMarkSheetUrl,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0, // Adds shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded edges
                      ),
                      color: Colors.blue[300], // Button color
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0), // Padding inside the button
                        child: Text('View Documents',
                            style:
                                TextStyle(color: Colors.white)), // Text style
                      ),
                    ),
                  ),
                  // ElevatedButton(onPressed: approved, child: Text('Approved')),
                  // ElevatedButton(onPressed: rejected, child: Text('Rejected')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String govIDurl;
  final String itiMarkSheetUrl;
  final String twelfthMarkSheetUrl;
  final String pgUgMarkSheetUrl;
  final String diplomaMarkSheetUrl;
  final String tenMarkSheetUrl;

  PDFScreen({
    required this.govIDurl,
    required this.itiMarkSheetUrl,
    required this.twelfthMarkSheetUrl,
    required this.pgUgMarkSheetUrl,
    required this.diplomaMarkSheetUrl,
    required this.tenMarkSheetUrl,
  });

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  late Future<File?> _pdfFile;
  late Future<File?> _itiMarkSheetFile;
  late Future<File?> _twelfthMarkSheetFile;
  late Future<File?> _pgUgMarkSheetFile;
  late Future<File?> _diplomaMarkSheetFile;
  late Future<File?> _tenMarkSheetFile;

  @override
  void initState() {
    super.initState();
    _pdfFile = fetchPDF(widget.govIDurl, 'GovID.pdf');
    _itiMarkSheetFile = fetchPDF(widget.itiMarkSheetUrl, 'itiMarkSheet.pdf');
    _twelfthMarkSheetFile =
        fetchPDF(widget.twelfthMarkSheetUrl, 'twelfthMarkSheet.pdf');
    _pgUgMarkSheetFile = fetchPDF(widget.pgUgMarkSheetUrl, 'pgUgMarkSheet.pdf');
    _diplomaMarkSheetFile =
        fetchPDF(widget.diplomaMarkSheetUrl, 'diplomaMarkSheet.pdf');
    _tenMarkSheetFile = fetchPDF(widget.tenMarkSheetUrl, 'tenMarkSheet.pdf');
  }

  Future<File?> fetchPDF(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FuturePDFViewer(futureFile: _pdfFile, fileName: 'GovID.pdf'),
            FuturePDFViewer(
                futureFile: _tenMarkSheetFile, fileName: '10 marksheet'),
            FuturePDFViewer(
                futureFile: _diplomaMarkSheetFile,
                fileName: 'diploma marksheet'),
            FuturePDFViewer(
                futureFile: _pgUgMarkSheetFile, fileName: 'PG/UG marksheet'),
            FuturePDFViewer(
                futureFile: _twelfthMarkSheetFile, fileName: '12 marksheet'),
            FuturePDFViewer(
                futureFile: _itiMarkSheetFile, fileName: 'iti marksheet'),
          ],
        ),
      ),
    );
  }
}

class FuturePDFViewer extends StatelessWidget {
  final Future<File?> futureFile;
  final String fileName;

  const FuturePDFViewer({
    Key? key,
    required this.futureFile,
    required this.fileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: futureFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('PDF not found'));
        }

        return Container(
          height: 300, // Adjust the height as needed
          child: PDFViewerPage(file: snapshot.data!, fileName: fileName),
        );
      },
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final File file;
  final String fileName;

  const PDFViewerPage({
    Key? key,
    required this.file,
    required this.fileName,
  }) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PDFViewController? controller;
  int pages = 0;
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final text = '${indexPage + 1} of $pages';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.fileName),
        actions: pages >= 2
            ? [
                Center(child: Text(text)),
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 32),
                  onPressed: () {
                    final page = indexPage == 0 ? pages : indexPage - 1;
                    controller?.setPage(page);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 32),
                  onPressed: () {
                    final page = indexPage == pages - 1 ? 0 : indexPage + 1;
                    controller?.setPage(page);
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: PDFView(
          filePath: widget.file.path,
          onRender: (pages) => setState(() => this.pages = pages!),
          onViewCreated: (controller) =>
              setState(() => this.controller = controller),
          onPageChanged: (indexPage, _) =>
              setState(() => this.indexPage = indexPage!),
        ),
      ),
    );
  }
}
