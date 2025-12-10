import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/meal_planner_view_model.dart';import '../../../../core/constants/app_enums.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryOrange = Color(0xFFFB8C00);
  static const Color lightGreen = Color(0x194CAF50);
  static const Color lightOrange = Color(0x33FB8C00);
  static const Color lightYellow = Color(0x33FFC107);
  static const Color yellow = Color(0xFFFFC107);
  static const Color greyText = Color(0xFF6C757D);
  static const Color darkText = Color(0xFF212529);
  static const Color background = Color(0xFFF6F8F6);
  static const Color greyDivider = Color(0xFFE0E0E0);
  static const Color greyBackground = Color(0xFFE5E7EB);
  static const Color white = Colors.white;
}

// Class chứa Provider
class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealPlannerViewModel(),
      child: const AddMealPlanScreenContent(),
    );
  }
}

// Nội dung màn hình chính
class AddMealPlanScreenContent extends StatelessWidget {
  const AddMealPlanScreenContent({super.key});

  // Hàm định dạng ngày tháng thủ công
  String _formatDate(DateTime date) {
    const dayOfWeekMap = {
      1: 'Thứ Hai',
      2: 'Thứ Ba',
      3: 'Thứ Tư',
      4: 'Thứ Năm',
      5: 'Thứ Sáu',
      6: 'Thứ Bảy',
      7: 'Chủ Nhật',
    };
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final dayOfWeek = dayOfWeekMap[date.weekday] ?? '';

    return '$dayOfWeek, $day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlannerViewModel>(
      builder: (context, viewModel, child) {
        final plan = viewModel.plan;
        final isMealSelected = plan.selectedMeal != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, viewModel, isMealSelected),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              if (!isMealSelected) _buildAddMealButton(context, viewModel),
              if (isMealSelected) ...[
                _buildMealLabel(),
                const SizedBox(height: 8),
                _buildMealInfo(context, viewModel),
                if (plan.selectedMeal != null && plan.servings < viewModel.originalServings)
                  _buildMissingIngredientsBanner(),
              ],
              const SizedBox(height: 16),
              _buildTimeSection(context, viewModel),
              const SizedBox(height: 16),
              _buildServingSizeSection(context, viewModel),
              const SizedBox(height: 16),
              _buildIngredientsSection(),
              const SizedBox(height: 16),
              _buildReminderSection(),
              const SizedBox(height: 16),
              _buildNoteSection(viewModel),
              const SizedBox(height: 16),
              _buildRepeatSection(context, viewModel),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(context, viewModel, isMealSelected),
        );
      },
    );
  }

  // MARK: - App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context, MealPlannerViewModel viewModel, bool isMealSelected) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.darkText), onPressed: () => Navigator.pop(context)),
      centerTitle: true,
      title: const Text('Thêm kế hoạch', style: TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton(
            onPressed: isMealSelected ? () => viewModel.saveMealPlan() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isMealSelected ? AppColors.primaryGreen : AppColors.greyBackground,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              minimumSize: Size.zero,
            ),
            child: Text('Lưu', style: TextStyle(color: isMealSelected ? AppColors.white : AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: AppColors.greyDivider, height: 1.0)),
    );
  }

  // MARK: - Món ăn
  Widget _buildMealLabel() {
    return const Text.rich(
      TextSpan(children: [TextSpan(text: 'Món ăn ', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)), TextSpan(text: '* ', style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _buildAddMealButton(BuildContext context, MealPlannerViewModel viewModel) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () => _showMealSelectionDialog(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          minimumSize: Size.zero,
        ),
        child: const Text('Thêm món ăn', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context, MealPlannerViewModel viewModel) {
    final meal = viewModel.plan.selectedMeal;
    if (meal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _buildBoxDecoration(),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(meal.imageUrl, width: 80, height: 80, fit: BoxFit.cover)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.greyText),
                    const SizedBox(width: 4),
                    Text('${meal.preparationTimeMinutes} phút', style: const TextStyle(color: AppColors.greyText, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showMealSelectionDialog(context, viewModel),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(9999)),
              child: const Icon(Icons.edit, size: 20, color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Banner
  Widget _buildMissingIngredientsBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.lightOrange, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.primaryOrange, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text('Bạn thiếu 3 nguyên liệu. Thêm vào danh sách mua?', style: TextStyle(color: AppColors.primaryOrange, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // MARK: - Thời gian
  Widget _buildTimeSection(BuildContext context, MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thời gian', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildDateRow(context, viewModel),
        const SizedBox(height: 12),
        _buildMealTypeSegmentedControl(context, viewModel),
        const SizedBox(height: 12),
        _buildSpecificTimeRow(context, viewModel),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context, MealPlannerViewModel viewModel) {
    return _buildPlanDetailRow(
      icon: Icons.calendar_today,
      title: const Text.rich(TextSpan(children: [TextSpan(text: 'Ngày nấu ', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)), TextSpan(text: '*', style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w500))])),
      // Đã sửa: Sử dụng hàm định dạng thủ công
      value: Text(_formatDate(viewModel.plan.date), style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: viewModel.plan.date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          locale: const Locale('vi', 'VN'),
        );
        if (picked != null) {
          viewModel.selectDate(picked);
        }
      },
    );
  }

  String _getMealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast: return '🌅 Sáng';
      case MealType.lunch: return '☀️ Trưa';
      case MealType.dinner: return '🌙 Tối';
      case MealType.snack: return '☕ Ăn nhẹ';
      default: return '';
    }
  }

  Widget _buildMealTypeSegmentedControl(BuildContext context, MealPlannerViewModel viewModel) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: MealType.values.where((e) => e != MealType.snack).map((type) {
          return _buildMealTypeSegment(viewModel, type, _getMealTypeLabel(type));
        }).toList(),
      ),
    );
  }

  Widget _buildMealTypeSegment(MealPlannerViewModel viewModel, MealType type, String text) {
    final isSelected = viewModel.plan.mealType == type;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setMealTime(type),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.yellow : AppColors.greyText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificTimeRow(BuildContext context, MealPlannerViewModel viewModel) {
    return _buildPlanDetailRow(
      icon: Icons.access_time_filled,
      title: const Text('Giờ cụ thể', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Text(viewModel.plan.specificTime.format(context), style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: viewModel.plan.specificTime,
        );
        if (picked != null) {
          viewModel.setSpecificTime(picked);
        }
      },
    );
  }

  // MARK: - Số khẩu phần
  Widget _buildServingSizeSection(BuildContext context, MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Số người ăn', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildBoxDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIconBox(Icons.people),
                  const SizedBox(width: 16),
                  const Expanded(child: Text('Số khẩu phần', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))),
                  _buildQuantityControl(
                    viewModel.plan.servings,
                        (delta) => viewModel.changeServings(delta),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Công thức gốc: ${viewModel.originalServings} người', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Ghi chú
  Widget _buildNoteSection(MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ghi chú', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _buildBoxDecoration(),
          child: TextFormField(
            initialValue: viewModel.plan.notes,
            onChanged: (value) => viewModel.updateNotes(value),
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'VD: Mời khách, làm nhiều hơn...',
              hintStyle: TextStyle(color: Color(0xFF6B7280)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4),
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  // MARK: - Lặp lại kế hoạch này
  Widget _buildRepeatSection(BuildContext context, MealPlannerViewModel viewModel) {
    final selectedDaysSummary = viewModel.plan.repeatDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');

    return _buildPlanDetailRow(
      icon: Icons.repeat,
      title: const Text('Lặp lại kế hoạch này', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Expanded(
        child: Text(
          selectedDaysSummary.isEmpty ? 'Không' : selectedDaysSummary,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selectedDaysSummary.isEmpty ? AppColors.greyText : AppColors.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () => _showRepeatDialog(context, viewModel),
    );
  }

  // MARK: - Widget Chung
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.greyDivider, width: 1),
      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
    );
  }

  Widget _buildPlanDetailRow({required IconData icon, required Widget title, required Widget value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _buildBoxDecoration(),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: 16),
            Expanded(child: title),
            value,
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.primaryGreen, size: 24),
    );
  }

  Widget _buildQuantityControl(int quantity, Function(int) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircularButton(Icons.remove, AppColors.greyBackground, AppColors.darkText, () => onChanged(-1)),
        SizedBox(width: 32, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700))),
        _buildCircularButton(Icons.add, AppColors.primaryGreen, AppColors.white, () => onChanged(1)),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9999)),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, size: 16, color: iconColor), onPressed: onPressed),
    );
  }

  Widget _buildIngredientsSection() {
    return _buildPlanDetailRow(
      icon: Icons.sort,
      title: const Text('Nguyên liệu cần dùng', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.lightOrange, borderRadius: BorderRadius.circular(9999)), child: const Text('8/10 có sẵn', style: TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600))), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, color: AppColors.darkText, size: 24)]),
      onTap: () {},
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nhắc nhở', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildBoxDecoration(),
          child: Column(children: [Row(children: [_buildIconBox(Icons.notifications_active), const SizedBox(width: 16), const Expanded(child: Text('Nhắc nhở trước', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))), Switch(value: true, onChanged: (val) {}, activeColor: AppColors.primaryGreen)]), const Padding(padding: EdgeInsets.only(top: 12.0), child: Divider(color: AppColors.greyDivider, height: 1)), Padding(padding: const EdgeInsets.only(top: 12.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Nhắc trước bao lâu?', style: TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w500)), Text('1 giờ', style: TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600))]))]),
        ),
      ],
    );
  }


  Widget _buildBottomActions(BuildContext context, MealPlannerViewModel viewModel, bool isMealSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(width: 1, color: AppColors.greyDivider))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isMealSelected ? () {} : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                side: BorderSide(color: isMealSelected ? AppColors.primaryGreen : AppColors.greyDivider, width: 1),
              ),
              child: Text('Xem công thức', style: TextStyle(color: isMealSelected ? AppColors.primaryGreen : AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isMealSelected ? () => viewModel.saveMealPlan() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isMealSelected ? AppColors.primaryGreen : AppColors.greyBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                elevation: isMealSelected ? 4 : 0,
                shadowColor: AppColors.primaryGreen.withOpacity(0.3),
              ),
              child: Text('Lưu kế hoạch', style: TextStyle(color: isMealSelected ? AppColors.white : AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Dialogs

  void _showMealSelectionDialog(BuildContext context, MealPlannerViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn Món Ăn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.availableMeals.length,
                  itemBuilder: (context, index) {
                    final meal = viewModel.availableMeals[index];
                    return ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(meal.imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                      title: Text(meal.name),
                      subtitle: Text('${meal.preparationTimeMinutes} phút'),
                      onTap: () {
                        viewModel.selectMeal(meal);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRepeatDialog(BuildContext context, MealPlannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lặp lại hàng tuần'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: viewModel.plan.repeatDays.keys.map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: viewModel.plan.repeatDays[day],
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        viewModel.toggleRepeatDay(day);
                        setState(() {});
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Xong')),
          ],
        );
      },
    );
  }
}