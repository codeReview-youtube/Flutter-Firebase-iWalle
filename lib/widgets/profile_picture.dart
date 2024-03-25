import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iwalle/services/auth_service.dart';
import 'package:iwalle/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  String _imageUrl =
      'https://img.freepik.com/free-vector/user-circles-set_78370-4704.jpg';
  bool _progress = false;
  String _userId = '';

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  Future<void> _getUserData() async {
    final user = await authService.currentUser;

    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      final snapshot = await firestoreService.usersRef.doc(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['imageUrl'] != null) {
          setState(() {
            _imageUrl = data['imageUrl'];
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _progress = true;
    });
    if (_userId.isEmpty) {
      return;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = pickedFile.path.split('/').last;
      final destination = 'profile-images/$fileName';
      await FirebaseStorage.instance.ref(destination).putFile(file);
      final downloadedUrl =
          await FirebaseStorage.instance.ref(destination).getDownloadURL();
      setState(() {
        _imageUrl = downloadedUrl;
        _progress = false;
      });
      await firestoreService.usersRef.doc(_userId).update({
        'imageUrl': downloadedUrl,
      });
    }

    setState(() {
      _progress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                  image: Image.network(_imageUrl).image,
                  fit: BoxFit.cover,
                )),
          ),
          _progress
              ? const CircularProgressIndicator()
              : const Positioned(
                  bottom: 10,
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }
}
