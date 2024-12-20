import 'package:flutter/material.dart';
import 'settings/settings_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(home: DatingCompatibilityApp());
      },
    );
  }
}

class DatingCompatibilityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating Compatibility Game',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: LevelsScreen(),
    );
  }
}

class LevelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Level')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CarouselSlider.builder(
          itemCount: 5,
          itemBuilder: (context, index, realIdx) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionCardsScreen(level: index + 1),
                ),
              ),
              child: Card(
                color: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.gamepad,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Level ${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Description of level ${index + 1} goes here. Complete challenges and have fun!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 250.0,
            enlargeCenterPage: true,
            viewportFraction: 1.3,
            enableInfiniteScroll: true,
          ),
        ),
      ),
    );
  }
}

class QuestionCardsScreen extends StatelessWidget {
  final int level;

  QuestionCardsScreen({required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level $level Questions')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(question: 'Question ${index + 1}'),
              ),
            ),
            child: Card(
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  'Question ${index + 1}',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String question;

  ChatScreen({required this.question});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _showEmojiPicker = false;

  void _promptRatingToast() {
    Fluttertoast.showToast(
      msg: "Would you like to rate this answer?",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    ).then((_) => _promptRatingDialog());
  }

  void _promptRatingDialog() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate the Answer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How would you rate this answer?'),
              Slider(
                value: 0.0,
                onChanged: (value) {},
                min: 0.0,
                max: 5.0,
                divisions: 5,
                label: 'Rating',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.star_rate),
                  onPressed: _promptRatingToast,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _promptRatingToast,
                ),
              ],
            ),
            Text(
              widget.question,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isPlayer1 = message['isPlayer1'];
                return Align(
                  alignment:
                      isPlayer1 ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isPlayer1 ? Colors.greenAccent : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showEmojiPicker)
            EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _messageController.text += emoji.emoji;
              },
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.pink,
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.insert(0, {
                          'text': _messageController.text,
                          'isPlayer1': true,
                        });
                      });
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
