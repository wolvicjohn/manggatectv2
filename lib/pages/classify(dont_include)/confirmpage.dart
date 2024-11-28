import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/home_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../services/app_designs.dart';
import 'classifypage.dart'; // Import the ClassifyPage.

class ConfirmPage extends StatefulWidget {
  final File image;

  const ConfirmPage({required this.image, Key? key}) : super(key: key);

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  String _result = "";
  String _description = ""; // Stores the stage description.
  bool _loading = true;

  // Step 1: Define stage descriptions
  final Map<String, String> _descriptions = {
    'stage-1':
        'Budding phase: During this phase, the tree begins to form flower buds. '
            'As these buds mature, they enlarge and adopt a red hue. The duration '
            'of this stage can vary for weeks, contingent on the mango type.',
    'stage-2':
        'Flowers blossom during the growth stage. The petals typically exhibit '
            'white or light yellow colors. This phase generally persists for a handful of days.',
    'stage-3':
        'Complete bloom stage: Blossoms cover the tree, and the flowers open fully, '
            'but this stage lasts only a day or two.',
    'stage-4':
        'Fruit setting stage: This is the stage when the flowers turn into small mangos. '
            'The mangos can take several weeks to reach their full growth stage and become ready for harvest.',
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (_labels.isEmpty) throw Exception("Labels file is empty!");

      await _classifyImage();
    } catch (e) {
      setState(() {
        _result = "Error loading model or labels: $e";
        _loading = false;
      });
    }
  }

  img.Image _preprocessImage(File image) {
    final originalImage = img.decodeImage(image.readAsBytesSync())!;
    return img.copyResize(originalImage, width: 224, height: 224);
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(224, (y) {
        return List.generate(224, (x) {
          final pixel = image.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        });
      }),
    );
  }

  Future<void> _classifyImage() async {
    setState(() => _loading = true);

    try {
      final inputTensor = _imageToInputTensor(_preprocessImage(widget.image));
      final outputTensor =
          List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter.run(inputTensor, outputTensor);

      final output = outputTensor[0].cast<double>();
      double maxScore = output[0];
      int labelIndex = 0;

      for (int i = 1; i < output.length; i++) {
        if (output[i] > maxScore) {
          maxScore = output[i];
          labelIndex = i;
        }
      }

      final label = _labels[labelIndex];
      setState(() {
        _result =
            "Label: $label\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
        _description = _descriptions[label] ?? "Description not available.";
      });
    } catch (e) {
      setState(() {
        _result = "Error during classification: $e";
        _description = "";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Image', style: AppDesigns.titleTextStyle),
        backgroundColor: AppDesigns.primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading ? _buildLoadingView() : _buildResultView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(widget.image),
          ),
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildResultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(widget.image),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppDesigns.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _result,
                style: AppDesigns.valueTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _description,
                style: AppDesigns.labelTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppDesigns.customButton(
          title: 'Close',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Homepage(),
              ),
              (Route<dynamic> route) => false, // Removes all previous routes
            );
          },
        )
      ],
    );
  }
}
