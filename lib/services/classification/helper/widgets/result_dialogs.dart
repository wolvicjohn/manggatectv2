import 'package:flutter/material.dart';

import '../../../app_designs.dart';

Future<bool> showSaveConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppDesigns.backgroundColor,
            title: const Text(
              'Do you want to save this stage?',
              style: TextStyle(color: Colors.black, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No', style: AppDesigns.labelTextStyle),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes', style: AppDesigns.labelTextStyle),
              ),
            ],
          );
        },
      ) ??
      false;
}
