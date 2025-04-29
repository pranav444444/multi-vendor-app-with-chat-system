import 'package:flutter/material.dart';
import 'package:multi_vendor_app/views/screens/auth/register_screen.dart';
import 'package:multi_vendor_app/views/screens/auth/welcome_screens/welcome_login_screen.dart';

class WelcomeRegisterScreen extends StatefulWidget {
  const WelcomeRegisterScreen({super.key});

  @override
  State<WelcomeRegisterScreen> createState() => _WelcomeRegisterScreenState();
}

class _WelcomeRegisterScreenState extends State<WelcomeRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63),
              Color(0xFFFF748C),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Logo with improved styling
            Positioned(
              top: screenHeight * 0.12,
              left: screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.7,
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/icons/logo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // Customer Register Button
            Positioned(
              top: screenHeight * 0.641,
              left: screenWidth * 0.07,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerRegisterScreen()),
                  );
                },
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.085,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Register as Customer',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Seller Register AlertDialog
            Positioned(
              top: screenHeight * 0.77,
              left: screenWidth * 0.07,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.store, color: Color(0xFFE91E63)),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ChatterKart Vendors',
                                    style: TextStyle(
                                      color: Color(0xFFE91E63),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Please redirect to our ChatterKart Vendors App to register as a seller.',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.085,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Register as Seller',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Login Prompt
            Positioned(
              top: screenHeight * 0.88,
              left: screenWidth * 0.065,
              child: Row(
                children: [
                  const Text(
                    'Already Have An Account?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeLoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
