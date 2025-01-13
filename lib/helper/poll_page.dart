import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PollPage extends StatefulWidget {
  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _options = [];
  String _selectedType = 'Poll'; // New variable to track the type (Poll or Survey)

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DropdownButton<String>(
          value: _selectedType,
          items: ['Poll', 'Survey']
              .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              // Reset options if switching between Poll and Survey
              _options.clear();
            });
          },
        ),
        TextField(
          controller: _questionController,
          decoration: InputDecoration(labelText: 'Question'),
        ),
        TextField(
          controller: _optionController,
          decoration: InputDecoration(labelText: _selectedType == 'Poll' ? 'Option' : 'Response'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _options.add(value);
                _optionController.clear();
              });
            }
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _createPollOrSurvey,
          child: Text('Create ${_selectedType}'),
        ),
        SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('polls').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final polls = snapshot.data!.docs;
              return ListView.builder(
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  final question = poll['question'];
                  final options = List<String>.from(poll['options']);
                  return ListTile(
                    title: Text(question),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: options.map((option) => Text(option)).toList(),
                    ),
                    onTap: () {
                      // Show survey results or response input
                      _showSurveyResults(context, poll);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _createPollOrSurvey() async {
    if (_questionController.text.isNotEmpty && _options.isNotEmpty) {
      await _firestore.collection('polls').add({
        'question': _questionController.text,
        'options': _options,
        'type': _selectedType, // Store the type of poll or survey
      });
      setState(() {
        _questionController.clear();
        _options.clear();
      });
    }
  }

  void _showSurveyResults(BuildContext context, QueryDocumentSnapshot poll) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Survey Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Question: ${poll['question']}'),
              ...List.generate(poll['options'].length, (index) {
                return Text('Option ${index + 1}: ${poll['options'][index]}');
              }),
              TextField(
                decoration: InputDecoration(labelText: 'Your Response'),
                onSubmitted: (response) {
                  // Save response logic
                  _saveResponse(poll.id, response);
                  Navigator.of(context).pop(); // Close dialog after submission
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveResponse(String pollId, String response) async {
    await _firestore.collection('poll_responses').add({
      'pollId': pollId,
      'response': response,
    });
  }
}
