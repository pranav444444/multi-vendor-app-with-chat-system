import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_vendor_app/controllers/auth_controller.dart';
import 'package:multi_vendor_app/views/screens/auth/login_screen.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({Key? key}) : super(key: key);

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final AuthController authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? email;
  String? fullName;
  String? password;

  Uint8List? _image;  //to store the image as bytes for profile image

  Future<void> selectGalleryImage() async {
    Uint8List im = await authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  Future<void> captureImage() async {
    Uint8List im = await authController.pickProfileImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }

  Future<void> registerUser() async {
    if (_image != null) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        
        String res = await authController.createNewUser(email!, fullName!, password!, _image!);

        setState(() {
          _isLoading = false;
        });

        if (res == 'success') {
          Get.to(() => CustomerLoginScreen());
          Get.snackbar(
            'Success', 
            'Account created successfully',
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
            icon: const Icon(Icons.message, color: Colors.white)
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'Register Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
                    _image==null ? CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ):CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: MemoryImage(_image!),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 10,
                      child: InkWell(
                        onTap: () {
                          // Add functionality to upload/select photo
                          print("Photo icon tapped");
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.pink,
                          child: IconButton(onPressed: (){
                            selectGalleryImage();
                          }, icon:Icon(CupertinoIcons.photo,),)
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Address must not be empty';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter Email Address',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.pink,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      fullName = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full Name must not be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter Full Name',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.pink,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password must not be empty';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.pink,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    await registerUser();
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child:_isLoading ? CircularProgressIndicator(color:Colors.white,) : Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return CustomerLoginScreen();
                    }));

                    
                  },
                  child: Text(
                    'Already have an Account? Login',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
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
