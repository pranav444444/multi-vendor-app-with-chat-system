import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateControllers();
    
    // Add listener for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null && user.emailVerified) {
        // Update Firestore after email verification
        _updateFirestore(user);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _populateControllers() async {
    setState(() => _isLoading = true);
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = 
            await _firestore.collection('buyers').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _emailController.text = userData['email'] ?? '';
            _fullNameController.text = userData['fullName'] ?? '';
            _profileImage = userData['profileImage'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this validation method to _EditProfileScreenState
  bool _isValidEmail(String email) {
    // More comprehensive email validation
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      // Validate email format before attempting update
      final String newEmail = _emailController.text.trim();
      if (!_isValidEmail(newEmail)) {
        throw 'Please enter a valid email address';
      }

      // Only attempt email update if it has changed
      if (user.email != newEmail) {
        String? password = await _getPasswordFromUser();
        if (password == null || password.isEmpty) {
          throw 'Password is required to update email';
        }

        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );

          // Reauthenticate user
          await user.reauthenticateWithCredential(credential);

          // Send verification email to new address
          await user.verifyBeforeUpdateEmail(newEmail);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification email sent to $newEmail\nPlease check your email and verify.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 5),
            ),
          );

          return; // Wait for email verification
        } on FirebaseAuthException catch (e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-email':
              errorMessage = 'The email address is not properly formatted';
              break;
            case 'email-already-in-use':
              errorMessage = 'This email is already registered';
              break;
            case 'requires-recent-login':
              errorMessage = 'Please sign out and sign in again before changing email';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password';
              break;
            default:
              errorMessage = e.message ?? 'An error occurred while updating email';
          }
          throw errorMessage;
        }
      }

      // Update other profile information
      await _firestore.collection('buyers').doc(user.uid).update({
        'fullName': _fullNameController.text.trim(),
        if (_profileImage != null) 'profileImage': _profileImage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      print('Update profile error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent. Please verify your email before updating.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Email verification error: $e');
      throw 'Failed to send verification email';
    }
  }

  Future<String?> _getPasswordFromUser() async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text('Confirm Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter your current password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                password = passwordController.text;
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
    return password;
  }

  Future<void> _updateFirestore(User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.uid)
          .update({
        'fullName': _fullNameController.text.trim(),
        'email': user.email,
        if (_profileImage != null) 'profileImage': _profileImage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      print('Firestore update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile information'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter Email',
                      errorText: _emailController.text.isNotEmpty && !_isValidEmail(_emailController.text)
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to show/hide error text
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(hintText: 'Enter full Name'),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      _updateProfile();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}