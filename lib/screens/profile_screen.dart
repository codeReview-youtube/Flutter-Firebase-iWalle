import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iwalle/services/auth_service.dart';
import 'package:iwalle/services/firestore_service.dart';
import 'package:iwalle/widgets/profile_picture.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _toggleFields = false;
  bool _showCodeField = false;
  String _verificationId = '';
  String _userId = '';
  String _name = '';
  String _phoneNumber = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCode = TextEditingController();

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
      firestoreService.usersRef.doc(user.uid).snapshots().listen((event) {
        final data = event.data();
        if (data != null) {
          _name = data['name'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final user = await authService.currentUser;

    if (user != null) {
      await firestoreService.usersRef.doc(user.uid).set({
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
      });
      await user.updateDisplayName(_nameController.text);
      await authService.auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) {
          user.updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The provided phone number is not valid.'),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _toggleFields = false;
            _showCodeField = true;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      setState(() {
        _toggleFields = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    final user = await authService.currentUser;
    if (user != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCode.text,
      );
      await user.updatePhoneNumber(credential);
      setState(() {
        _showCodeField = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Row(
            children: [
              ProfilePicture(),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<User?>(
              future: authService.currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.data != null) {
                  final user = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildText(
                        'Name: ',
                        _name,
                      ),
                      const SizedBox(height: 10),
                      _buildText('Phone number: ', _phoneNumber),
                      const SizedBox(height: 10),
                      _buildText(
                        'Email: ',
                        user.email,
                      ),
                      const SizedBox(height: 10),
                      _buildText(
                        'Is Email verified: ',
                        user.emailVerified.toString(),
                      ),
                    ],
                  );
                }
                return const Text('Not found');
              }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _toggleFields = true;
              });
            },
            child: const Text('Update Profile'),
          ),
          const SizedBox(height: 20),
          if (_toggleFields)
            Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Save'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          if (_showCodeField)
            Column(children: [
              TextFormField(
                controller: _smsCode,
                decoration: const InputDecoration(
                  labelText: 'Enter code',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text('Verify code'),
              ),
              const SizedBox(height: 20),
            ]),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    ));
  }

  Widget _buildText(String title1, String? title2) {
    return Row(
      children: [
        Text(
          title1,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(width: 10),
        Text(title2 ?? ''),
      ],
    );
  }
}
