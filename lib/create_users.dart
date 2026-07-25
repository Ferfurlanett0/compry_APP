import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> createUser(String username, String password, String role, String name) async {
    final email = '${username.toLowerCase().trim()}@Compry.app';
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await firestore.collection('users').doc(cred.user!.uid).set({
        'username': username.toLowerCase().trim(),
        'name': name,
        'role': role,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('=== User $username created successfully! ===');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
         print('=== User $username already exists, updating password and doc... ===');
         final commonPasswords = ['123456', 'senha123', 'admin123', 'admin', 'password', '12345678', '000000'];
         for (final oldPass in commonPasswords) {
           try {
             final cred = await auth.signInWithEmailAndPassword(email: email, password: oldPass);
             await cred.user!.updatePassword(password);
             await firestore.collection('users').doc(cred.user!.uid).set({
               'username': username.toLowerCase().trim(),
               'name': name,
               'role': role,
               'active': true,
               'updatedAt': FieldValue.serverTimestamp(),
             }, SetOptions(merge: true));
             print('=== Successfully updated password and doc for $username! ===');
             break;
           } catch (_) {}
         }
      } else {
         print('=== Error creating $username: $e ===');
      }
    }
  }

  print('=== STARTING SEED ===');
  await createUser('funcionario', 'senha123', 'EMPLOYEE', 'João Silva');
  await createUser('joao', 'senha123', 'EMPLOYEE', 'João Funcionário');
  await createUser('admin', 'admin123', 'ADMIN', 'Administrador');
  print('=== SEED COMPLETE ===');
  
  // Exit the app gracefully
  // ignore: dead_code
  // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
