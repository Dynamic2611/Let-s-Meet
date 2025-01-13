import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String meetingId;

  ChatPage({required this.meetingId, Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  void _getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserEmail = user?.email ?? 'Unknown';
    });
  }

  
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;
      String? username = user?.displayName;

      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meetingId)
          .collection('chat')
          .add({
        'username': username ?? 'Unknown',
        'text': _messageController.text,
        'createdAt': Timestamp.now(),
        'userEmail': _currentUserEmail,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        title: Text('Chat - Meeting ID: ${widget.meetingId}'),
      ),
      body: Column(
        children: [
          Expanded(
            
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('meetings')
                  .doc(widget.meetingId)
                  .collection('chat')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['userEmail'] == _currentUserEmail;
                    final timestamp = (message['createdAt'] as Timestamp).toDate();
                    final time = TimeOfDay.fromDateTime(timestamp).format(context);

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: isCurrentUser ? 40:5, right: isCurrentUser ? 5: 40,),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blueAccent : Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isCurrentUser ? 10 : 10),
                              topRight: Radius.circular(isCurrentUser ? 10 : 10),
                              bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
                              bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                Text(
                                  message['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser ? Colors.white : Colors.black,
                                  ),
                                ),
                              SizedBox(height: 5),
                              Text(
                                message['text'],
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                time,
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Send a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
