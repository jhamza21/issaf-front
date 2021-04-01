import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';

class TicketInProgress extends StatefulWidget {
  @override
  _TicketInProgressState createState() => _TicketInProgressState();
}

class _TicketInProgressState extends State<TicketInProgress> {
  bool _isLoading = true;
  List<Ticket> _tickets = [];

  void _fetchTickets() async {
    try {
      // var prefs = await SharedPreferences.getInstance();
      // final response =
      //     await ProviderService().fetchProviders(prefs.getString('token'));

      // assert(response.statusCode == 200);
      // final jsonData = json.decode(response.body);
      // _providers = Provider.listFromJson(jsonData);
      // reorderProviders();

      _tickets.add(Ticket(
          date: "Demain à 12h",
          description: "Accés au magasin",
          id: 0,
          number: 1,
          title: "Carrefour",
          status: Status.IN_PROGRESS));
      _tickets.add(Ticket(
          date: "2021-10-10 à 10:55",
          description: "Simple coiffure",
          id: 1,
          number: 7,
          title: "Coiffeur Guigos",
          status: Status.IN_PROGRESS));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTickets();
  }

  Card ticketCard(Ticket ticket) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 42,
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      ticket.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(ticket.description),
                  ],
                ),
              ],
            ),
          ),
          Container(
              color: Colors.white,
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        height: 80,
                        width: 50,
                        child: Image.asset(
                          'assets/images/alarm.gif',
                        )),
                    Column(
                      children: [
                        Text("Vous avez un rendez-vous"),
                        Text(
                          ticket.date,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
                Text(
                  "Ticket Nᵒ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                Text(
                  ticket.number.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0),
                ),
              ])),
          Container(
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.remove_circle),
                    label: Text("Annuler")),
                TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.repeat),
                    label: Text("Replanifier"))
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: circularProgressIndicator)
        : _tickets.length == 0
            ? Center(
                child: Text(getTranslate(context, "NO_RESULT_FOUND")),
              )
            : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return ticketCard(_tickets[index]);
                },
              );
  }
}
