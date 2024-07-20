import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDetail extends StatefulWidget {
  final String uid;

  CompanyDetail({required this.uid});

  @override
  _CompanyDetailState createState() => _CompanyDetailState();
}

class _CompanyDetailState extends State<CompanyDetail> {
  late TextEditingController _companyNameController;
  late TextEditingController _companyDescriptionController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _companyDescriptionController = TextEditingController();
    loadData();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  void loadData() {
    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          _companyNameController.text =
              data['companyName'] ?? 'No Company Name';
          _companyDescriptionController.text =
              data['companyDescription'] ?? 'No Description';
        });
      }
    }).catchError((error) {
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Detail'),
        backgroundColor: Color(0xFFA555EC),
      ),
      body: Container(
        color: Color(0xFFF9E6FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _companyDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Company Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        // Delete button action
                        FirebaseFirestore.instance
                            .collection('post')
                            .doc(widget.uid)
                            .delete()
                            .then((value) => Navigator.pop(context))
                            .catchError(
                                (error) => print('Delete failed: $error'));
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD09CFA), Color(0xFFFFFFD0)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Color(0xFF7776B3),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Color(0xFF7776B3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        // Update button action
                        String companyName = _companyNameController.text.trim();
                        String companyDescription =
                            _companyDescriptionController.text.trim();

                        FirebaseFirestore.instance
                            .collection('post')
                            .doc(widget.uid)
                            .update({
                              'companyName': companyName,
                              'companyDescription': companyDescription,
                            })
                            .then((value) => Navigator.pop(context))
                            .catchError(
                                (error) => print('Update failed: $error'));
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD09CFA), Color(0xFFFFFFD0)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Color(0xFF7776B3),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Update',
                                style: TextStyle(
                                  color: Color(0xFF7776B3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
