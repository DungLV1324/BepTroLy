// Loại bữa ăn (Dùng cho FR2.3 - Bộ lọc & FR4.1 - Lịch)
enum MealType { breakfast, lunch, dinner, snack }

// Đơn vị đo lường (Chuẩn hóa để tính toán FR1.3 - Quản lý số lượng)
enum MeasureUnit {
  g, kg, ml, l, spoon, cup, piece, unknown
}

// Trạng thái nguyên liệu (Dùng cho logic hiển thị màu sắc FR3)
enum ExpiryStatus {
  fresh,        // Còn tốt
  expiringSoon, // Sắp hết hạn (<= 2 ngày)
  expired       // Đã hết hạn
}