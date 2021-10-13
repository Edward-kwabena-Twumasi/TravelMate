import 'package:flutter/material.dart';

void main() => runApp(MyAgents());

class MyAgents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              child: Text("Enter Location and destinations")),
        ),
        SizedBox(
          height: 11,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          height: 200.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              cards(context),
              cards(context),
              cards(context),
            ],
          ),
        ),
      ],
    );
  }
}

//card widget
Widget cards(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
        shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(39)),
    padding: EdgeInsets.all(10),
    height: 900,
    width: 300,
    child: Card(
        child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.arrow_drop_down_circle),
          title: const Text('Metro Mass Transit'),
          subtitle: Text(
            'Travel agent',
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
      ],
    )),
  );
}
