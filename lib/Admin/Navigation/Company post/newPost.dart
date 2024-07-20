

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TileListScreen extends StatefulWidget {
  @override
  _TileListScreenState createState() => _TileListScreenState();
}

class _TileListScreenState extends State<TileListScreen> {
  final _formKey = GlobalKey<FormState>();
  final companyDescriptionController = TextEditingController();
  final companyNameController = TextEditingController();
  File? _companyImage;
  DateTime? _postExpiredData;
  Timestamp _currentTimeStamp = Timestamp.now();
  bool _isLoading = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final RegCodeService _regCodeService = RegCodeService();
  
  var postID;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _companyImage != null &&
        _postExpiredData != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imageName = DateTime.now().millisecondsSinceEpoch;
        final storageRef =
            FirebaseStorage.instance.ref().child('company_images/$imageName');
        final uploadTask = storageRef.putFile(_companyImage!);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
          int postID = await _regCodeService.fetchAndIncrementPostId();

        await FirebaseFirestore.instance.collection('post').doc().set({
          'companyDescription': companyDescriptionController.text,
          'companyImage': downloadUrl,
          'companyName': companyNameController.text,
          'postExpiredData': _postExpiredData,
          'createdAt': _currentTimeStamp,
          'postID': postID,
        });
        
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully')),
        );

        companyDescriptionController.clear();
        companyNameController.clear();
        setState(() {
          _companyImage = null;
          _postExpiredData = null;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Color(0xFFA555EC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: size.width,
          color: Color(0xFFF3CCFF),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Company Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  controller: companyDescriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                    );
                    if (pickedFile != null) {
                      final fileExtension = pickedFile.path.split('.').last;
                      if (['jpg', 'jpeg', 'png']
                          .contains(fileExtension.toLowerCase())) {
                        setState(() {
                          _companyImage = File(pickedFile.path);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Only JPG, JPEG, and PNG formats are allowed.')),
                        );
                      }
                    }
                  },
                  child: _companyImage != null
                      ? Image.file(_companyImage!)
                      : Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Tap to upload image, The image size Show be in 1080*720 or smilar to this size'),
                          ),
                        ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  controller: companyNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _postExpiredData = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color(0xFFD09CFA),
                          Color(0xFFFFFFD0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: _postExpiredData != null
                        ? Text(
                            'Expiration Date: ${_postExpiredData.toString()}',
                            style: TextStyle(
                              color: Color(0xFF7776B3),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Choose Expiration Date and Time',
                                style: TextStyle(
                                  color: Color(0xFF7776B3),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ),
                SizedBox(height: 16),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text('Submit'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RegCodeService {
  int _currentNumber = 0; // Initialize with 0

  int get currentNumber => _currentNumber;

  Future<int> fetchAndIncrementPostId() async {
    // Fetch the value from Firestore (assuming it is stored as an integer)
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Unique_Code_Generate')
        .doc('post_code')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('PostID')) {
        _currentNumber = data['PostID'];
      } else {
        // If the field doesn't exist, initialize with a value of 0
        _currentNumber = 0;
      }
    } else {
      // If the document doesn't exist, initialize with a value of 0
      _currentNumber = 0;
    }

    // Increment the number
    _currentNumber++;

    // Update the document with the incremented value
    await FirebaseFirestore.instance
        .collection('Unique_Code_Generate')
        .doc('post_code')
        .set({'PostID': _currentNumber});

    return _currentNumber;
  }
}