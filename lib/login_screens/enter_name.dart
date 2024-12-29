import 'package:becho_project/login_screens/location_screen.dart';
import 'package:flutter/material.dart';

class EnterName extends StatefulWidget {
  const EnterName({Key? key}) : super(key: key);

  @override
  State<EnterName> createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Track whether the button should be enabled
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to check for text input changes
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Remove the listener and dispose of the controller
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    super.dispose();
  }

  // Update the button state when the text field changes
  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s your name?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stranger feels so impersonal. You know?',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationScreen(),
                      ),
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _isButtonEnabled ? Colors.blue : Colors.grey,
                  foregroundColor:
                  _isButtonEnabled ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}