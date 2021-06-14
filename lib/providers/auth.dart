import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/http_exception/heep_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get getIsAuth {
    return _token != null;
  }

  String get getToke {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(String email, String password, urlSegment) async {
    const API_KEY = 'AIzaSyD_e8TLv0CjOBwwRm5RBKYiiM_qPfgOfeQ';
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$API_KEY');
    var response = null;

    try {
      response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(
            responseData['error']['message']); //throwing a costumized exception
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
    print(json.decode(response.body));
  }

  //method to sign user up
  Future<Void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp').then((value) => null);
  }

  Future<Void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword')
        .then((value) => null);
  }
}
