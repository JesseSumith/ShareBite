import 'package:flutter/material.dart';

class DonationForm extends StatefulWidget {
  final String token;
  const DonationForm({super.key, required this.token});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: call API with widget.token
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Donation submitted")));
      Navigator.pop(context);
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
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Pickup Address"),
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
