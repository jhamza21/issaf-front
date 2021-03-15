import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  signOut() async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              'Bienvenue',
              style: TextStyle(color: Colors.orange[800], fontSize: 18.0),
            ),
            accountEmail: SizedBox.shrink(),
            currentAccountPicture:
                CircleAvatar(child: Image.asset('assets/images/logo.png')),
          ),
          ListTile(
            onTap: () {
              // Navigator.of(context).pop();
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (BuildContext context) =>
              //   // HomePage(),
              // ));
            },
            leading: Icon(Icons.home),
            title: Text(
              'Accueil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             //CasesPage(token: widget.token)));
          //   },
          //   leading: Icon(Icons.add),
          //   title: Text(
          //     'Nouvelle demande',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading: Icon(Icons.mail_outline),
          //   title: Text(
          //     'Boîte de réception',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             DraftsPage(token: widget.token)));
          //   },
          //   leading: Icon(Icons.edit),
          //   title: Text(
          //     'Brouillon',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             ToDoPage(token: widget.token)));
          //   },
          //   leading: Icon(Icons.call_made),
          //   title: Text(
          //     'Mes Demandes',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          Divider(),
          ListTile(
            leading: Icon(FontAwesomeIcons.lock),
            title: Text('Déconnexion'),
            onTap: () {
              signOut();
            },
          ),
        ],
      ),
    );
  }
}
