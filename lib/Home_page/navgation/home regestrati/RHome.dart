import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../login/login_page.dart';
import '../../HomeDashBoard.dart';

class RHome extends StatefulWidget {
  @override
  _RHomeState createState() => _RHomeState();
}

class _RHomeState extends State<RHome> {
  int _selectedEXPOption = 0;
  final _workExpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _alterPhoneNoController = TextEditingController();
  File? _profilePhoto;
  bool _isMale = true;
  bool _isHours = true;
  int _selectedDocIndex = 0;
  File? _tenMarkSheet;
  File? _itiMarkSheet;
  File? _twelfthMarkSheet;
  File? _pgUgMarkSheet;
  File? _govID;
  bool _isLoading = false;
  String? _selectedField = '10 passed';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final profilePhoto = File(pickedFile.path);
      if (_checkFileSize(profilePhoto.path)) {
        setState(() {
          _profilePhoto = profilePhoto;
        });
      } else {
        _showSnackBar('File size exceeds 1 MB or no file selected.');
      }
    }
  }

  bool _checkFileSize(String path, {int sizeLimit = 1000000}) {
    var file = File(path);
    var fileSize = file.lengthSync();
    return fileSize <= sizeLimit;
  }

  Future<void> _pickDocument(Function(File?) onPicked,
      {int sizeLimit = 1500000}) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.lengthSync() <= sizeLimit) {
        onPicked(file);
      } else {
        _showSnackBar('File size exceeds 1.5 MB or no file selected.');
      }
    }
  }

  Future<void> _pickTenMarkSheet() async =>
      _pickDocument((file) => setState(() => _tenMarkSheet = file));
  Future<void> _pickITIMarkSheet() async =>
      _pickDocument((file) => setState(() => _itiMarkSheet = file));
  Future<void> _pickTwelfthMarkSheet() async =>
      _pickDocument((file) => setState(() => _twelfthMarkSheet = file));
  Future<void> _pickPgUgMarkSheet() async =>
      _pickDocument((file) => setState(() => _pgUgMarkSheet = file));
  Future<void> _pickGovID() async =>
      _pickDocument((file) => setState(() => _govID = file));

  Future<String> _uploadFile(String path, File file) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await ref.putFile(
        file, SettableMetadata(customMetadata: {'timestamp': '$timestamp'}));
    return await ref.getDownloadURL();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final timestamp = Timestamp.now();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Map<String, dynamic> dataToUpdate = {
          'address': _addressController.text,
          'age': _ageController.text,
          'gender': _isMale ? 'Male' : 'Female',
          'phoneNo': _phoneNoController.text,
          'alterPhoneNo': _alterPhoneNoController.text,
          'workExperience': _workExpController.text,
          'Education detail': _selectedField,
          'jobHours': _isHours ? '8 Hours' : '12 Hours',
          'Reg': 'YES',
          'createdAt': timestamp,
        };

        if (_profilePhoto != null)
          dataToUpdate['profilePhotoUrl'] = await _uploadFile(
              'profile_photos/${user.uid}.jpg', _profilePhoto!);
        if (_tenMarkSheet != null)
          dataToUpdate['tenMarkSheetUrl'] = await _uploadFile(
              'documents/${user.uid}_tenMarkSheet.${_tenMarkSheet!.path.split('.').last}',
              _tenMarkSheet!);
        if (_itiMarkSheet != null)
          dataToUpdate['itiMarkSheetUrl'] = await _uploadFile(
              'documents/${user.uid}_itiMarkSheet.${_itiMarkSheet!.path.split('.').last}',
              _itiMarkSheet!);
        if (_twelfthMarkSheet != null)
          dataToUpdate['twelfthMarkSheetUrl'] = await _uploadFile(
              'documents/${user.uid}_twelfthMarkSheet.${_twelfthMarkSheet!.path.split('.').last}',
              _twelfthMarkSheet!);
        if (_pgUgMarkSheet != null)
          dataToUpdate['pgUgMarkSheetUrl'] = await _uploadFile(
              'documents/${user.uid}_pgUgMarkSheet.${_pgUgMarkSheet!.path.split('.').last}',
              _pgUgMarkSheet!);
        if (_govID != null)
          dataToUpdate['govIDUrl'] = await _uploadFile(
              'documents/${user.uid}_govID.${_govID!.path.split('.').last}',
              _govID!);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(dataToUpdate);
        _showSnackBar('Data saved successfully!');

