import 'package:flutter/material.dart';

class HandleService extends StatefulWidget {
  @override
  _HandleServiceState createState() => _HandleServiceState();
}

class _HandleServiceState extends State<HandleService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.qr_code))],
        title: Text("Accueil"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Client nᵒ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "236",
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonTheme(
                  minWidth: 150,
                  // ignore: deprecated_member_use
                  child: RaisedButton.icon(
                    elevation: 5.0,
                    icon: Icon(Icons.done),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.green[900],
                    label: Text("Done"),
                    onPressed: () {},
                  ),
                ),
                ButtonTheme(
                  minWidth: 150,
                  // ignore: deprecated_member_use
                  child: RaisedButton.icon(
                    elevation: 5.0,
                    icon: Icon(Icons.dangerous),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.red[900],
                    label: Text("Undone"),
                    onPressed: () {},
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
