import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(String email, String password, urlSegment) async {
    const API_KEY = 'AIzaSyD_e8TLv0CjOBwwRm5RBKYiiM_qPfgOfeQ';
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$API_KEY');

    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    print(json.decode(response.body));
  }

  //method to sign user up
  Future<Void> signup(String email, String password) async {
    _authenticate(email, password, 'signUp');
  }

  Future<Void> signin(String email, String password) async {
    _authenticate(email, password, 'signInWithPassword');
  }
}
