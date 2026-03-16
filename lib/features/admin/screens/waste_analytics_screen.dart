import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WasteAnalyticsScreen extends StatelessWidget {
  const WasteAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF1B5E36);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Waste Analytics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('disposal_history')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error loading data"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: brandGreen),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          int organicCount = 0;
          int plasticCount = 0;
          int glassCount = 0;

          for (var doc in docs) {
            String type =
                (doc.data() as Map<String, dynamic>)['wasteType'] ?? 'Organic';
            if (type == 'Organic')
              organicCount++;
            else if (type == 'Plastic')
              plasticCount++;
            else if (type == 'Glass')
              glassCount++;
          }

          int total = organicCount + plasticCount + glassCount;

          double organicPct = total == 0 ? 0 : (organicCount / total);
          double plasticPct = total == 0 ? 0 : (plasticCount / total);
          double glassPct = total == 0 ? 0 : (glassCount / total);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Activity Overview",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),

                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 60,
                        color: brandGreen,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$total",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Total Disposals Recorded",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Waste Type Distribution",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),

                _buildLiveAnalyticsRow("Organic", organicPct, Colors.green),
                _buildLiveAnalyticsRow("Plastic", plasticPct, Colors.orange),
                _buildLiveAnalyticsRow("Glass", glassPct, Colors.blue),

                const SizedBox(height: 40),
                _buildSummaryCard(
                  "Most Frequent",
                  organicCount >= plasticCount && organicCount >= glassCount
                      ? "Organic"
                      : plasticCount >= glassCount
                      ? "Plastic"
                      : "Glass",
                  brandGreen,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveAnalyticsRow(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text("${(percent * 100).toStringAsFixed(1)}%"),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}