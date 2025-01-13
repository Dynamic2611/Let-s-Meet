import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:whiteboard/whiteboard.dart';
import 'package:http/http.dart' as http; // Add this import for fetching images
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  _WhiteboardScreenState createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  final WhiteBoardController _controller = WhiteBoardController();
  Color _strokeColor = Colors.black;
  double _penStrokeWidth = 5.0;
  double _eraserStrokeWidth = 20.0;
  bool _isErasing = false;
  final GlobalKey _repaintKey = GlobalKey();
  bool _showSlider = false;
  bool _showButtons = false;
  bool isMoreIcon = true; // State variable for toggling buttons

  Future<void> _captureAndSave() async {
  try {
    final RenderRepaintBoundary boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Call the function to upload the image to Firebase Storage
    await _uploadToFirebase(pngBytes);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error capturing image: $e')),
    );
  }
}

  // Function to upload image to Firebase Storage
  Future<void> _uploadToFirebase(Uint8List pngBytes) async {
    try {
      // Generate a unique file name for the image
      String fileName = 'whiteboard_capture_${DateTime.now().millisecondsSinceEpoch}.png';

      // Get reference to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('whiteboard_images/$fileName');

      // Upload image to Firebase Storage
      UploadTask uploadTask = storageRef.putData(pngBytes);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL of uploaded image
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded to Firebase: $downloadUrl')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  // Fetch images from Firebase Storage and save as PDF
  Future<void> _downloadAllImagesAsPDF() async {
    List<String> imageUrls = await _fetchImageUrls();

    final pdf = pw.Document();

    for (var imageUrl in imageUrls) {
      final imageBytes = await _fetchImage(imageUrl);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(imageBytes)),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Function to fetch image URLs from Firebase Storage
  Future<List<String>> _fetchImageUrls() async {
    List<String> imageUrls = [];
    final storageRef = FirebaseStorage.instance.ref().child('whiteboard_images');

    final ListResult result = await storageRef.listAll();

    for (var item in result.items) {
      final String downloadUrl = await item.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  // Function to fetch image bytes from a URL
  Future<Uint8List> _fetchImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from URL: $imageUrl');
    }
  }

  void _clearBoard() {
    _controller.clear();
  }

  void _undo() {
    _controller.undo();
  }

  void _redo() {
    _controller.redo();
  }

  // Function to toggle button visibility
  void opBut() {
    setState(() {
      _showButtons = !_showButtons;
      isMoreIcon = !isMoreIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 30),
            onPressed: _captureAndSave,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 30),
            onPressed: _downloadAllImagesAsPDF, // Add this line
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          height: 2000.0,
                          child: WhiteBoard(
                            controller: _controller,
                            strokeColor: _strokeColor,
                            strokeWidth: _isErasing ? _eraserStrokeWidth : _penStrokeWidth,
                            isErasing: _isErasing,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildToolBar(isSmallScreen),
            ],
          ),
          Positioned(
            bottom: 80.0,
            right: 20.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showButtons) ...[
                  FloatingActionButton(
                    heroTag: 'undo',
                    onPressed: _undo,
                    child: const Icon(Icons.undo),
                  ),
                  const SizedBox(height: 16.0),
                  FloatingActionButton(
                    heroTag: 'redo',
                    onPressed: _redo,
                    child: const Icon(Icons.redo),
                  ),
                  const SizedBox(height: 16.0),
                  FloatingActionButton(
                    heroTag: 'clear',
                    onPressed: _clearBoard,
                    child: const Icon(Icons.cleaning_services),
                  ),
                ],
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  heroTag: 'more',
                  onPressed: opBut,
                  child: Icon(isMoreIcon ? Icons.more_vert : Icons.clear),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBar(bool isSmallScreen) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.color_lens,
                  color: _strokeColor,
                  size: isSmallScreen ? 24 : 30,
                ),
                onPressed: () => _selectColor(context),
              ),
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    _showSlider = !_showSlider;
                  });
                },
                child: IconButton(
                  icon: Icon(
                    _isErasing ? Icons.delete : Icons.create,
                    color: _isErasing ? Colors.red : Colors.blue,
                    size: isSmallScreen ? 24 : 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _isErasing = !_isErasing;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_showSlider)
            _buildStrokeSizeSlider(
              label: _isErasing ? 'Eraser Size' : 'Pen Size',
              value: _isErasing ? _eraserStrokeWidth : _penStrokeWidth,
              onChanged: (value) {
                setState(() {
                  if (_isErasing) {
                    _eraserStrokeWidth = value;
                  } else {
                    _penStrokeWidth = value;
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeSizeSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Slider(
          min: 1.0,
          max: 20.0,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _selectColor(BuildContext context) async {
    // ignore: unused_local_variable
    Color? pickedColor = await showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _strokeColor;
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _strokeColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _strokeColor = tempColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
}
