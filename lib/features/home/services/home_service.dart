import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../../kho_nguyen_lieu/services/pantry_service.dart';

class HomeService {
  final PantryService _pantryService = PantryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Danh sách đã lọc & sắp xếp sẵn
  Stream<List<IngredientModel>> getExpiringIngredientsStream() {
    return _pantryService.getIngredientsStream().map((allIngredients) {
      allIngredients.sort((a, b) {
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      //Chỉ lấy 10 món đầu tiên để hiện ở Home
      return allIngredients.take(10).toList();
    });
  }

  //Hàm lấy thông tin User
  Future<Map<String, String?>> getUserProfile() async {
    User? user = _auth.currentUser;
    String name = 'My friend';
    String? photoUrl;

    if (user != null) {
      name = user.displayName ?? 'My friend';
      photoUrl = user.photoURL;

      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          name = data['displayName'] ?? 'My friend';
          if (data.containsKey('photoUrl') && data['photoUrl'] != "") {
            photoUrl = data['photoUrl'];
          }
        }
      } catch (e) {
        print("Lỗi HomeService (User): $e");
      }
    }
    return {'name': name, 'photoUrl': photoUrl};
  }
}
