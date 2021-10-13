import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';



void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const title = 'Chat assistant';
    return MaterialApp(
      title: title,
      home:  ChatHomePage(
          title: title,        
        ),
    );
  }
}



class ChatHomePage extends StatefulWidget {
  const ChatHomePage({
    Key? key,
    required this.title,
   
  }) : super(key: key);
  final String title;
  
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final TextEditingController controller = TextEditingController();

late final WebSocketChannel channel;
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
  Uri.parse('wss://echo.websocket.org'),

);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       floatingActionButton: FloatingActionButton(
          onPressed:(){
 if (controller.text.isNotEmpty) {
    channel.sink.add(controller.text);
  }
          },
          tooltip:'Send message',
          child: const Icon(Icons.send),
        ),
     body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Enter search here'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream:channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            )
          ],
        ),
    
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  @override
  void dispose() {
   channel.sink.close();
    super.dispose();
  }
}
