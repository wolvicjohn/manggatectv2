import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import 'package:manggatectv2/utility/notificationservice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../services/app_designs.dart';
import '../../services/firestore.dart';
import '../home_page.dart';

class ResultPage extends StatefulWidget {
  final File stageImage;
  final File image;
  final String latitude;
  final String longitude;
  final String username;

  ResultPage({
    Key? key,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.stageImage,
    required this.username,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  String _result = "";
  String? _stage;
  bool _loading = true;
  bool _isSaving = false;

  // stage descriptions
  final Map<String, String> _descriptions = {
    'Invalid': 'Invalid Image, try again',
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
    NotificationService.initialize();
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
        _result = "Label: ${_labels[labelIndex]}";
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

  // Save image back to disk as File
  Future<File> _resizeAndSaveImage(img.Image image, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final resizedImage = File(filePath)..writeAsBytesSync(img.encodeJpg(image));
    return resizedImage;
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
        false;
  }

  Future<void> _saveStageToFirestore() async {
    if (_isSaving) return;

    // Show confirmation dialog before saving
    bool shouldSave = await _showSaveConfirmationDialog();

    if (!shouldSave) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    FirestoreService firestoreService = FirestoreService();

    try {
      // Resize both images
      final resizedStageImage = await _resizeAndSaveImage(
          _preprocessImage(widget.stageImage), 'resized_stage_image.jpg');
      final resizedImage = await _resizeAndSaveImage(
          _preprocessImage(widget.image), 'resized_image.jpg');

      // Save resized images to Firestore (or Firebase Storage)
      await firestoreService.addmango_tree(
        longitude: widget.longitude,
        latitude: widget.latitude,
        image: resizedImage,
        stageImage: resizedStageImage,
        stage: _stage,
        isArchived: false,
        uploader: widget.username,
      );

      // After saving, show notification
      await NotificationService.showNotification(
        id: 0,
        title: 'Save Successful',
        body: 'The stage has been saved successfully!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stage saved successfully!')),
      );

      // Pop the current screen and replace with Homepage
      Navigator.pushReplacement(
        context,
        CustomPageTransition(page: Homepage(username: widget.username)),
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
  }

  img.Image _resizeImage(File imageFile) {
    final originalImage = img.decodeImage(imageFile.readAsBytesSync())!;
    return img.copyResize(originalImage, width: 224, height: 224);
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isSaving
          ? Container(
              child: Center(child: AppDesigns.loadingIndicator()),
            ) // Show loading indicator
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _loading
                      ? _buildLoadingView() // Show loading view when classifying
                      : _buildResultView(), // Show result view after classification
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
                    style: AppDesigns.bodyText2),
              ],
            ),
          ),
        const SizedBox(height: 20),
        // Hide the save button if the result is "Invalid"
        if (_stage != 'Invalid')
          AppDesigns.customButton(
            title: "Save",
            onPressed: _saveStageToFirestore,
            isLoading: _isSaving,
          ),
      ],
    );
  }
}
