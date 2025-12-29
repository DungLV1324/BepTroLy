import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart' as app_model;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ĐÃ ĐỒNG BỘ: Sử dụng 'USERS' viết hoa theo đúng ảnh database của bạn
  static const String _userCollection = 'USERS';

  app_model.UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return _mapFirebaseUser(firebaseUser);
  }

  Stream<app_model.UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  Future<app_model.UserModel?> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // Lưu vào Firestore ngay khi đăng ký thành công
        await _saveUserToFirestore(credential.user!);
        await credential.user!.reload();
        return _mapFirebaseUser(_firebaseAuth.currentUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<app_model.UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password
      );
      if (credential.user != null) {
        // Cập nhật thông tin đăng nhập vào Firestore
        await _saveUserToFirestore(credential.user!);
      }
      return _mapFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

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

  // ĐÃ SỬA: Hàm lưu sử dụng 'USERS' và xử lý Map lồng nhau Pantry/meal_plans
  Future<void> _saveUserToFirestore(User firebaseUser) async {
    try {
      final userDocRef = _firestore.collection(_userCollection).doc(firebaseUser.uid);
      final doc = await userDocRef.get();

      if (!doc.exists) {
        // Nếu là người dùng mới, khởi tạo cấu trúc Map như trong ảnh của bạn
        await userDocRef.set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'displayName': firebaseUser.displayName ?? 'Người dùng',
          'photoUrl': firebaseUser.photoURL ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'Pantry': {}, // Khởi tạo Map rỗng cho kho nguyên liệu
          'meal_plans': {}, // Khởi tạo Map rỗng cho kế hoạch bữa ăn
        });
      } else {
        // Nếu đã tồn tại, chỉ cập nhật thời gian đăng nhập để không ghi đè dữ liệu cũ
        await userDocRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Bắt lỗi Permission Denied nếu Security Rules chưa cho phép ghi vào 'USERS'
      print('Firestore Save Error: $e');
      throw 'Không có quyền cập nhật dữ liệu hệ thống.';
    }
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        if (name != null) await firebaseUser.updateDisplayName(name);
        if (photoUrl != null) await firebaseUser.updatePhotoURL(photoUrl);

        // Cập nhật cả trong Collection 'USERS'
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

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
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
      displayName: firebaseUser.displayName ?? 'Người dùng',
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Thông tin đăng nhập không chính xác hoặc đã hết hạn.'; // Sửa lỗi trong ảnh
      case 'user-not-found':
        return 'Tài khoản chưa được đăng ký.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng.';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }
}