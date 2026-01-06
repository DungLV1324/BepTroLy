import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient_model.dart';

class PantryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _pantryRef {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Người dùng chưa đăng nhập! Không thể truy cập Pantry.");
    }

    return _db.collection('users').doc(user.uid).collection('pantry_items');
  }

  // 1. Lấy luồng dữ liệu và chuyển đổi sang IngredientModel
  Stream<List<IngredientModel>> getIngredientsStream() {
    return _pantryRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Lấy data và gán ID thực từ Firestore vào Model
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return IngredientModel.fromJson(data);
      }).toList();
    });
  }

  // 2. Thêm món mới
  Future<void> addIngredient(IngredientModel item) async {
    // Dùng toJson() có sẵn trong model của bạn
    // Lưu ý: Remove 'id' vì Firestore sẽ tự sinh ID mới hoặc dùng .doc().set()
    final data = item.toJson();
    data.remove('id');

    await _pantryRef.add(data);
  }

  // 3. Xóa món
  Future<void> deleteIngredient(String id) async {
    await _pantryRef.doc(id).delete();
  }

  Future<void> updateIngredient(IngredientModel item) async {
    // item.id bắt buộc phải có để biết sửa document nào
    await _pantryRef.doc(item.id).update(item.toJson());
  }
}