// Navigate to the login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeDashboard()), // Replace with your login page
          (route) => false, // Always return false to remove all previous routes
        );
      } else {
        _showSnackBar('No user logged in!');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleDocSelection(int? index) {
    if (index != null) {
      setState(() {
        _selectedDocIndex = index;
      });
    }
  }

  Widget _buildDocPicker(
      String label, File? file, Function() onPick, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        file != null
            ? Text('$label selected: ${file.path.split('/').last}')
            : Text('No $label selected, only PDF are allowed.'),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: enabled ? onPick : null,
          child: Text('Pick $label'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEducationSelected(String level) => _selectedField == level;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27374D), // Set your desired background color
        title: Text(
          'User Form',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Replace with your login page
                  (route) =>
                      false, // Always return false to remove all previous routes
                );
              } catch (e) {
                _showSnackBar('Error signing out: $e');
              }
            },
            icon: Icon(Icons.logout, color: Colors.white,),
          ),
        ],
      ),
        backgroundColor: Color(0xFFDDE6ED),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _profilePhoto != null
                          ? Image.file(_profilePhoto!)
                          : Text('Select a profile photo'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: Text('Pick Photo'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide()),
                          labelText: 'Address',
                          hintText: 'Enter your address',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide()),
                          labelText: 'Age',
                          hintText: 'Enter your age',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Gender: '),
                          Text('Male'),
                          Switch(
                            value: !_isMale,
                            onChanged: (value) =>
                                setState(() => _isMale = !value),
                          ),
                          Text('Female'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _phoneNoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide()),
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _alterPhoneNoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide()),
                          labelText: 'Alternate Phone Number',
                          hintText: 'Enter an alternate phone number',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an alternate phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Please select the experienced "),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ToggleSwitch(
                        initialLabelIndex: _selectedEXPOption,
                        labels: ['Fresher', 'Experienced'],
                        onToggle: (index) {
                          setState(() {
                            _selectedEXPOption = index!;
                            _workExpController.text = _selectedEXPOption == 0
                                ? 'Fresher'
                                : 'Experienced';
                          });
                        },
                      ),
                    ),
                    if (_selectedEXPOption ==
                        1) // Display only for experienced users
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _workExpController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(),
                            ),
                            labelText: 'Work Experience',
                            hintText: 'Enter your work experience',
                          ),
                          validator: (value) {
                            if (value!.isEmpty && _selectedEXPOption == 1) {
                              return 'Please enter your work experience';
                            }
                            return null;
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Please select the Job Hours"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ToggleSwitch(
                        initialLabelIndex: _selectedDocIndex,
                        labels: ['8 Hours', '12 Hours'],
                        onToggle: (index) {
                          setState(() {
                            _selectedDocIndex = index!;
                            _isHours = index == 0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedField,
                        items: [
                          '10 passed',
                          'ITI',
                          '12th passed',
                          'Graduation',
                          'Post Graduation'
                        ]
                            .map((field) => DropdownMenuItem(
                                value: field, child: Text(field)))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedField = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide()),
                          labelText: 'Education',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your highest education';
                          }
                          return null;
                        },
                      ),
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (isEducationSelected('10 passed') ||
                            isEducationSelected('12th passed') ||
                            isEducationSelected('Graduation') ||
                            isEducationSelected('Post Graduation')) {
                          if (_tenMarkSheet == null) {
                            return 'Please upload the 10 Mark Sheet';
                          }
                        }
                        return null;
                      },
                      builder: (formFieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocPicker(
                              '10 Mark Sheet',
                              _tenMarkSheet,
                              _pickTenMarkSheet,
                              isEducationSelected('10 passed') ||
                                  isEducationSelected('12th passed') ||
                                  isEducationSelected('Graduation') ||
                                  isEducationSelected('Post Graduation'),
                            ),
                            if (formFieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formFieldState.errorText ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (isEducationSelected('ITI')) {
                          if (_itiMarkSheet == null) {
                            return 'Please upload the ITI Mark Sheet';
                          }
                        }
                        return null;
                      },
                      builder: (formFieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocPicker(
                              'ITI Mark Sheet',
                              _itiMarkSheet,
                              _pickITIMarkSheet,
                              isEducationSelected('ITI'),
                            ),
                            if (formFieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formFieldState.errorText ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (isEducationSelected('12th passed') ||
                            isEducationSelected('Graduation') ||
                            isEducationSelected('Post Graduation')) {
                          if (_twelfthMarkSheet == null) {
                            return 'Please upload the 12th Mark Sheet';
                          }
                        }
                        return null;
                      },
                      builder: (formFieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocPicker(
                              '12th Mark Sheet',
                              _twelfthMarkSheet,
                              _pickTwelfthMarkSheet,
                              isEducationSelected('12th passed') ||
                                  isEducationSelected('Graduation') ||
                                  isEducationSelected('Post Graduation'),
                            ),
                            if (formFieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formFieldState.errorText ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (isEducationSelected('Graduation') ||
                            isEducationSelected('Post Graduation')) {
                          if (_pgUgMarkSheet == null) {
                            return 'Please upload the Graduation/Post Graduation Mark Sheet';
                          }
                        }
                        return null;
                      },
                      builder: (formFieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocPicker(
                              'Graduation/Post Graduation Mark Sheet',
                              _pgUgMarkSheet,
                              _pickPgUgMarkSheet,
                              isEducationSelected('Graduation') ||
                                  isEducationSelected('Post Graduation'),
                            ),
                            if (formFieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formFieldState.errorText ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (isEducationSelected('10 passed') ||
                            isEducationSelected('ITI') ||
                            isEducationSelected('12th passed') ||
                            isEducationSelected('Graduation') ||
                            isEducationSelected('Post Graduation')) {
                          if (_govID == null) {
                            return 'Please upload a Government ID';
                          }
                        }
                        return null;
                      },
                      builder: (formFieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocPicker(
                              'Government ID',
                              _govID,
                              _pickGovID,
                              isEducationSelected('10 passed') ||
                                  isEducationSelected('ITI') ||
                                  isEducationSelected('12th passed') ||
                                  isEducationSelected('Graduation') ||
                                  isEducationSelected('Post Graduation'),
                            ),
                            if (formFieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formFieldState.errorText ?? '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitForm,
                              child: Text('Submit'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
