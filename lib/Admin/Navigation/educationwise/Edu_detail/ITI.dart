import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'common_pop_page_for_detail.dart';



class ITI extends StatefulWidget {
  const ITI({Key? key}) : super(key: key);

  @override
  _ITIState createState() => _ITIState();
}

class _ITIState extends State<ITI> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users with ITI Passed Education'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('Education detail', isEqualTo: 'ITI').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

 
          List<DocumentSnapshot> users = snapshot.data!.docs;
          users = users.reversed.toList(); // Reverse the order of the list

          return AnimatedList(
            key: _listKey,
            initialItemCount: users.length,
            itemBuilder: (context, index, animation) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['name'] ?? 'No Name';
              final uid = users[index].id;

              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(-1, 0),
                  end: Offset.zero,
                ).animate( CurvedAnimation(
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
                    title: Text(name),
                    tileColor: Colors.grey[200],
                    leading: Icon(Icons.person),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(name: name, uid: uid),
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
