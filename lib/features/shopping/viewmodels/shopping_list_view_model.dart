import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/shopping_item_model.dart';
import '../../../core/constants/app_enums.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _itemsSubscription;

  List<ShoppingItemModel> _items = [];
  List<ShoppingItemModel> get items => _items;

  ShoppingListViewModel() {
    _listenToItems();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference? get _itemsRef {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('shopping_list');
  }

  CollectionReference? get _historyRef {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('shopping');
  }

  void _listenToItems() {
    if (_uid == null) return;

    _itemsSubscription?.cancel();
    _itemsSubscription = _itemsRef
        ?.orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _items = snapshot.docs.map((doc) {
        return ShoppingItemModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addItem(
      String name,
      double quantity,
      MeasureUnit unit,
      {String category = 'Shopping List'}
      ) async {
    if (_itemsRef == null) return;

    final doc = _itemsRef!.doc();
    final newItem = ShoppingItemModel(
      id: doc.id,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      updatedAt: DateTime.now(),
      isBought: false,
    );

    await doc.set(newItem.toJson());
  }

  Future<void> toggleBoughtStatus(String itemId, bool currentStatus) async {
    if (_itemsRef == null) return;
    await _itemsRef!.doc(itemId).update({
      'isBought': !currentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  Future<void> completeShoppingAndSaveHistory() async {
    if (_uid == null || _items.isEmpty || _itemsRef == null || _historyRef == null) return;

    final boughtItems = _items.where((item) => item.isBought).toList();
    if (boughtItems.isEmpty) return;

    final batch = _firestore.batch();
    final newHistoryDoc = _historyRef!.doc();


    batch.set(newHistoryDoc, {
      'completedAt': FieldValue.serverTimestamp(),
      'items': boughtItems.map((e) => e.toJson()).toList(),
      'totalItems': boughtItems.length,
    });

    for (var item in boughtItems) {
      batch.delete(_itemsRef!.doc(item.id));
    }

    await batch.commit();
  }
  Stream<QuerySnapshot> get shoppingHistoryStream {
    if (_uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('shopping')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }
  Future<void> clearList() async {
    if (_itemsRef == null) return;
    final snapshots = await _itemsRef!.get();

    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }
}