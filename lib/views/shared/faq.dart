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
        title:
            "Qu'est-ce que tu peux me dire... qu'est-ce que ça répresente pour toi la cuisine française ?",
        response:
            "Bah, c'est une cuisine raffinée, c'est sûr.... cuisine raffinée qui, euh, qui a des racines aussi, euh, un petit peu dans d'autres cuisines, qui a pris des racines un peu dans d'autres cuisines, qui fait que c'est une cuisine qui est élaborée de façon, euh comment dire, j... en tenant compte un petit peu de goût de plus grand nombre"),
    Question(
        title: "Qu'est-ce que tu peux me dire sur les plats typiques du Sud ? ",
        response:
            "C'est des plats épicés, c'est des... ce sont des plats de... légumes... ils mangent beaucoup de légumes dans, dans le Midi, et plats épicés, quoi. Voilà."),
    Question(
        title: "Et quels sont les plats typiques des Alpes ?",
        response:
            "Des Alpes, c'est fromage évidemment. Fromage, bah base de fromage, quoi, et la charcuterie"),
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
                      _question.title,
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
                    _question.response,
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
