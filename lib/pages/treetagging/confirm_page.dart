import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../services/app_designs.dart';
import '../../services/firestore.dart';
import '../home_page.dart';

class ConfirmPage extends StatefulWidget {
  final File image;
  final String latitude;
  final String longitude;

  const ConfirmPage({
    required this.image,
    required this.latitude,
    required this.longitude,
    Key? key,
  }) : super(key: key);

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  String _result = "";
  String? _stage;
  bool _loading = true;
  bool _isSaving = false; // Track saving state

  // Step 1: Define stage descriptions
  final Map<String, String> _descriptions = {
    'stage-1':
        'Budding phase: During this phase, the tree begins to form flower buds. As these buds mature, they enlarge and adopt a red hue. The duration of this stage can vary for weeks, contingent on the mango type.',
    'stage-2':
        'Flowers blossom during the growth stage. The petals typically exhibit white or light yellow colors. This phase generally persists for a handful of days.',
    'stage-3':
        'Complete bloom stage: Blossoms cover the tree, and the flowers open fully, but this stage lasts only a day or two.',
    'stage-4':
        'Fruit setting stage: This is the stage when the flowers turn into small mangos. The mangos can take several weeks to reach their full growth stage and become ready for harvest.',
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

      if (_labels.isEmpty) {
        throw Exception("Labels file is empty or not found!");
      }

      await _classifyImage();
    } catch (e) {
      _handleError("Error loading model and labels: $e");
    }
  }

  img.Image _preprocessImage(File image) {
    final originalImage = img.decodeImage(image.readAsBytesSync())!;
    return img.copyResize(originalImage, width: 224, height: 224);
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    return List.generate(1, (_) {
      return List.generate(224, (y) {
        return List.generate(224, (x) {
          final pixel = image.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        });
      });
    });
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

      setState(() {
        _result = "Label: ${_labels[labelIndex]}\n"
            "Confidence: ${(maxScore * 100).toStringAsFixed(2)}%";
        _stage = _labels[labelIndex];
      });
    } catch (e) {
      _handleError("Error during image classification: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleError(String message) {
    setState(() {
      _result = message;
      _loading = false;
    });
  }

  Future<void> _saveStageToFirestore() async {
    if (_isSaving) return; // Prevent multiple clicks
    setState(() {
      _isSaving = true; // Start saving
    });

    FirestoreService firestoreService = FirestoreService();
    if (_stage != null) {
      try {
        await firestoreService.addNote(
          longitude: widget.longitude,
          latitude: widget.latitude,
          image: widget.image,
          stage: _stage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stage saved successfully!')),
        );

        // Redirect to the homepage after saving

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Homepage()), // Replace with your homepage widget
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving stage: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false; // End saving
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stage to save!')),
      );
      setState(() {
        _isSaving = false; // End saving
      });
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
        title: Text(
          'Confirm Image',
          style: AppDesigns
              .titleTextStyle, // Use the title text style from AppDesigns
        ),
        backgroundColor:
            AppDesigns.primaryColor, // Use your primary color from AppDesigns
        elevation: 4, // Adjust elevation for a subtle shadow
        centerTitle: true, // Center the title
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
        // Result Container
        Container(
          width: double
              .infinity, // Stretch the container to fill the available width
          padding: const EdgeInsets.all(16.0), // Padding inside the container
          decoration: BoxDecoration(
            color: AppDesigns.backgroundColor, // Set background color
            borderRadius: BorderRadius.circular(10), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Colors.black26, // Shadow color
                blurRadius: 4.0, // Shadow blur
                offset: Offset(0, 2), // Shadow position
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align text to the start
            children: [
              Text(
                'Result:',
                style: AppDesigns.titleTextStyle2, // Use the custom title style
              ),
              const SizedBox(height: 10),
              Text(
                _result,
                style: AppDesigns.valueTextStyle, // Use the custom value style
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Description Container
        if (_stage != null && _descriptions.containsKey(_stage!))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0), // Padding inside the container
            decoration: BoxDecoration(
              color: AppDesigns.backgroundColor, // Set background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // Shadow color
                  blurRadius: 4.0, // Shadow blur
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: Text(
              _descriptions[_stage!]!, // Get description based on stage
              style: AppDesigns.labelTextStyle, // Use a custom style if needed
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        _isSaving // Show loading indicator while saving
            ? const CircularProgressIndicator()
            : AppDesigns.customButton(
                title: 'Save Stage',
                onPressed: _saveStageToFirestore,
              ),
      ],
    );
  }
}
