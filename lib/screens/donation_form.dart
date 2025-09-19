import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonationForm extends StatefulWidget {
  final String token;
  final int donorId;

  const DonationForm({super.key, required this.token, required this.donorId});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final String baseUrl = "http://10.10.10.127:8080";

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

      final url = Uri.parse(
        "$baseUrl/ShareBite/donations/create/${widget.donorId}",
      );

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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Donation submitted successfully")),
          );
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting donation: $e")),
        );
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Food"),
        elevation: 4,
        backgroundColor: Colors.deepOrange.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.deepOrange.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Please fill in the donation details",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.deepOrange.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _foodTypeController,
                    decoration: _inputDecoration(
                      label: "Food Type",
                      icon: Icons.fastfood,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: _inputDecoration(
                      label: "Quantity",
                      icon: Icons.format_list_numbered,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      if (int.tryParse(v) == null || int.parse(v) <= 0)
                        return "Enter a valid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration(
                      label: "Street / Address",
                      icon: Icons.location_on,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration(
                      label: "City",
                      icon: Icons.location_city,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    decoration: _inputDecoration(
                      label: "State",
                      icon: Icons.map,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinCodeController,
                    decoration: _inputDecoration(
                      label: "Pin Code",
                      icon: Icons.pin,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      if (!RegExp(r'^\d{5,6}$').hasMatch(v))
                        return "Invalid Pin Code";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _estimatedValueController,
                    decoration: _inputDecoration(
                      label: "Estimated Value",
                      icon: Icons.attach_money,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      if (double.tryParse(v) == null || double.parse(v) < 0)
                        return "Enter a valid value";
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text("Submit Donation"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
