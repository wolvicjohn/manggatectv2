import 'package:flutter/material.dart';
import 'package:manggatectv2/services/app_designs.dart';
import 'package:manggatectv2/services/button_design.dart';
import '../helper/widgets/care_card.dart';
import '../helper/widgets/result_maps.dart';
import 'controller/result_controller.dart';


class ResultBody extends StatelessWidget {
  final ResultController controller;

  const ResultBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    debugPrint("controller.result: ${controller.result}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.file(
            controller.stageImage,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            controller.result,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDesigns.primaryColor,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Card(
            elevation: 1,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                stageDescriptions[controller.stage] ??
                    'No description available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Care Recommendations",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        CareCard(
          icon: Icons.water_drop,
          title: "Care",
          content: careRecommendations[controller.stage] ??
              'No recommendations available',
          color: Colors.blue.shade100,
        ),
        const SizedBox(height: 12),
        CareCard(
          icon: Icons.grass,
          title: "Fertilization",
          content:
              fertilizationAdvice[controller.stage] ?? 'No advice available',
          color: Colors.green.shade100,
        ),
        const SizedBox(height: 12),
        CareCard(
          icon: Icons.content_cut,
          title: "Pruning",
          content: pruningAdvice[controller.stage] ?? 'No advice available',
          color: Colors.amber.shade100,
        ),
        const SizedBox(height: 12),
        CareCard(
          icon: Icons.bug_report,
          title: "Pest Control",
          content: pestControl[controller.stage] ?? 'No information available',
          color: Colors.red.shade100,
        ),
        const SizedBox(height: 28),
        controller.stage != "Invalid"
            ? FeatureCard(
                title: "Save Information",
                icon: Icons.save_alt,
                onTap: controller.saveToFirestore,
                color: AppDesigns.primaryColor,
                delay: 200)
            : const SizedBox.shrink(),
      ],
    );
  }
}
