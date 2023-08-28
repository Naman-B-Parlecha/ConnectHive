import 'dart:io';

import 'package:demo/Widget/ImagePicker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  File? onSelectedimage;
  var _isAuthenticating = false;
  final _Form = GlobalKey<FormState>();
  var _islogin = true;
  var enteredemail = '';
  var enteredpassword = '';
  var enteredname = '';

  void submit() async {
    final isValid = _Form.currentState!.validate();
    if (!isValid || (!_islogin && onSelectedimage == null)) {
      return;
    }
    _Form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_islogin) {
        final userCredentials = await fireBase.signInWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
      } else {
        final userCredentials = await fireBase.createUserWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);

        final storageref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredentials.user!.uid}.jpg');
        await storageref.putFile(onSelectedimage!);
        final imageUrl = await storageref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredname,
          'email': enteredemail,
          'password': enteredpassword,
          'image': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed')),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                child: Image.asset(
                  'assets/images/chat.png',
                  height: 200,
                  width: 200,
                ),
              ),
              Card(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _Form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_islogin)
                          UserImagePicker(
                            onSelectImage: (image) {
                              onSelectedimage = image;
                            },
                          ),
                        if (!_islogin)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username'),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 3) {
                                return 'enter a valid username(length greater than 3)';
                              }
                              return null;
                            },
                            enableSuggestions: false,
                            onSaved: (newValue) {
                              enteredname = newValue!;
                            },
                          ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Enter a valid email Address';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            enteredemail = newValue!;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.length < 6) {
                              return 'Enter a password with length greater than 6';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            enteredpassword = newValue!;
                          },
                        ),
                        SizedBox(height: 10),
                        if (_isAuthenticating) CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              onPressed: submit,
                              child: Text(_islogin ? 'Login' : 'Sign Up')),
                        if (!_isAuthenticating)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'create a new account'
                                  : 'already have an account'))
                      ],
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
