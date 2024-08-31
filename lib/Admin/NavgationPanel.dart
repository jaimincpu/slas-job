import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/login_page.dart';
import 'Navigation/Export data/exportdata.dart';
import 'Navigation/educationwise/educationvicUser.dart';
import 'Navigation/Company post/companylist.dart';
import 'Navigation/Company post/newPost.dart';
import 'Navigation/jobRequirement/jobRequirmentlist.dart';
import 'Navigation/regestration/NewReg.dart';
import 'Navigation/regestration/oldreg.dart';

class NavPanel extends StatefulWidget {
  const NavPanel({Key? key}) : super(key: key);
  

  @override
  _NavPanelState createState() => _NavPanelState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;
 Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

class _NavPanelState extends State<NavPanel> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Color(0xFFA555EC),
        actions: [
          Row(
            children: [
              IconButton(
                icon: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(200 * (1 - value), 0),
                      child: child,
                    );
                  },
                  child: Icon(Icons.exit_to_app),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _signOut(context);
                },
                child: Text('Logout'),
              ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF3CCFF),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextTile(
                              context,
                              'Old Registration',
                              Icons.history,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OldReg()),
                                );
                              },
                            ),
                            _buildTextTile(
                              context,
                              'This Month Registration',
                              Icons.event,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewReg()),
                                );
                              },
                            ),
                            _buildTextTile(
                              context,
                              'Old Post',
                              Icons.archive,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CompanyList()),
                                );
                              },
                            ),
                              _buildTextTile(
                              context,
                              'Export data',
                              Icons.history,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                  ExportData
                                 // FirestoreToExcelEmailPage
                                 ()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextTile(
                              context,
                              'Education VIC User',
                              Icons.school,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ByEducationVic()),
                                );
                              },
                            ),
                            _buildTextTile(
                              context,
                              'New Post',
                              Icons.post_add,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TileListScreen()),
                                );
                              },
                            ),
                            _buildTextTile(
                              context,
                              'Job Requirement',
                              Icons.work,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CompanyListPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
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
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF7776B3)),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFF7776B3),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
