import 'package:flutter/material.dart';
import 'package:letsmeet/shared/constants.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class SpeechTranslate extends StatefulWidget {
  const SpeechTranslate({super.key});

  @override
  State<SpeechTranslate> createState() => _SpeechTranslateState();
}

class _SpeechTranslateState extends State<SpeechTranslate> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  String _translatedText = "";
  String _selectedLanguage = "en"; // Default to English

  final List<Map<String, String>> _languages = languages;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) async {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });

    if (_wordsSpoken.isNotEmpty) {
      final translator = GoogleTranslator();
      var translation = await translator.translate(
        _wordsSpoken,
        to: _selectedLanguage,
      );
      setState(() {
        _translatedText = translation.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "Listening"
                    : _speechEnabled
                        ? "Tap microphone to start listening"
                        : "Speech is not available",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    /*Text(
                      _wordsSpoken,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                    ),*/
                    SizedBox(height: 20),
                    Text(
                      _translatedText,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
            if (_speechToText.isNotListening && _confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text(
                  "Confidence ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: TextStyle(color: Colors.amber, fontSize: 30, fontWeight: FontWeight.w200),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          
          onPressed: _speechToText.isListening ? _stopListening : _startListening,
          tooltip: "Listen",
          child: Icon(
            _speechToText.isListening ? Icons.mic_off : Icons.mic,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
