import 'dart:async';
import '../core/constants/app_constants.dart';
import '../models/user.dart';

class AuthService {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Demo user login
  Future<User> loginDemoUser() async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulated latency
    _currentUser = const User(
      id: AppConstants.demoUserId,
      name: AppConstants.demoUserName,
      phone: AppConstants.demoUserPhone,
      email: AppConstants.demoUserEmail,
      accountAgeDays: 320,
      trustedDevices: ['DEVICE001', 'DEVICE002'],
      currentDeviceId: AppConstants.defaultDeviceId,
      currentLocation: AppConstants.defaultLocation,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  // Simulated login with phone and PIN
  Future<User> loginWithCredentials(String phone, String pin) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Accept valid format phone (e.g. 11 digits) and 4-digit PIN
    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleanedPhone.length < 11) {
      throw Exception('অনুগ্রহ করে সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন');
    }
    if (pin.length != 4) {
      throw Exception('৪ ডিজিটের পিন কোড দিন');
    }

    _currentUser = User(
      id: cleanedPhone == AppConstants.demoUserPhone ? AppConstants.demoUserId : 'USER_${cleanedPhone.substring(cleanedPhone.length - 4)}',
      name: cleanedPhone == AppConstants.demoUserPhone ? AppConstants.demoUserName : 'MFS Customer',
      phone: cleanedPhone,
      email: 'user@upay.com.bd',
      accountAgeDays: 240,
      trustedDevices: ['DEVICE001'],
      currentDeviceId: AppConstants.defaultDeviceId,
      currentLocation: 'Dhaka, Bangladesh',
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
  }
}

