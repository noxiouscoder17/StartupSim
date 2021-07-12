import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:startupsim/Controllers/UserController.dart';

class DataController {
  Map<String, dynamic> userData, companyData;
  bool userExists;
  bool companyExists;

  final currentUser = UserController().currentUser();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');

  void uploadUserData(Map<String, dynamic> data) async {
    await users.doc(currentUser.uid).set(data);
  }

  void uploadCompanyData(Map<String, dynamic> data, String companyName) async {
    await company.doc(companyName).set(data);
  }

  void updateCompanyData(Map<String, dynamic> data, String companyName) async {
    await company.doc(companyName).update(data);
  }

  void fetchUserData() async {
    final currentUser = await UserController().currentUser();
    await users.doc(currentUser.uid).get().then((querySnapshots) {
      userData = querySnapshots.data() as Map<String, dynamic>;
    });
  }

  void fetchCompanyData() async {
    final currentUser = await UserController().currentUser();
    await company.doc(userData['companyName']).get().then((querySnapshots) {
      companyData = querySnapshots.data() as Map<String, dynamic>;
    });
  }

  void ifUserDataExists() async {
    final currentUser = await UserController().currentUser();
    await users.doc(currentUser.uid).get().then((querySnapshots) {
      if (querySnapshots.exists) {
        userExists = true;
      } else {
        userExists = false;
      }
    });
  }

  void ifCompanyDataExists(String companyName) async {
    await company.doc(companyName).get().then((result) {
      if (result.exists) {
        companyExists = true;
      } else {
        companyExists = false;
      }
    });
  }
}
