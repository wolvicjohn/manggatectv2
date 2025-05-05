import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/services/firestore.dart';
import 'package:manggatectv2/utils/custom_page_transition.dart';
import 'package:manggatectv2/utils/notificationservice.dart';
import '../../../../pages/display_tree_page/displaytree.dart';
import '../../../app_designs.dart';
import '../../helper/result_helpers.dart';
import '../../helper/widgets/result_classifier.dart';
import '../../helper/widgets/result_dialogs.dart';

class ResultController {
  final BuildContext context;
  final File stageImage;
  final File image;
  final String latitude;
  final String longitude;
  final String username;
  final VoidCallback onUpdate;

  late ResultClassifier _classifier;
  String result = "";
  String? stage;
  bool loading = true;
  bool isSaving = false;

  ResultController({
    required this.context,
    required this.stageImage,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.username,
    required this.onUpdate,
  });

  void initClassifier() {
    _classifier = ResultClassifier(onClassificationDone: _onClassificationDone);
    _classifier.loadModelAndLabels(stageImage);
  }

  void _onClassificationDone(String res, String label) {
    result = res;
    stage = label;
    loading = false;
    onUpdate();
  }

  Future<void> saveToFirestore() async {
    if (isSaving) return;

    final shouldSave = await showSaveConfirmationDialog(context);
    if (!shouldSave) return;

    isSaving = true;
    onUpdate();

    try {
      final resizedStageImage = await resizeAndSaveImage(
        preprocessImage(stageImage),
        'resized_stage_image.jpg',
      );

      final resizedImage = await resizeAndSaveImage(
        preprocessImage(image),
        'resized_image.jpg',
      );

      await FirestoreService().addmango_tree(
        longitude: longitude,
        latitude: latitude,
        image: resizedImage,
        stageImage: resizedStageImage,
        stage: stage,
        isArchived: false,
        uploader: username,
      );

      await NotificationService.showNotification(
        id: 0,
        title: 'Save Successful',
        body: 'The tree has been saved successfully!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tree saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        CustomPageTransition(
          page: LatestMangoTreeDisplay(username: username),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving stage: $e')),
      );
    } finally {
      isSaving = false;
      onUpdate();
    }
  }

  Widget buildSavingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppDesigns.loadingIndicator(),
          SizedBox(height: 16),
          Text("Saving your results...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildLoadingView(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppDesigns.loadingIndicator(),
            SizedBox(height: 24),
            Text("Classifying your plant..."),
            SizedBox(height: 12),
            Text("Please wait while we analyze the image"),
          ],
        ),
      ),
    );
  }

  void dispose() => _classifier.dispose();
}
