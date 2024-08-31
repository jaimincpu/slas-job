import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'jobapplicationapproved/approvdenied.dart';

class ApplicationListPage extends StatelessWidget {
  final String documentUid; // Received UID from the previous page

  ApplicationListPage({required this.documentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('post')
            .doc(documentUid)
            .collection('userApplications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final userApplications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userApplications.length,
            itemBuilder: (context, index) {
              final applicationName = userApplications[index]['name'] as String;
              final applicationUid = userApplications[index].id; // Get the document ID
              final applicationCompanyName =userApplications[index]['Company Name'] as String;

              return ListTile(
                title: Text(applicationName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          candidateaproveddinedPage(uid: applicationUid, name: applicationName ,CompanyName : applicationCompanyName), // Pass the document ID
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}