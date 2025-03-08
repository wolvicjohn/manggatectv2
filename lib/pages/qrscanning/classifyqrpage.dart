import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../services/app_designs.dart';
import '../../services/firestore.dart';
import '../home_page.dart';

class ConfirmPage extends StatefulWidget {
  final File stageImage;
  final String docID;
  final String username;

  const ConfirmPage({
    super.key,
    required this.stageImage,
    required this.docID,
    required this.username,
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
  final Map<String, String> _careRecommend = {
    'Invalid': 'Invalid Image, try again',
    'stage-1':
        'Watering: Water deeply but less frequently to encourage deeper root growth.',
    'stage-2':
        'Watering: Reduce watering slightly to avoid stimulating excessive vegetative growth, which can hinder flowering.',
    'stage-3':
        'Watering: Maintain consistent moisture levels to prevent fruit drop.',
    'stage-4':
        'Watering: Reduce watering slightly as the fruit matures to improve sweetness.',
  };
  final Map<String, String> _fertilization = {
    'Invalid': 'Invalid Image, try again',
    'stage-1': 'Fertilization: Add organic compost to improve soil health.',
    'stage-2':
        'Fertilization: Avoid nitrogen-heavy fertilizers at this stage, as they encourage leaf growth over flowers.',
    'stage-3':
        'Fertilization: Add micronutrients like zinc and boron for better fruit retention.',
    'stage-4':
        'Harvest Timing: Harvest fruits when they emit a fruity aroma and the skin color changes appropriately, Avoid picking fruits too early, as they may not ripen properly.',
  };
  final Map<String, String> _pruning = {
    'Invalid': 'Invalid Image, try again',
    'stage-1':
        'Remove dead or diseased branches to improve airflow and light penetration.',
    'stage-2':
        'Pollination Support: Mango flowers are pollinated by insects, so encourage natural pollinators like bees. Avoid spraying insecticides during flowering.',
    'stage-3':
        'Thinning: If there are too many fruits, remove some to prevent the tree from being overburdened and ensure better fruit quality.',
    'stage-4':
        'Post-Harvest Care: Store fruits in a cool, dry place to prolong shelf life.',
  };
  final Map<String, String> _pestControl = {
    'Invalid': 'Invalid Image, try again',
    'stage-1':
        'Watch for pests like aphids and scale insects. Treat with neem oil if necessary.',
    'stage-2':
        'Disease Management: Watch for powdery mildew or anthracnose, which can damage flowers. Use appropriate fungicides if needed.',
    'stage-3':
        'Pest and Disease Control: Monitor for fruit flies and bag fruits with protective coverings if necessary.',
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/model.tflite'); // load the algo model
      final labelsData = await DefaultAssetBundle.of(context)
          .loadString('assets/labels.txt'); //load and process labels
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (_labels.isEmpty) {
        throw Exception(
            "Labels file is empty or not found!"); //if no labels are found, throw exception
      }

      await _classifyImage();
    } catch (e) {
      _handleError("Error loading model and labels: $e"); //error handling
    }
  }

  img.Image _preprocessImage(File stageImage) {
    final originalImage =
        img.decodeImage(stageImage.readAsBytesSync())!; //decode the image
    return img.copyResize(originalImage,
        width: 224, height: 224); //resize the image into 224 x 224
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    //generate tensor structure
    return List.generate(1, (_) {
      // batch size 1 image
      return List.generate(224, (y) {
        //width
        return List.generate(224, (x) {
          // height
          final pixel = image.getPixel(x, y); // RGB values
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
      final inputTensor = _imageToInputTensor(_preprocessImage(widget
          .stageImage)); // Preprocess the image and convert to required tensor format
      final outputTensor = List.filled(_labels.length, 0.0).reshape([
        1,
        _labels.length
      ]); // create empty list to store the classification results

      _interpreter.run(inputTensor, outputTensor); // run inference

      final output = outputTensor[0].cast<
          double>(); // the models output is parsed to find the label with the highest confidence score(maxscore)
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
            "Classified as: ${_labels[labelIndex]} (Accuracy: ${(maxScore * 100).toStringAsFixed(2)}%)";
        _stage = _labels[labelIndex];
      });
    } catch (e) {
      _handleError("Error during image classification: $e"); // catch error
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
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
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
    bool shouldSave = await _showSaveConfirmationDialog();

    if (!shouldSave) return;

    setState(() {
      _isSaving = true;
    });

    FirestoreService firestoreService = FirestoreService();

    if (_stage != null && widget.docID.isNotEmpty) {
      try {
        await firestoreService.updateStage(
          docID: widget.docID,
          stage: _stage!,
          stageImage: widget.stageImage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stage saved successfully!')),
        );
        // Pop the current screen and replace with Homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Homepage(username: widget.username)),
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
        title: Text('Image Result', style: AppDesigns.titleTextStyle),
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
        if (_stage != null && _stage != 'Invalid')
          Column(
            children: [
              Text('Description', style: AppDesigns.titleTextStyle2),
            ],
          ),
        if (_stage != null &&
            _stage != 'Invalid' &&
            _descriptions.containsKey(_stage!))
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
        if (_stage != null && _stage != 'Invalid')
          Text('Maintenance Recommendations',
              style: AppDesigns.titleTextStyle2),
        const SizedBox(height: 20),
        if (_stage != null &&
            _stage != 'Invalid' &&
            _careRecommend.containsKey(_stage!))
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
                Text(_careRecommend[_stage!] ?? 'No description available.',
                    style: AppDesigns.bodyText2),
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (_stage != null &&
            _stage != 'Invalid' &&
            _fertilization.containsKey(_stage!))
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
                Text(_fertilization[_stage!] ?? 'No description available.',
                    style: AppDesigns.bodyText2),
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (_stage != null &&
            _stage != 'Invalid' &&
            _pruning.containsKey(_stage!))
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
                Text(_pruning[_stage!] ?? 'No description available.',
                    style: AppDesigns.bodyText2),
              ],
            ),
          ),
        const SizedBox(height: 10),
        if (_stage != null &&
            _stage != 'Invalid' &&
            _pestControl.containsKey(_stage!))
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
                Text(_pestControl[_stage!] ?? 'No description available.',
                    style: AppDesigns.bodyText2),
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (_stage != 'Invalid')
          FeatureCard(
            title: "Save",
            icon: Icons.map,
            color: AppDesigns.primaryColor,
            delay: 800,
            onTap: _saveStageToFirestore,
          ),
      ],
    );
  }
}
