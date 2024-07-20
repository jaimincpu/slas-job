import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ApplicationListPage.dart';

class CompanyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
             backgroundColor: Color(0xFFA555EC),
        title: Text('Company List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('post').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final companies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final companyName = companies[index]['companyName'] as String;
              final documentUid = companies[index].id; // Get the document ID
              return Card(
                     color: Color(0xFFF3CCFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Text(
                    companyName,
                    style: TextStyle(color: Colors.black),
                  ),
                  tileColor: Color(0xFFD09CFA),
                  leading: Icon(
                    Icons.person,
                    color: Color(0xFF7776B3),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ApplicationListPage(documentUid: documentUid),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
