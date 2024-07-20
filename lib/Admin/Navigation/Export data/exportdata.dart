import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

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
      cell.value = headers[i];
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

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/UserDetails.xlsx');

    await file.writeAsBytes(uint8listBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to ${file.path}')),
    );

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
