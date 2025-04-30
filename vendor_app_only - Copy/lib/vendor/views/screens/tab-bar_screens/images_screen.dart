import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vendor_app_only/vendor/provider/product_provider.dart';  // Update this import path

class ImagesScreen extends StatefulWidget {
  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ImagePicker picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<File> _image = [];

  List<String> _imageUrlList = [];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('no image picked');
    } else {
      setState(() {
        _image.add(File(pickedFile.path));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      _image.removeAt(index - 1);  // Subtract 1 because index 0 is the add button
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productProvider = Provider.of<ProductProvider>(context);  // Change this line
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: _image.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 8, childAspectRatio: 3 / 3),
            itemBuilder: ((context, index) {
              return index == 0
                  ? Center(
                      child: IconButton(
                          onPressed: () {
                            chooseImage();
                          },
                          icon: Icon(Icons.add)),
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_image[index - 1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 15,
                                color: Colors.white,
                              ),
                              onPressed: () => removeImage(index),
                            ),
                          ),
                        ),
                      ],
                    );
            }),
          ),
          SizedBox(
            height: 30,
          ),
          TextButton(
            onPressed: () async {
              if (_image.isEmpty) {
                EasyLoading.showError('Please select at least one image');
                return;
              }

              try {
                EasyLoading.show(status: 'Uploading Images...');
                _imageUrlList.clear();

                for (var img in _image) {
                  try {
                    final String fileName = '${Uuid().v4()}.jpg';
                    // Changed path to use 'images' folder instead of 'productImages'
                    final Reference ref = _storage
                        .ref()
                        .child('images')  // Changed to existing 'images' folder
                        .child(fileName);

                    // Set content type and metadata
                    final SettableMetadata metadata = SettableMetadata(
                      contentType: 'image/jpeg',
                      customMetadata: {
                        'picked-file-path': img.path,
                        'uploadedBy': FirebaseAuth.instance.currentUser!.uid
                      },
                    );

                    // Create upload task with metadata
                    final UploadTask uploadTask = ref.putFile(img, metadata);

                    // Monitor upload progress
                    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                      final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                      EasyLoading.showProgress(
                        progress / 100,
                        status: 'Uploading ${progress.toStringAsFixed(2)}%'
                      );
                    });

                    // Wait for upload to complete
                    final TaskSnapshot snapshot = await uploadTask;
                    
                    if (snapshot.state == TaskState.success) {
                      final String downloadUrl = await snapshot.ref.getDownloadURL();
                      setState(() {
                        _imageUrlList.add(downloadUrl);
                      });
                    } else {
                      throw Exception('Upload failed: ${snapshot.state}');
                    }
                  } catch (e) {
                    print('Error uploading image: $e');
                    EasyLoading.showError('Failed to upload image: ${e.toString()}');
                    return;
                  }
                }

                if (_imageUrlList.isNotEmpty) {
                  productProvider.getFormData(imageUrlList: _imageUrlList);
                  EasyLoading.showSuccess('Successfully uploaded ${_imageUrlList.length} images');
                  setState(() {
                    _image.clear();
                  });
                }
              } catch (e) {
                print('Error in upload process: $e');
                EasyLoading.showError('Upload failed: ${e.toString()}');
              } finally {
                EasyLoading.dismiss();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.yellow.shade900,
              foregroundColor: Colors.white,
            ),
            child: Text('Upload'),
          ),
        ],
      ),
    );
  }
}