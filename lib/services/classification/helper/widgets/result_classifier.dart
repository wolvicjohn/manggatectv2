import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../result_helpers.dart';

class ResultClassifier {
  final Function(String result, String label) onClassificationDone;
  late Interpreter _interpreter;
  late List<String> _labels;

  ResultClassifier({required this.onClassificationDone});

  Future<void> loadModelAndLabels(File imageFile) async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _labels = await _loadLabels();
      await classifyImage(imageFile);
    } catch (e) {
      onClassificationDone('Error loading model: $e', 'Invalid');
    }
  }

  Future<List<String>> _loadLabels() async {
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    return labelsData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> classifyImage(File imageFile) async {
    final img.Image image = preprocessImage(imageFile);
    final input = imageToInputTensor(image);
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run(input, output);

    final List<double> scores = output[0].cast<double>();
    final int bestIdx = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));
    final label = _labels[bestIdx];
    final result = "Classified as: $label   ${(scores[bestIdx] * 100).toStringAsFixed(2)}%";

    onClassificationDone(result, label);
  }

  void dispose() {
    _interpreter.close();
  }
}
