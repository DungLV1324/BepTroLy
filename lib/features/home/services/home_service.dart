import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../../kho_nguyen_lieu/services/pantry_service.dart';

class HomeService {
  final PantryService _pantryService = PantryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Stream trả về danh sách ĐÃ LỌC & SẮP XẾP sẵn
  Stream<List<IngredientModel>> getExpiringIngredientsStream() {
    return _pantryService.getIngredientsStream().map((allIngredients) {
      // Logic xử lý dữ liệu nằm ở Service (Clean Code)

      // Bước 1: Sắp xếp theo hạn sử dụng (gần nhất lên đầu)
      allIngredients.sort((a, b) {
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      // Bước 2: Chỉ lấy 10 món đầu tiên để hiện ở Home
      return allIngredients.take(10).toList();
    });
  }

  // 2. Hàm lấy thông tin User (Tên & Ảnh)
  Future<Map<String, String?>> getUserProfile() async {
    User? user = _auth.currentUser;
    String name = 'My friend';
    String? photoUrl;

    if (user != null) {
      // Ưu tiên lấy từ Auth
      name = user.displayName ?? 'My friend';
      photoUrl = user.photoURL;

      // Nếu Auth chưa có tên, tìm trong Firestore
      if (name == 'My friend') {
        try {
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            name = data['fullName'] ?? data['name'] ?? 'My friend';
            if (data.containsKey('avatarUrl')) {
              photoUrl = data['avatarUrl'];
            }
          }
        } catch (e) {
          print("Lỗi HomeService (User): $e");
        }
      }
    }
    return {'name': name, 'photoUrl': photoUrl};
  }
}