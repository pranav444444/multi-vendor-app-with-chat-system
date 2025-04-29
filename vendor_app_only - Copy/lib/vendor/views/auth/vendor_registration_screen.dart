import 'dart:typed_data';

import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app_only/vendor/views/auth/controller/vendor_controller.dart';

class VendorRegistrationScreen extends StatefulWidget {
  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final VendorController _vendorController = VendorController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? _image;
  String emailAddress = '';
  String phoneNumber = '';
  String businessName = '';
  String countryValue = '';
  String stateValue = '';
  String cityValue = '';

  Future<void> selectGalleryImage() async {
    Uint8List? im = await _vendorController.pickStoreImage(ImageSource.gallery) as Uint8List?;

    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  Future<void> selectCameraImage() async {
    Uint8List? im = await _vendorController.pickStoreImage(ImageSource.camera) as Uint8List?;

    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.pink,
            toolbarHeight: 200,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  background: Center(
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _image != null
                          ? ClipOval(child: Image.memory(_image!, fit: BoxFit.cover))
                          : IconButton(
                              onPressed: selectGalleryImage,
                              icon: Icon(CupertinoIcons.photo),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill business name';
                        }
                        return null;
                      },
                      onChanged: (value) => businessName = value,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Business Name',
                        hintText: 'Business Name',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        return null;
                      },
                      onChanged: (value) => emailAddress = value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill phone number';
                        }
                        return null;
                      },
                      onChanged: (value) => phoneNumber = value,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SelectState(
                      onCountryChanged: (value) {
                        setState(() {
                          countryValue = value;
                        });
                      },
                      onStateChanged: (value) {
                        setState(() {
                          stateValue = value;
                        });
                      },
                      onCityChanged: (value) {
                        setState(() {
                          cityValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              EasyLoading.show(status: 'Please wait...');
              _vendorController
                  .vendorRegistrationForm(
                    businessName,
                    phoneNumber,
                    emailAddress,
                    countryValue,
                    stateValue,
                    cityValue,
                    _image,
                  )
                  .whenComplete(() => EasyLoading.dismiss());
            } else {
              print('Form validation failed');
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
