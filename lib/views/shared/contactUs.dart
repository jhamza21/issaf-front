import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';

class ContactUs extends StatefulWidget {
  final void Function(int) callback;
  ContactUs(this.callback);
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  String email, name, message;
  @override
  Widget build(BuildContext context) {
    Widget showEmailInput() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            SizedBox(height: 10.0),
            new TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: inputTextDecorationRectangle(
                  null, getTranslate(context, 'EMAIL') + "*", null, null),
              onChanged: (value) => setState(() {
                email = value.trim();
              }),
            ),
          ],
        ),
      );
    }

    Widget showNameInput() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            SizedBox(height: 10.0),
            new TextFormField(
              keyboardType: TextInputType.text,
              decoration: inputTextDecorationRectangle(
                  null, getTranslate(context, 'NAME') + "*", null, null),
              onChanged: (value) => setState(() {
                name = value.trim();
              }),
            ),
          ],
        ),
      );
    }

    Widget showMessageInput() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            SizedBox(height: 10.0),
            new TextFormField(
              maxLines: 8,
              keyboardType: TextInputType.text,
              decoration: inputTextDecorationRectangle(
                  null, getTranslate(context, 'DESCRIPTION') + "*", null, null),
              onChanged: (value) => setState(() {
                message = value.trim();
              }),
            ),
          ],
        ),
      );
    }

    Widget showImage() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 30.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/images/email.png'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          getTranslate(context, 'CONTACT_US'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => widget.callback(0),
        ),
      ),
      body: Column(
        children: [
          showImage(),
          showNameInput(),
          showEmailInput(),
          showMessageInput(),
        ],
      ),
    );
  }
}
