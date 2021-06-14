import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/http_exception/heep_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

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

  String get getUserId {
    return _userId;
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
      autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      await prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    print(json.decode(response.body));
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expirydate = DateTime.parse(extractedUserData['expiryDate']);

    if (expirydate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expirydate;
    notifyListeners();
    autoLogout();
    return true;
  }

  //method to sign user up
  Future<Void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp').then((value) => null);
  }

  Future<Void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword')
        .then((value) => null);
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
      final prefs = await SharedPreferences.getInstance();
      // prefs.clear();
      prefs.remove('userData');
    }

    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () => logOut());
    print('timeToExpiry : $timeToExpiry seconds');
  }
}
