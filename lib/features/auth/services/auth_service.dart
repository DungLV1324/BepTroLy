import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart' as app_model; // Alias để tránh trùng tên User của Firebase

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Lấy user hiện tại
  app_model.UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  // Stream lắng nghe trạng thái đăng nhập (Dùng để auto-login)
  Stream<app_model.UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  // Đăng ký Email/Password
  Future<app_model.UserModel?> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật tên hiển thị ngay sau khi tạo
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload(); // Reload để lấy thông tin mới
        return _mapFirebaseUser(_firebaseAuth.currentUser); // Lấy user đã update
      }
      return null;
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Đăng nhập Email/Password
  Future<app_model.UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // --- Helper Methods ---

  // Chuyển đổi từ Firebase User -> App User Model
  app_model.UserModel? _mapFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    return app_model.UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'Người dùng',
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Xử lý lỗi Firebase trả về thông báo tiếng Việt dễ hiểu
  String _handleFirebaseAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản này.';
        case 'wrong-password':
          return 'Sai mật khẩu.';
        case 'email-already-in-use':
          return 'Email này đã được đăng ký.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'weak-password':
          return 'Mật khẩu quá yếu (cần > 6 ký tự).';
        default:
          return 'Lỗi đăng nhập: ${e.message}';
      }
    }
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }
}