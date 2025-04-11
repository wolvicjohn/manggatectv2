import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manggatectv2/services/app_designs.dart';
import '../../services/firestore.dart';
import 'treedetails.dart';

class HistoryPage extends StatefulWidget {
  final String username;
  const HistoryPage({Key? key, required this.username}) : super(key: key);

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

          _controller.forward();

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final imageUrl = item['stageImageUrl'];
              final timestamp = item['timestamp'];
              final formattedDate = timestamp != null
                  ? DateFormat('EEEE, MMM d, yyyy h:mm a')
                      .format(timestamp.toDate())
                  : 'N/A';

              return AppDesigns.staggeredAnimation(
                controller: _controller,
                index: index,
                totalItems: data.length,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StageDetailsPage(
                          docId: item['id'],
                          username: widget.username,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15.0),
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
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: item['imageUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                          imageUrl: imageUrl!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                  width: 100,
                                                  height: 100,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: AppDesigns
                                                      .loadingIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                    Icons.error_outline),
                                              )),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: const Icon(
                                          Icons.image_not_supported_outlined),
                                    ),
                            )
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
