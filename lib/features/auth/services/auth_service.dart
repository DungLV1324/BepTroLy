import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart' as app_model;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _userCollection = 'users';

  app_model.UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return _mapFirebaseUser(firebaseUser);
  }

  Stream<app_model.UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  /// ĐĂNG KÝ TÀI KHOẢN
  Future<app_model.UserModel?> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // 1. Cập nhật Display Name lên Firebase Auth Profile
        await credential.user!.updateDisplayName(name);

        // 2. Reload để đồng bộ dữ liệu local của Auth
        await credential.user!.reload();

        // 3. Lưu vào Firestore (Truyền name trực tiếp để đảm bảo không bị null)
        await _saveUserToFirestore(credential.user!, manualName: name);

        // Lấy user đã được cập nhật sau khi reload
        final updatedUser = _firebaseAuth.currentUser;
        return _mapFirebaseUser(updatedUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định trong quá trình đăng ký.';
    }
  }

  /// ĐĂNG NHẬP EMAIL/PASSWORD
  Future<app_model.UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password
      );
      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
      }
      return _mapFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  /// ĐĂNG NHẬP GOOGLE
  Future<app_model.UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _saveUserToFirestore(firebaseUser);
        return _mapFirebaseUser(firebaseUser);
      }
      return null;

    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw 'Lỗi kết nối với Google.';
    }
  }

  /// LƯU THÔNG TIN USER VÀO FIRESTORE
  /// [manualName] dùng để ưu tiên lưu tên khi đăng ký mới
  Future<void> _saveUserToFirestore(User firebaseUser, {String? manualName}) async {
    final userDocRef = _firestore.collection(_userCollection).doc(firebaseUser.uid);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      await userDocRef.set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': manualName ?? firebaseUser.displayName ?? 'My friends',
        'photoUrl': firebaseUser.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      Map<String, dynamic> updateData = {
        'lastLogin': FieldValue.serverTimestamp(),
      };
      if (manualName != null) updateData['displayName'] = manualName;

      await userDocRef.update(updateData);
    }
  }

  /// CẬP NHẬT PROFILE (Tên, Ảnh)
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        if (name != null) await firebaseUser.updateDisplayName(name);
        if (photoUrl != null) await firebaseUser.updatePhotoURL(photoUrl);

        await _firestore.collection(_userCollection).doc(firebaseUser.uid).update({
          if (name != null) 'displayName': name,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });

        await firebaseUser.reload();
      }
    } catch (e) {
      throw 'Không thể cập nhật thông tin profile.';
    }
  }

  /// ĐĂNG XUẤT
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Lỗi khi đăng xuất.';
    }
  }

  app_model.UserModel? _mapFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    return app_model.UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'My friends',
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'The login information is incorrect or has expired.';
      case 'user-not-found':
        return 'The account is not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'network-request-failed':
        return 'Network connection error.';
      case 'user-disabled':
        return 'This account is locked.';
      case 'invalid-email':
        return 'Invalid email.';
      case 'operation-not-allowed':
        return 'This login method is not allowed.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      default:
        return 'System error: ${e.message}';
    }
  }
}