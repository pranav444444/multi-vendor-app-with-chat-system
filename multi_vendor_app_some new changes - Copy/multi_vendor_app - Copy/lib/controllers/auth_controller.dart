import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  ///function to select image from gallery and camera
  
  pickProfileImage(ImageSource source) async {
    // Add functionality to upload/select photo
   final ImagePicker _imagePicker=ImagePicker();

   XFile? _file= await _imagePicker.pickImage(source: source);

   if(_file!=null){
     return await _file.readAsBytes();//returning the image as bytes so that computer can understand it
   }else{
    print('No image selected or captured');
   }

  }

  ///Function to upload image to firebase storage
  
_uploadImageToStorage(Uint8List ?image)async{
Reference ref=_storage.ref().child('profileImages').child(auth.currentUser!.uid);//name of the image will be user uid
UploadTask uploadTask=ref.putData(image!);

TaskSnapshot snapshot=await uploadTask;

String downloadURL=await snapshot.ref.getDownloadURL();

return downloadURL;
}

  Future<String> createNewUser(
      String email, String fullName, String password,Uint8List ? image) async {
    String res = 'Some error occurred';
    try {
      // Create a new user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String downloadUrl = await _uploadImageToStorage(image);

      // Add user details to Firestore
      await firestore.collection('buyers').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'profileImage': downloadUrl,
        'email': email,
        'buyerId': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(), // Optional timestamp
      });

      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'Email already in use';
      } else if (e.code == 'weak-password') {
        res = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        res = 'Invalid email address';
      } else {
        res = e.message ?? 'An error occurred';
      }
    } catch (e) {
      res = 'An unexpected error occurred: $e';
    }
    return res;
  }

  ///fUNCTION TO LOGIN THE CREATED USER
  
  Future<String> loginUser(String email, String password) async {
    String res = 'Some error occurred';
    try {
      // Sign in user with email and password
      await auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided for that user';
      } else if (e.code == 'invalid-email') {
        res = 'Invalid email address';
      } else {
        res = e.message ?? 'An error occurred';
      }
    } catch (e) {
      res = 'An unexpected error occurred: $e';
    }
    return res;
  }
}
