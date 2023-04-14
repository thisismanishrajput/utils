import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thumbnail Generator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();
  String _enteredText = '';
  Color _backgroundColor = Colors.grey[800]!;
  Color _textColor = Colors.white;
  String _fontFamily = 'Roboto';
  FontWeight _fontWeight = FontWeight.normal;
  double _aspectRatio = 1.0;
  String? _savedImagePath;
  File? _imageFile;
  Future<void> _saveImage() async {
    final Uint8List imageBytes = await _generateImageBytes();
    final String fileName = 'thumbnail.png';
    final Directory directory = Directory("/storage/emulated/0/Download");
    final String filePath = '${directory.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(imageBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved to Download folder'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<Uint8List> _generateImageBytes() async {
    double _width = 300;
    double _height = 300;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Rect rect = Rect.fromLTWH(0, 0, _width, _height);
    final Canvas canvas = Canvas(recorder, rect);

    // Draw the background color
    final Paint paint = Paint()..color = _backgroundColor;
    canvas.drawRect(rect, paint);

    // Draw the text
    final TextSpan textSpan = TextSpan(
      text: _textController.text,
      style: TextStyle(fontSize: 24.0, color: _textColor,fontWeight: _fontWeight),
    );
    final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: _width);
    textPainter.paint(canvas, Offset(0, (_height - textPainter.height) / 2));

    // Convert the canvas to an image
    final ui.Image image = await recorder.endRecording().toImage(300, 300);

    // Convert the image to bytes
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _generateThumbnail() async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final imageBytes = await boundary
        .toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio)
        .then((image) => image.toByteData(format: ImageByteFormat.png));
    final bytes = Uint8List.view(imageBytes!.buffer);
    final tempDir = Directory('/storage/emulated/0/Download');
    final file = await File('${tempDir.path}/thumbnail.png').create();
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Thumbnail saved to download folder'),
      duration: const Duration(seconds: 2),
    ));
    setState(() {
      _imageFile = file;
    });
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thumbnail Generator App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                ),
                onChanged: (val){
                  setState(() {

                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButton<double>(
                value: _aspectRatio,
                onChanged: (value) {
                  setState(() {
                    _aspectRatio = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: const Text('1:1'),
                  ),
                  DropdownMenuItem(
                    value: 4 / 3,
                    child: const Text('4:3'),
                  ),
                  DropdownMenuItem(
                    value: 16 / 9,
                    child: const Text('16:9'),
                  ),
                  DropdownMenuItem(
                    value: 3 / 2,
                    child: const Text('3:2'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Font Family:', style: TextStyle(fontSize: 16)),


              SizedBox(height: 16),
              Text('Font Weight:', style: TextStyle(fontSize: 16)),
              DropdownButton<FontWeight>(
                value: _fontWeight,
                onChanged: (value) {
                  setState(() => _fontWeight = value!);
                },
                items: <FontWeight>[
                  FontWeight.normal,
                  FontWeight.bold,
                  FontWeight.w100,
                  FontWeight.w200,
                  FontWeight.w300,
                  FontWeight.w500,
                  FontWeight.w600,
                  FontWeight.w800,
                  FontWeight.w900,
                ].map<DropdownMenuItem<FontWeight>>((FontWeight value) {
                  return DropdownMenuItem<FontWeight>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Text("Background Color"),
              ColorPicker(
                onColorChanged: (color) {
                  setState(() {
                    _backgroundColor = color;
                  });
                },
                color: _backgroundColor,
              ),
              Text("Text Color"),
              ColorPicker(
                onColorChanged: (color) {
                  setState(() {
                    _textColor = color;
                  });
                },
                color: _textColor,
              ),
              const SizedBox(height: 16),
              Container(
                width: 400,
                height: 400,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    color: _backgroundColor,
                    child: Center(
                      child: Text(
                        _textController.text,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select Image'),
                  ),
                  ElevatedButton(
                    onPressed: _generateThumbnail,
                    child: const Text('Generate Thumbnail'),
                  ),
                ],
              ),
              if (_imageFile != null)
                Expanded(
                  child: Center(
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    required this.onColorChanged,
    required this.color,
    Key? key,
  }) : super(key: key);

  final Function(Color) onColorChanged;
  final Color color;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colorList.length,
        itemBuilder: (context, index) {
          final color = _colorList[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentColor = color;
              });
              widget.onColorChanged(color);
            },
            child: Container(
              color: color,
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: _currentColor == color ? const Icon(Icons.check) : null,
            ),
          );
        },
      ),
    );
  }
}

final _colorList = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.pink,
];
