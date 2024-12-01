import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../services/app_designs.dart';
import '../../services/firestore.dart';
import '../home_page.dart';

class ConfirmPage extends StatefulWidget {
  final File stageImage;
  final String docID;

  const ConfirmPage({
    super.key,
    required this.stageImage,
    required this.docID,
  });

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  String _result = "";
  String? _stage;
  bool _loading = true;
  bool _isSaving = false;

  final Map<String, String> _descriptions = {
    'Invalid':'Invalid Image, try again',
    'stage-1':
        'Budding phase: During this phase, the tree begins to form flower buds...',
    'stage-2': 'Flowers blossom during the growth stage...',
    'stage-3': 'Complete bloom stage: Blossoms cover the tree...',
    'stage-4':
        'Fruit setting stage: This is when the flowers turn into small mangos...',
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

  img.Image _preprocessImage(File stageImage) {
    final originalImage = img.decodeImage(stageImage.readAsBytesSync())!;
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
      final inputTensor =
          _imageToInputTensor(_preprocessImage(widget.stageImage));
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
        _result =
            "Label: ${_labels[labelIndex]}\nConfidence: ${(maxScore * 100).toStringAsFixed(2)}%";
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

  // Confirmation dialog to save data
  Future<bool> _showSaveConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Save'),
              content: const Text('Do you want to save this stage?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Return false if "Cancel"
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Return true if "Yes"
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  Future<void> _saveStageToFirestore() async {
    if (_isSaving) return;
    bool shouldSave = await _showSaveConfirmationDialog();

    if (!shouldSave) return;

    setState(() {
      _isSaving = true;
    });

    FirestoreService firestoreService = FirestoreService();

    if (_stage != null && widget.docID.isNotEmpty) {
      try {
        await firestoreService.updateStage(
          docID: widget.docID, // Pass docID here
          stage: _stage!,
          stageImage: widget.stageImage, // Pass the image file
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stage saved successfully!')),
        );
        // Pop the current screen and replace with Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving stage: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stage to save!')),
      );
      setState(() {
        _isSaving = false;
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
        title: Text('Confirm Image', style: AppDesigns.titleTextStyle),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loading ? _buildLoadingView() : _buildResultView(),
          ),
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
            child: Image.file(widget.stageImage),
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
            child: Image.file(widget.stageImage),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Result:', style: AppDesigns.titleTextStyle2),
              const SizedBox(height: 10),
              Text(_result,
                  style: AppDesigns.valueTextStyle,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_stage != null && _descriptions.containsKey(_stage!))
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_descriptions[_stage!] ?? 'No description available.',
                    style: AppDesigns.labelTextStyle),
              ],
            ),
          ),
        const SizedBox(height: 20),
        AppDesigns.customButton(
          title: "Tag a Tree",
          onPressed: _saveStageToFirestore,
          isLoading: _isSaving,
        ),
      ],
    );
  }
}
