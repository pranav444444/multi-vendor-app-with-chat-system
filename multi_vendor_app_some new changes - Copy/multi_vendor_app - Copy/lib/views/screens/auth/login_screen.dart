import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_vendor_app/controllers/auth_controller.dart';
import 'package:multi_vendor_app/views/screens/auth/register_screen.dart';
import 'package:multi_vendor_app/views/screens/map_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  @override
  _CustomerLoginScreenState createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController authController = AuthController();
  String email = '';
  String password = '';

  bool _isLoading = false;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      print('Attempting to log in...');
      String res = await authController.loginUser(email, password);

      setState(() {
        _isLoading = false;
      });

      // Check the response from AuthController
      if (res == 'success') {
        setState(() {
          _isLoading = false;
        });
        Get.to(MapScreen());
        Get.snackbar('Login Success', 'You are now logged in',
            backgroundColor: Colors.pink, colorText: Colors.white);
        // Navigate to the next screen or show success message
      } else {
        Get.snackbar('Login Failed', 'Please check your email and password',
            backgroundColor: Colors.cyanAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        // Show error message
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade800,
                  Colors.pink.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Login Form
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Email TextField
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter Email Address',
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password TextField
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    obscureText: true, // Hides password input
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Enter Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Login Button
                  InkWell(
                    onTap: () {
                      loginUser();
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade300,
                            Colors.purple.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Register Prompt
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerRegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
