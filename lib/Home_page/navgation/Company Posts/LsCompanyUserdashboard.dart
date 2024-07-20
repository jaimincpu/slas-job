import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardDEtail extends StatelessWidget {
  final String uid;

  DashboardDEtail({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Discription'),
        backgroundColor: Color(0xFF27374D),
      ),
      backgroundColor: Color(0xFFDDE6ED),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('post').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data found.'));
          } else {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var companyName = data['companyName'] ?? 'No Company Name';
            var companyDescription =
                data['companyDescription'] ?? 'No Description';

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color(0xFF526D82),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      companyDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Get the current user's UID
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final userUid = currentUser?.uid;

                        if (userUid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No user is currently signed in.'),
                            ),
                          );
                          return;
                        }

                        // Fetch the user's name from Firestore
                        final userDocRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(userUid);
                        final userDocSnapshot = await userDocRef.get();

                        if (!userDocSnapshot.exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'User information not found in Firestore.'),
                            ),
                          );
                          return;
                        }

                        final userName =
                            userDocSnapshot.data()?['name'] ?? 'Unknown User';

                        // Check if the user has already applied
                        final companyDocRef = FirebaseFirestore.instance
                            .collection('post')
                            .doc(uid);
                        final subcollectionRef =
                            companyDocRef.collection('userApplications');
                        final userApplicationDocRef =
                            subcollectionRef.doc(userUid);
                        final userApplicationSnapshot =
                            await userApplicationDocRef.get();

                        if (userApplicationSnapshot.exists) {
                          // User has already applied
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'You have already applied for this company'),
                            ),
                          );
                        } else {
                          // Create or update the subcollection
                          await subcollectionRef.doc(userUid).set({
                            'name': userName,
                            'Company Name' :companyName,
                            // Add other relevant data here if needed
                          });

                          // Perform any other actions you need
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Application submitted successfully'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF27374D), // Background color
                      ),
                      child: Text(
                        'Apply for the company',
                        style: TextStyle(color: Colors.white), // Text color
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
