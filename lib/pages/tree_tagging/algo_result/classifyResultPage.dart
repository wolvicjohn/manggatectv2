import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/services/app_designs.dart';
import '../../../services/classification/tree_classification/tree_result_body.dart';
import '../../../utils/notificationservice.dart';
import '../../../services/classification/tree_classification/controller/result_controller.dart';

class ResultPage extends StatefulWidget {
  final File stageImage;
  final File image;
  final String latitude;
  final String longitude;
  final String username;

  const ResultPage({
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
  late ResultController _controller;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();

    _controller = ResultController(
      stageImage: widget.stageImage,
      image: widget.image,
      latitude: widget.latitude,
      longitude: widget.longitude,
      username: widget.username,
      context: context,
      onUpdate: () => setState(() {}),
    );
    _controller.initClassifier();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppDesigns.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _controller.isSaving
          ? _controller.buildSavingView()
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _controller.loading
                      ? _controller.buildLoadingView(context)
                      : ResultBody(controller: _controller),
                ),
              ),
            ),
    );
  }
}
