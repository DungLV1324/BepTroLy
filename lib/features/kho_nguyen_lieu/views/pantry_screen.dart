import 'package:flutter/material.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final List<Map<String, dynamic>> _pantryData = [
    {
      "category": "Dairy & Eggs",
      "count": 3,
      "items": [
        {
          "name": "Eggs",
          "quantity": "6 count",
          "daysLeft": -1,
          "icon": Icons.egg_alt,
          "color": const Color(0xFFFF4D4D),
          "status": "Expired yesterday"
        },
        {
          "name": "Milk",
          "quantity": "1 Litre",
          "daysLeft": 2,
          "icon": Icons.local_drink,
          "color": const Color(0xFFFFC107),
          "status": "Expires in 2 days"
        },
        {
          "name": "Cheddar Cheese",
          "quantity": "200g",
          "daysLeft": 14,
          "icon": Icons.circle,
          "color": const Color(0xFF4CAF50),
          "status": "Expires in 14 days"
        },
      ]
    },
    {
      "category": "Vegetables",
      "count": 2,
      "items": [
        {
          "name": "Broccoli",
          "quantity": "1 head",
          "daysLeft": 5,
          "icon": Icons.grass,
          "color": const Color(0xFF4CAF50),
          "status": "Expires in 5 days"
        },
        {
          "name": "Carrots",
          "quantity": "500g",
          "daysLeft": 3,
          "icon": Icons.eco,
          "color": const Color(0xFFFFC107),
          "status": "Expires in 3 days"
        },
      ]
    },
    {
      "category": "Meats",
      "count": 0,
      "items": []
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: const [
            Icon(Icons.kitchen, color: Color(0xFF1A1D26)),
            SizedBox(width: 8),
            Text(
              'My Pantry',
              style: TextStyle(
                color: Color(0xFF1A1D26),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Mở màn hình thêm nguyên liệu hoặc Quét mã vạch
        },
        backgroundColor: const Color(0xFF2BEE79),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ingredients...',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9FA2B4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ..._pantryData.map((category) {
              return _buildCategorySection(category);
            }).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> data) {
    final List<dynamic> items = data['items'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(
                data['category'],
                style: const TextStyle(
                  color: Color(0xFF1A1D26),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data['count'].toString(),
                  style: const TextStyle(
                    color: Color(0xFF9FA2B4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: items.map<Widget>((item) => _buildPantryItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildPantryItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: item['color'],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item['icon'],
                color: item['color'],
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            // Thông tin tên và số lượng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      color: Color(0xFF1A1D26),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['quantity'],
                    style: const TextStyle(
                      color: Color(0xFF9FA2B4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              item['status'],
              style: TextStyle(
                color: item['color'] == const Color(0xFF9FA2B4)
                    ? const Color(0xFF9FA2B4)
                    : item['color'],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}