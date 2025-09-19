import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonationForm extends StatefulWidget {
  final String token;
  final int donorId; // ✅ add donorId

  const DonationForm({
    super.key,
    required this.token,
    required this.donorId, // ✅ make it required
  });

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final String baseUrl = "http://10.10.10.127:8080"; // change easily later

  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _estimatedValueController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final foodType = _foodTypeController.text.trim();
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final street = _addressController.text.trim();
      final city = _cityController.text.trim();
      final state = _stateController.text.trim();
      final pinCode = _pinCodeController.text.trim();
      final estimatedValue =
          double.tryParse(_estimatedValueController.text.trim()) ?? 0.0;

      final donorId = 1; // <-- replace with actual logged-in donor ID

      final url = Uri.parse("$baseUrl/ShareBite/donations/create/$donorId");

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.token}",
          },
          body: jsonEncode({
            "foodType": foodType,
            "quantity": quantity,
            "street": street,
            "city": city,
            "state": state,
            "pinCode": pinCode,
            "estimatedValue": estimatedValue,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Donation submitted successfully")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting donation: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donate Food")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _foodTypeController,
                decoration: const InputDecoration(labelText: "Food Type"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Street / Address",
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: "State"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pinCodeController,
                decoration: const InputDecoration(labelText: "Pin Code"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estimatedValueController,
                decoration: const InputDecoration(labelText: "Estimated Value"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
