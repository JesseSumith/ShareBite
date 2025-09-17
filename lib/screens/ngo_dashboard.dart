import 'package:flutter/material.dart';
import 'main_drawer.dart';

class NgoDashboard extends StatelessWidget {
  final String token;
  const NgoDashboard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with API call
    return Scaffold(
      appBar: AppBar(title: const Text("NGO Dashboard")),
      drawer: MainDrawer(token: token, role: "NGO"), // ✅ added drawer
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (_, i) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text("Donation #$i"),
            subtitle: const Text("Rice - 5kg, Donor: John"),
            trailing: ElevatedButton(
              onPressed: () {}, // TODO: claim API call
              child: const Text("Claim"),
            ),
          ),
        ),
      ),
    );
  }
}
