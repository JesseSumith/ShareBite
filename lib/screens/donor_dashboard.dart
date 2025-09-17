import 'package:flutter/material.dart';
import 'donation_form.dart';
import 'main_drawer.dart';

class DonorDashboard extends StatelessWidget {
  final String token;
  const DonorDashboard({super.key, required this.token});

  void _donateAgain(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonationForm(token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: replace with API call
    bool hasDonations = true;

    return Scaffold(
      appBar: AppBar(title: const Text("Donor Dashboard")),
      drawer: MainDrawer(token: token, role: "DONOR"), // ✅ added drawer
      body: hasDonations
          ? Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "My Donations",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("Donation #$i"),
                        subtitle: const Text("Rice - 5kg"),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _donateAgain(context),
                    child: const Text("Donate Again"),
                  ),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: () => _donateAgain(context),
                child: const Text("Create First Donation"),
              ),
            ),
    );
  }
}
