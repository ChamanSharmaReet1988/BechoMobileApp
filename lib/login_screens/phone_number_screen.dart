import 'otp_screen.dart';
import '../Utility/constant.dart';
import 'package:flutter/material.dart';
import '../Utility/preference_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumberScreen extends StatefulWidget {
  final bool
      isEmailLogin; // Flag to determine if the screen should work as email or phone

  const PhoneNumberScreen({super.key, this.isEmailLogin = false});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isButtonEnabled = false;
  String selectedCountryCode = '+91';
  String verificationId = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    // login(context);
  }

  void _onInputChanged(String value) {
    setState(() {
      if (widget.isEmailLogin) {
        // Enable button if the email is valid
        _isButtonEnabled = RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value);
      } else {
        // Enable button if the phone number is 10 digits
        _isButtonEnabled = value.length == 10;
      }
    });
  }

  void _navigateToOtpScreen() {
    String verificationDetail;
    if (widget.isEmailLogin) {
      verificationDetail = _controller.text.trim(); // Email
    } else {
      verificationDetail = selectedCountryCode +
          _controller.text.trim(); // Phone number with country code
    }

    // Navigate to OTP screen and pass the verification details
    if (_formKey.currentState!.validate()) {
      // login(context);
    }
  }

  void login() async {
    try {
      debugPrint(
          "Attempting phone verification for: ${selectedCountryCode + _controller.text.trim()}");

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: selectedCountryCode + _controller.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("Verification completed automatically.");
          await FirebaseAuth.instance.signInWithCredential(credential);
          // Navigate to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                contactInfo: selectedCountryCode + _controller.text.trim(),
                verificationId:
                    "", // Pass a dummy value here for auto-verification
              ),
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Detailed error logging
          debugPrint("Verification failed with message: ${e.message}");
          debugPrint("Error code: ${e.code}");
          debugPrint("Complete error: ${e.toString()}");

          // Show error in the UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Verification failed."),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("Code sent. Verification ID: $verificationId");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                contactInfo: selectedCountryCode + _controller.text.trim(),
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
              "Code auto-retrieval timeout. Verification ID: $verificationId");
        },
      );
    } catch (e) {
      debugPrint("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void login() {
  //   var url = '${ApiConstants.baseUrl}${ApiConstants.userLogin}';
  //   var body = {
  //     'phone': _controller.text.trim(), // Trim input to remove whitespace
  //   };
  //
  //   HandleRequest(context).handleRequest(
  //     'POST',
  //     url,
  //     "", // No token since `authRequired` is false
  //     false,
  //     body: body,
  //     callback: (responseBody, {bool isError = false}) {
  //       if (isError) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               responseBody,
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       } else {
  //         // Parse the response and handle success
  //         final jsonResponse = jsonDecode(responseBody);
  //         final message = jsonResponse['message'] ?? 'Login successful!';
  //         print('Response: $jsonResponse'); // Debugging
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               message,
  //               style: const TextStyle(color: Colors.white),
  //             ),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //
  //         // Proceed with navigation or other actions
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => OtpScreen(
  //               contactInfo: _controller.text.trim(),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section on the Left Side
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/images/avatar.png', // Path to your local image
              ),
            ),
            const SizedBox(height: 20),

            // Change Text Based on Login Type (Phone or Email)
            Text(
              widget.isEmailLogin
                  ? 'Enter Your Email'
                  : 'Enter Your Phone Number',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isEmailLogin
                  ? "we'll send you a verification link to your email"
                  : "we'll send you a verification code on the same number",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),

            // Conditional Input Field (Email or Phone)
            widget.isEmailLogin
                ? TextFormField(
                    controller: _controller,
                    onChanged: _onInputChanged,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(fontSize: 16),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  )
                : Row(
                    children: [
                      // Country Code Picker (Only for Phone Number)
                      DropdownButton<String>(
                        value: selectedCountryCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        items: Constant.countryCodes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          onChanged: _onInputChanged,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(fontSize: 16),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 30),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                // onPressed: _isButtonEnabled ? _navigateToOtpScreen : null,
                onPressed: _isButtonEnabled ? () => login() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? Colors.blue : Colors.grey,
                  foregroundColor:
                      _isButtonEnabled ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: Size(double.infinity, 50),
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
