import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static const String userLoggedInKey = "loggedInKey";
  static const String userNameKey = "userNameKey";
  static const String userEmailKey = "userEmailKey";

  // Save login status
  static Future<void> setUserLoggedInStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedInKey, isLoggedIn);
  }

  // Retrieve login status
  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  // Save username
  static Future<void> setUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  // Retrieve username
  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  // Save user email
  static Future<void> setUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, userEmail);
  }

  // Retrieve user email
  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }
}
