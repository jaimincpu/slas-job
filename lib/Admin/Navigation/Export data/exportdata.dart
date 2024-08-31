import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

class ExportData extends StatefulWidget {
  @override
  _ExportDataState createState() => _ExportDataState();
}

class _ExportDataState extends State<ExportData> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  double _progress = 0.0;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          _startDateController.text = pickedDate.toLocal().toString().split(' ')[0];
        } else {
          _endDate = pickedDate;
          _endDateController.text = pickedDate.toLocal().toString().split(' ')[0];
        }
      });
    }
  }

  Future<void> generateExcel() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['UserDetails'];

    // Headers (Title Row)
    var headers = [
      'name',
      'email',
      'phoneNo',
      'alterPhoneNo',
      'address',
      'age',
      'gender',
      'jobHours',
      'workExperience',
      'Education detail',
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i] as CellValue?;
    }

    // Fetch and populate data
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    int rowIndex = 1;
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('createdAt')) {
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        if (createdAt.isAfter(_startDate!) && createdAt.isBefore(_endDate!)) {
          for (var j = 0; j < headers.length; j++) {
            var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
            cell.value = data[headers[j]];
          }
          rowIndex++;
        }
      }
    }

    final List<int> bytes = excel.encode()!;
    final Uint8List uint8listBytes = Uint8List.fromList(bytes);

    // Upload the file to Firebase Storage
    String fileName = 'UserDetails_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    Reference storageReference = FirebaseStorage.instance.ref().child('export_data/$fileName');

    try {
      UploadTask uploadTask = storageReference.putData(uint8listBytes);
      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        });
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Store file metadata in Firestore
      await FirebaseFirestore.instance.collection('export_data').add({
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }

    setState(() {
      _isLoading = false;
      _progress = 1.0;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Data to Excel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _startDateController, true),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _endDateController, false),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _isLoading ? null : generateExcel,
                    child: Text('Export to Excel'),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ExportData()));
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class ExportData extends StatefulWidget {
//   @override
//   _ExportDataState createState() => _ExportDataState();
// }

// class _ExportDataState extends State<ExportData> {
//   Future<void> fetchAndExportData() async {
//     try {
//       // Fetch data from Firestore collection
//       final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

//       // Create a new Excel document
//       final Excel excel = Excel.createExcel();
//       final Sheet sheetObject = excel['UserDetails'];

//       // Define column headers
//       final List<String> headers = [
//         'name',
//         'email',
//         'phoneNo',
//         'alterPhoneNo',
//         'address',
//         'age',
//         'gender',
//         'jobHours',
//         'workExperience',
//         'Education detail',
//       ];

//       // Add headers to Excel sheet
//       sheetObject.appendRow(headers.cast<CellValue?>());

//       // Add data to Excel
//       for (final doc in snapshot.docs) {
//         final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         sheetObject.appendRow([
//           data['name'] ?? '',
//           data['email'] ?? '',
//           data['phoneNo'] ?? '',
//           data['alterPhoneNo'] ?? '',
//           data['address'] ?? '',
//           data['age'] ?? '',
//           data['gender'] ?? '',
//           data['jobHours'] ?? '',
//           data['workExperience'] ?? '',
//           data['Education detail'] ?? '',
//         ]);
//       }

//       // Get app directory and create a folder for the app
//       final Directory appDocDir = await getApplicationDocumentsDirectory();
//       final String appDocPath = appDocDir.path;
//       final String folderPath = '$appDocPath/YourAppName';
//       await Directory(folderPath).create(recursive: true);

//       // Save the file
//       final String filePath = '$folderPath/your_data.xlsx';
//       File(filePath)
//         ..createSync(recursive: true)
//         ..writeAsBytesSync(excel.encode()!);

//       // Display a success message to the user
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data exported successfully to $filePath')));
//     } catch (e) {
//       print('Error fetching data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export data')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Export Data')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: fetchAndExportData,
//           child: Text('Export to Excel'),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(home: ExportData()));
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class FirestoreToExcelEmailPage extends StatefulWidget {
//   @override
//   _FirestoreToExcelEmailPageState createState() =>
//       _FirestoreToExcelEmailPageState();
// }

// class _FirestoreToExcelEmailPageState extends State<FirestoreToExcelEmailPage> {
//   final String smtpServerAddress = 'smtp.gmail.com';
//   final String email = 'slasgroup7381@gmail.com';
//   final String password = 'zdbpbkftivduorru';
//   final String recipientEmail = 'pateljaimin325@gmail.com';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Export Data to Excel'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _exportDataAndSendEmail,
//           child: Text('Export and Send Email'),
//         ),
//       ),
//     );
//   }
//   Future<void> _exportDataAndSendEmail() async {
//     try {
//       List<Map<String, dynamic>> data = await _fetchDataFromFirestore();
//       Uint8List excelBytes = _createExcel(data);
//       await _sendEmailWithAttachment(excelBytes, 'FirestoreData.xlsx');
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> _fetchDataFromFirestore() async {
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('users').get();
//     return querySnapshot.docs
//         .map((doc) => doc.data() as Map<String, dynamic>)
//         .toList();
//   }

//   Uint8List _createExcel(List<Map<String, dynamic>> data) {
//     final workbook = xls.Workbook();
//     final worksheet = workbook.worksheets[0];

//     // Adding column headers
//     if (data.isNotEmpty) {
//       List<String> headers = data.first.keys.toList();
//       for (int i = 0; i < headers.length; i++) {
//         worksheet.getCell(0, i).value = headers[i];
//       }

//       // Adding rows with data
//       for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
//         final row = data[rowIndex];
//         for (int colIndex = 0; colIndex < headers.length; colIndex++) {
//           final header = headers[colIndex];
//           worksheet.getCell(rowIndex + 1, colIndex).value = row[header]?.toString() ?? '';
//         }
//       }
//     }

//     final List<int> bytes = workbook.saveAsStream();
//     workbook.dispose();

//     return Uint8List.fromList(bytes);
//   }

//   Future<void> _sendEmailWithAttachment(Uint8List excelBytes, String fileName) async {
//     final smtpServer = SmtpServer(smtpServerAddress,
//         username: email,
//         password: password);

//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/$fileName');
//     await file.writeAsBytes(excelBytes);

//     final message = Message()
//       ..from = Address(email, 'Firestore Data Service')
//       ..recipients.add(recipientEmail)
//       ..subject = 'Firestore Data Excel Sheet'
//       ..text = 'Please find the attached Excel sheet containing the Firestore data.'
//       ..attachments.add(
//         FileAttachment(file),
//       );

//     try {
//       final sendReport = await send(message, smtpServer);
//       print('Message sent: ' + sendReport.toString());
//     } on MailerException catch (e) {
//       print('Message not sent. \n${e.toString()}');
//     }
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: FirestoreToExcelEmailPage(),
//   ));
// }