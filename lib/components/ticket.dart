import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/completebook.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Ticket extends StatefulWidget {
  const Ticket({Key? key, required this.ticketinfo}) : super(key: key);
  final Ticketinfo ticketinfo;
  @override
  _TicketState createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 6,
        color: Colors.lightGreen[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            Center(
              child: Text(
                "Ticket details",
                style: TextStyle(color: Colors.lightBlue,fontWeight:FontWeight.bold,fontSize: 26 ),
              ),
            ),
            DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Issuer : Travel mates",
                    style: TextStyle(
                      color: Colors.green,
                      backgroundColor: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            Divider(color: Colors.lightBlue),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: ListTile(
                          title: Text(widget.ticketinfo.company,
                              style: TextStyle(
                                color: Colors.green,
                                backgroundColor: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          subtitle: Text("Company"))),
                  Expanded(
                      child: ListTile(
                    title: Text(widget.ticketinfo.tripid,
                        style: TextStyle(
                          color: Colors.green,
                          backgroundColor: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text("Tripid"),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: ListTile(
                          title: Text(widget.ticketinfo.vehid,
                              style: TextStyle(
                                color: Colors.green,
                                backgroundColor: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          subtitle: Text("Vehicle id"))),
                  Expanded(
                      child: ListTile(
                    title: Text(widget.ticketinfo.booker,
                        style: TextStyle(
                          color: Colors.green,
                          backgroundColor: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text("Booker id"),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: ListTile(
                          title: Text(widget.ticketinfo.from,
                              style: TextStyle(
                                color: Colors.green,
                                backgroundColor: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          subtitle: Text("From"))),
                  Expanded(
                      child: ListTile(
                    title: Text(widget.ticketinfo.to,
                        style: TextStyle(
                          color: Colors.green,
                          backgroundColor: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text("To"),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: ListTile(
                          title: Text((widget.ticketinfo.total/100).toString(),
                              style: TextStyle(
                                color: Colors.green,
                                backgroundColor: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          subtitle: Text("Total"))),
                  Expanded(
                      child: ListTile(
                    title: Text(
                        (widget.ticketinfo.total /
                                widget.ticketinfo.chosen.length*100)
                            .toString(),
                        style: TextStyle(
                          color: Colors.green,
                          backgroundColor: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text("Fare"),
                  )),
                ],
              ),
            ),
            Center(
              child: ListTile(
                title: Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.ticketinfo.chosen.length,
                    itemBuilder: (itemBuilder, i) {
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: DecoratedBox(decoration: BoxDecoration(
                        color: Colors.pink[50],
                        border: Border.all(color:Colors.green ),
                        borderRadius:BorderRadius.circular(5),
                        
                      ),
                      child: Text(widget.ticketinfo.chosen[i].toString().split("_")[0],
                      style:TextStyle(color:Colors.green,fontWeight:FontWeight.bold   ) ,),
                      ),
                    );
                  }),
                ),
                subtitle: Text("Seat numbers"),
              ),
            ),
            Center(
                child: ListTile(
                    title: Text("QR code"),
                    subtitle: ClipRRect(
                      borderRadius:BorderRadius.circular(25),
                      child: QrImage(
                        data: widget.ticketinfo.booker +
                            "  " +
                            widget.ticketinfo.tripid.toString(),
                        version: QrVersions.auto,
                        size: 100.0,
                      ),
                    ))),
            Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserInfoClass()),
                    );
                  },
                  child: Text("See profile")),
            )
          ]),
        ),
      ),
    );
  }
}
