import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manggatectv2/services/app_designs.dart';
import '../../../services/classification/qr_classification/controller/qr_result_controller.dart';
import '../../../services/classification/qr_classification/qr_result_body.dart';
import '../../../utils/notificationservice.dart';

class QrResultPage extends StatefulWidget {
  final File stageImage;
  final String DocId;
  final String username;

  const QrResultPage({
    Key? key,
    required this.stageImage,
    required this.username,
    required this.DocId,
  }) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<QrResultPage> {
  late ResultController _controller;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();

    _controller = ResultController(
      widget.DocId,
      stageImage: widget.stageImage,
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
