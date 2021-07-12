import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Controller/ValidationController.dart';

class FireStore {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  Map<String, dynamic> data;
  FireStore();
  void test() {
    data = {
      "Name": "Bhavishya",
      "Level": 7,
      "isRegistered": true,
    };
    users.doc(Validation().currentUser().uid).set(data);
  }
}
