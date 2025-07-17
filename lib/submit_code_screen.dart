import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'create_password_screen.dart';

class SubmitCodeScreen extends StatefulWidget {
  final String email;

  const SubmitCodeScreen({super.key, required this.email});

  @override
  State<SubmitCodeScreen> createState() => _SubmitCodeScreenState();
}

class _SubmitCodeScreenState extends State<SubmitCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  bool isLoading = false;

  Future<void> _submitCode() async {
    if (!_formKey.currentState!.validate()) return;

    String otp = controllers.map((c) => c.text).join();
    print("Entered OTP: $otp");

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          "https://api.righted.in/api/auth/verify-otp?email=${widget.email}&otp=$otp");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);
      print("OTP Response: $data");

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? "OTP Verified Successfully!")),
        );

        // ✅ Navigate to Reset Password Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateNewPasswordScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "OTP verification failed")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Submit Code",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter the 4-digit code sent to\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index + 1]);
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index - 1]);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Resend Code Pressed")),
                    );
                  },
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
