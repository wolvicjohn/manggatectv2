import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manggatectv2/services/app_designs.dart';
import '../../services/firestore.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: AppDesigns.titleTextStyle2),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getAllMangoTrees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppDesigns.loadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Error: ${snapshot.error}', style: AppDesigns.bodyText2),
            );
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return const Center(
              child: Text('No history found.', style: AppDesigns.bodyText2),
            );
          }

          _controller.forward(); // Start the animation when data is loaded

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final timestamp = item['timestamp'];
              final formattedDate = timestamp != null
                  ? DateFormat('EEEE, MMM d, yyyy h:mm a')
                      .format(timestamp.toDate())
                  : 'N/A';

              return AppDesigns.staggeredAnimation(
                controller: _controller,
                index: index,
                totalItems: data.length,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(12, 2.5, 12, 2.5),
                  elevation: 6.0,
                  color: AppDesigns.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: item['stageImageUrl'] != null
                        ? Image.network(item['stageImageUrl'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                    title: Text(
                      '${item['stage'] ?? 'Unknown'}',
                      style: AppDesigns.titleTextStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Uploaded on: $formattedDate',
                            style: AppDesigns.bodyText),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
