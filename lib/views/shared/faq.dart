import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';

class Faq extends StatefulWidget {
  final void Function(int) callback;
  Faq(this.callback);
  @override
  _FaqState createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  List<Question> questions = [
    Question(
        title: "HOW_DELETE_MY_ACCOUNT",
        response: "HOW_DELETE_MY_ACCOUNT_RESPONSE"),
    Question(
        title: "HOW_TO_ADD_MY_OWN_SERVICE",
        response: "HOW_TO_ADD_MY_OWN_SERVICE_RESPONSE"),
    Question(
        title: "WHAT_IS_THE_USE_OF_AVG_TIME_PER_CLIENT",
        response: "WHAT_IS_THE_USE_OF_AVG_TIME_PER_CLIENT_RESPONSE"),
    Question(
        title: "HOW_TO_INVITE_USER_TO_HANDLE_ESAFF",
        response: "HOW_TO_INVITE_USER_TO_HANDLE_ESAFF_RESPONSE"),
    Question(title: "HOW_TO_LOGOUT", response: "HOW_TO_LOGOUT_RESPONSE"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          getTranslate(context, 'FAQ'),
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () => widget.callback(0),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                questions[index].isExpanded = !isExpanded;
              });
            },
            animationDuration: Duration(milliseconds: 300),
            children: questions.map<ExpansionPanel>((Question _question) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      getTranslate(context, _question.title),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslate(context, _question.response),
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
                isExpanded: _question.isExpanded,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Question {
  Question({
    this.title,
    this.response,
    this.isExpanded = false,
  });

  String title;
  String response;
  bool isExpanded;
}
