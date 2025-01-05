import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enter_name.dart';

class OtpScreen extends StatefulWidget {
  final String contactInfo; // This will hold the phone number or email
  final String verificationId; // The verification ID from Firebase

  const OtpScreen({Key? key, required this.contactInfo, required this.verificationId}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isButtonEnabled = false; // Track if the button should be enabled

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Update the OTP input and check if all fields are filled
  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // When the user finishes entering the OTP in the last field
        _validateOTP();
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }

    // Check if all OTP fields are filled to enable the button
    bool allFieldsFilled =
    _controllers.every((controller) => controller.text.isNotEmpty);
    setState(() {
      _isButtonEnabled = allFieldsFilled;
    });
  }

  // Function to validate the OTP
  void _validateOTP() async {
    String enteredOtp =
    _controllers.map((controller) => controller.text).join();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterName(),
        ),
      );
    } catch (e) {
      // Show an error message if the OTP is incorrect
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid OTP"),
          content: const Text("The OTP you entered is incorrect."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter verification code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            // Dynamic message based on the contact type (phone or email)
            Text(
              'We sent a 4-digit code to ${widget.contactInfo}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Icon(
                Icons.search,
                size: 100,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                return SizedBox(
                  height: 60,
                  width: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  _validateOTP();
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