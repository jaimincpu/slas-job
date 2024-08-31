import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'navgation/Contact/infopage .dart';
import 'UserData.dart';
import 'navgation/Company Posts/LsCompanyUserdashboard.dart';
import 'navgation/updates/update.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeDashboard(),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final User? user = FirebaseAuth.instance.currentUser;
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      DashboardScreen(), // Replace with your actual widget
      update(),
      LUserDetailsPage(),
      ContactPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Color(0xFFDDE6ED),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.update),
        title: "Update",
        activeColorPrimary: Color(0xFFDDE6ED),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.account_circle),
        title: "Details",
        activeColorPrimary: Color(0xFFDDE6ED),
        inactiveColorPrimary: Colors.grey,
      ),
       PersistentBottomNavBarItem(
        icon: Icon(Icons.contact_page),
        title: "Contact",
        activeColorPrimary: Color(0xFFDDE6ED),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: Color(0xFF27374D), // Main background color
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(1),
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News Feed',
          style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 255, 255, 255)),
        
        ),
        backgroundColor: Color(0xFF27374D),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       try {
        //         // Sign out the user
        //         await FirebaseAuth.instance.signOut();

        //         // Navigate to the login screen (replace with your actual route)
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(builder: (context) => LoginPage()),
        //           (route) => false, // Remove all previous routes from the stack
        //         );
        //       } catch (e) {
        //         // Show an error snackbar
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(
        //             content: Text('Error signing out. Please try again.'),
        //             duration: Duration(seconds: 3),
        //           ),
        //         );
        //       }
        //     },
        //     icon: Icon(Icons.logout, color: Colors.white),
        //   )
        // ],
      ),
      backgroundColor: const Color(0xFFDDE6ED),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('post')
      .where('postExpiredData', isGreaterThanOrEqualTo: DateTime.now())
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return const Center(child: Text('Error fetching posts.'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('No posts available.'));
    }

    final posts = snapshot.data!.docs;

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final companyImage = post['companyImage'] ?? '';
        final companyName = post['companyName'] ?? '';
        final uid = post.id;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardDEtail(uid: uid),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: companyImage.isNotEmpty
                          ? NetworkImage(companyImage)
                          : const AssetImage('assets/placeholder.png')
                              as ImageProvider, // Placeholder image
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.6),
                    child: Text(
                      companyName,
                      style: const TextStyle(
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

    );
  }
}

