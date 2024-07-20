import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../educationwise/Edu_detail/common_pop_page_for_detail.dart';

class NewReg extends StatefulWidget {
  @override
  _NewRegState createState() => _NewRegState();
}

class _NewRegState extends State<NewReg> {
  Stream<QuerySnapshot> fetchUsers() {
    // Get the current date and the first day of the current month
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    Timestamp startOfMonth = Timestamp.fromDate(firstDayOfMonth);

    // Fetch users from Firestore with the timestamp condition
    return FirebaseFirestore.instance
        .collection('users')
        .where('createdAt', isGreaterThan: startOfMonth)
        .snapshots(); // Use snapshots() to get a stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Registrations'),
        backgroundColor: Color(0xFFA555EC), // Set app bar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return AnimatedList(
            key: GlobalKey<AnimatedListState>(),
            initialItemCount: users.length,
            itemBuilder: (context, index, animation) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['name'] ?? '';
              final uid = users[index].id;

              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(-1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                    reverseCurve: Curves.easeInOut,
                  ),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      name,
                      style: TextStyle(color: Colors.black), // Set text color
                    ),
                    tileColor: Color(0xFFD09CFA), // Set tile color
                    leading: Icon(
                      Icons.person,
                      color: Color(0xFF7776B3), // Set icon color
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailsPage(name: name, uid: uid),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
