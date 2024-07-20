import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'companydetail.dart';

class CompanyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text('Old Post'),
  backgroundColor: Color(0xFFA555EC), // Set the desired color
),

      body: Container(
  color: Color(0xFFF3CCFF), // Set the desired color
  child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('post').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final companyImage = post['companyImage'];
              final companyName = post['companyName'];
              final uid = post.id;

              return GestureDetector(
                onTap: () {
                  print("uid $uid");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetail(uid: uid),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Background image
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                          //    fit: BoxFit.fitHeight,
                            image: companyImage.isNotEmpty
                                ? NetworkImage(companyImage)
                                : AssetImage('assets/NO_FEED.png')
                                    as ImageProvider, // Placeholder image
                          ),
                        ),
                      ),
                      // Text overlay
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.6),
                          child: Text(
                            companyName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
