import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isDarkModeOn = false;
  bool _isExpiryAlertOn = true;
  String _displayName = "User Name";
  String _email = "user@example.com";
  String _photoUrl = "";
  bool _isLoading = false;

  bool get isDarkModeOn => _isDarkModeOn;
  bool get isExpiryAlertOn => _isExpiryAlertOn;
  String get displayName => _displayName;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;

  Future<void> fetchUserSettings() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkModeOn = prefs.getBool('isDarkMode') ?? false;

      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _isExpiryAlertOn = data['isExpiryAlert'] ?? true;
          _displayName = data['displayName'] ?? "User Name";
          _email = data['email'] ?? "user@example.com";
          _photoUrl = data['photoUrl'] ?? "";
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Lỗi load data: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveProfile({required String name, File? imageFile}) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      _setLoading(true);
      Map<String, dynamic> updateData = {'displayName': name};

      if (imageFile != null) {
        // Tạo đường dẫn chuẩn: avatars/uid.jpg
        final String fileName = '$uid.jpg';
        final Reference ref = _storage.ref().child('avatars').child(fileName);

        debugPrint("--- Đang tải ảnh lên Storage...");

        // Upload và kèm theo metadata để Firebase nhận diện đúng file ảnh
        UploadTask uploadTask = ref.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Đợi upload hoàn tất 100%
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

        if (snapshot.state == TaskState.success) {
          String downloadUrl = await snapshot.ref.getDownloadURL();
          updateData['photoUrl'] = downloadUrl;
          _photoUrl = downloadUrl;
        }
      }

      // Lưu thông tin vào Firestore
      await _firestore.collection('users').doc(uid).update(updateData);
      _displayName = name;

      notifyListeners();
      debugPrint("✅ Cập nhật hồ sơ thành công.");
    } catch (e) {
      debugPrint("❌ Lỗi cập nhật hồ sơ: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- 3. ĐĂNG XUẤT ---
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully!'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      debugPrint("❌ Lỗi đăng xuất: $e");
    }
  }

  // --- 4. CẬP NHẬT DARK MODE / THÔNG BÁO ---
  Future<void> updateToggleSetting({
    required String field,
    required bool value,
  }) async {
    try {
      if (field == 'isDarkMode') {
        _isDarkModeOn = value;
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', value);
      } else {
        _isExpiryAlertOn = value;
        notifyListeners();
        String? uid = _auth.currentUser?.uid;
        if (uid != null) {
          await _firestore.collection('users').doc(uid).set({
            field: value,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi gạt nút: $e");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
