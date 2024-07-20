import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../login/login_page.dart';

class LUserDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'N/A';

    final Color primaryColor = Color(0xFF27374D);
    final Color backgroundColor = Color(0xFFDDE6ED);
    final Color textColor = Colors.white;
    final Color buttonColor = Color(0xFF526D82);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details',
            textAlign: TextAlign.center, style: TextStyle(color: textColor)),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Navigate to the login screen (replace with your actual route)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false, // Remove all previous routes from the stack
                );
              } catch (e) {
                // Show an error snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out. Please try again.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: Icon(Icons.logout, color: textColor),
          )
        ],
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
          final String name = userData['name'] ?? 'N/A';
          final String address = userData['address'] ?? 'N/A';
          final String age = userData['age'] ?? 'N/A';
          final String phoneNo = userData['phoneNo'] ?? 'N/A';
          final String AlterphoneNo = userData['alterPhoneNo'] ?? 'N/A';
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
          final String profilePhotoUrl = userData['profilePhotoUrl'] ?? '';
           final String regnumber = (userData['REGID'] ?? 'N/A').toString();

          return Container(
            color: backgroundColor,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (profilePhotoUrl.isNotEmpty)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profilePhotoUrl),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         UserInfoText(
                            title: 'Reg No', content: regnumber, textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Name', content: name, textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Address',
                            content: address,
                            textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Age', content: age, textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Phone Number',
                            content: phoneNo,
                            textColor: textColor),
                            SizedBox(height: 8),
                        UserInfoText(
                            title: 'Alternate Phone Number',
                            content: AlterphoneNo,
                            textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Education Detail',
                            content: educationDetail,
                            textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Gender',
                            content: gender,
                            textColor: textColor),
                        SizedBox(height: 8),
                        UserInfoText(
                            title: 'Work Experience',
                            content: workExperience,
                            textColor: textColor),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: textColor,
                        backgroundColor: buttonColor,
                      ),
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
                      child: Text('View Documents'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserInfoText extends StatelessWidget {
  final String title;
  final String content;
  final Color textColor;

  const UserInfoText({
    required this.title,
    required this.content,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title: $content',
      style: TextStyle(color: textColor, fontSize: 16),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final VoidCallback onPressed;

  const CustomTextButton({
    required this.label,
    required this.primaryColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
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
