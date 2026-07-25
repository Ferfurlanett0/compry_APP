import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lista_pro/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final snap = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: 'funcionario').get();
  for (var doc in snap.docs) {
    print('USER DATA: \');
  }
}
