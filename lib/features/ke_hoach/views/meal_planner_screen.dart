import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/meal_planner_view_model.dart';
import '../../../../core/constants/app_enums.dart';

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

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Khởi tạo ViewModel mới cho màn hình thêm kế hoạch
      create: (_) => MealPlannerViewModel(),
      child: const AddMealPlanScreenContent(),
    );
  }
}

class AddMealPlanScreenContent extends StatefulWidget {
  const AddMealPlanScreenContent({super.key});

  @override
  State<AddMealPlanScreenContent> createState() => _AddMealPlanScreenContentState();
}

class _AddMealPlanScreenContentState extends State<AddMealPlanScreenContent> {
  bool _isReminderOn = true;

  String _formatDate(DateTime date) {
    const dayOfWeekMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final dayOfWeek = dayOfWeekMap[date.weekday] ?? '';

    return '$dayOfWeek, $day/$month/$year';
  }

  Future<void> _handleSave(BuildContext context, MealPlannerViewModel viewModel) async {
    final success = await viewModel.saveMealPlan();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan saved successfully to your collection!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        GoRouter.of(context).pop();
      } else {
        final error = viewModel.errorMessage;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(error ?? "An unknown error occurred."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlannerViewModel>(
      builder: (context, viewModel, child) {
        final plan = viewModel.plan;
        final hasMeals = viewModel.selectedMeals.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, viewModel, hasMeals),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  if (hasMeals) ...[
                    const SizedBox(height: 16),
                    _buildMealLabel(),
                    const SizedBox(height: 8),
                    // Danh sách các món ăn đã chọn từ Firebase
                    ...viewModel.selectedMeals.map((meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildMealInfo(context, viewModel, meal),
                        )),
                  ],
                  const SizedBox(height: 16),
                  _buildAddMealButton(context, viewModel, isMore: hasMeals),



                  const SizedBox(height: 24),
                  _buildTimeSection(context, viewModel),
                  const SizedBox(height: 24),
                  _buildServingSizeSection(context, viewModel),
                  const SizedBox(height: 24),
                  _buildReminderSection(),
                  const SizedBox(height: 24),
                  _buildNoteSection(viewModel),
                  const SizedBox(height: 24),
                  _buildRepeatSection(context, viewModel),
                  const SizedBox(height: 120),
                ],
              ),
              // Lớp phủ khi đang xử lý lưu lên Firestore
              if (viewModel.isLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(context, viewModel, hasMeals),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MealPlannerViewModel viewModel, bool hasMeals) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      centerTitle: true,
      title: const Text('Add Plan',
          style: TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: viewModel.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : ElevatedButton(
                  onPressed: hasMeals ? () => _handleSave(context, viewModel) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasMeals ? AppColors.primaryGreen : AppColors.greyBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    minimumSize: Size.zero,
                  ),
                  child: Text('Save',
                      style: TextStyle(
                          color: hasMeals ? AppColors.white : AppColors.greyText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
        ),
      ],
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.greyDivider, height: 1.0)),
    );
  }

  Widget _buildBottomActions(BuildContext context, MealPlannerViewModel viewModel, bool hasMeals) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(width: 1, color: AppColors.greyDivider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: hasMeals ? () {} : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                side: BorderSide(color: hasMeals ? AppColors.primaryGreen : AppColors.greyDivider, width: 1),
              ),
              child: Text('View Recipe',
                  style: TextStyle(
                      color: hasMeals ? AppColors.primaryGreen : AppColors.greyText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: hasMeals && !viewModel.isLoading ? () => _handleSave(context, viewModel) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasMeals ? AppColors.primaryGreen : AppColors.greyBackground,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                elevation: hasMeals ? 4 : 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Plan', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealLabel() {
    return const Text.rich(
      TextSpan(children: [
        TextSpan(
            text: 'Selected Meals ',
            style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        TextSpan(
            text: '* ',
            style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w600))
      ]),
    );
  }

  Widget _buildAddMealButton(BuildContext context, MealPlannerViewModel viewModel, {bool isMore = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => _showMealSelectionDialog(context, viewModel),
        icon: const Icon(Icons.add, color: AppColors.white, size: 20),
        label: Text(isMore ? 'Add More Meal' : 'Add Meal',
            style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context, MealPlannerViewModel viewModel, dynamic meal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _buildBoxDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: meal.imageUrl.startsWith('http')
                ? Image.network(meal.imageUrl,
                    width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                : Image.asset(meal.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${meal.preparationTimeMinutes} min • ${meal.kcal} kcal',
                    style: const TextStyle(color: AppColors.greyText, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
            onPressed: () => viewModel.removeMeal(meal),
          ),
        ],
      ),
    );
  }



  Widget _buildTimeSection(BuildContext context, MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
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
      title: const Text.rich(TextSpan(children: [
        TextSpan(
            text: 'Cooking Date ',
            style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
        TextSpan(
            text: '* ',
            style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w500))
      ])),
      value: Text(_formatDate(viewModel.plan.date),
          style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: viewModel.plan.date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) viewModel.selectDate(picked);
      },
    );
  }

  String _getMealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      default:
        return '';
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
          child: Text(text,
              style: TextStyle(
                  color: isSelected ? AppColors.yellow : AppColors.greyText, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildSpecificTimeRow(BuildContext context, MealPlannerViewModel viewModel) {
    return _buildPlanDetailRow(
      icon: Icons.access_time_filled,
      title: const Text('Specific Time', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Text(viewModel.plan.specificTime.format(context),
          style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(context: context, initialTime: viewModel.plan.specificTime);
        if (picked != null) viewModel.setSpecificTime(picked);
      },
    );
  }

  Widget _buildServingSizeSection(BuildContext context, MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servings', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  const Expanded(
                      child: Text('Number of servings',
                          style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))),
                  _buildQuantityControl(viewModel.plan.servings, (delta) => viewModel.changeServings(delta)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Original recipe: ${viewModel.originalServings} servings',
                  style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection(MealPlannerViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _buildBoxDecoration(),
          child: TextFormField(
            initialValue: viewModel.plan.notes,
            onChanged: (value) => viewModel.updateNotes(value),
            maxLines: 4,
            decoration: const InputDecoration(
                hintText: 'e.g. For guests, make more...',
                hintStyle: TextStyle(color: Color(0xFF6B7280)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(4)),
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatSection(BuildContext context, MealPlannerViewModel viewModel) {
    final selectedDaysSummary = viewModel.plan.repeatDays.entries.where((e) => e.value).map((e) => e.key).join(', ');
    return _buildPlanDetailRow(
      icon: Icons.repeat,
      title: const Text('Repeat this plan', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Expanded(
          child: Text(selectedDaysSummary.isEmpty ? 'None' : selectedDaysSummary,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: selectedDaysSummary.isEmpty ? AppColors.greyText : AppColors.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500))),
      onTap: () => _showRepeatDialog(context, viewModel),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyDivider, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))]);
  }

  Widget _buildPlanDetailRow({required IconData icon, required Widget title, required Widget value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _buildBoxDecoration(),
        child: Row(children: [_buildIconBox(icon), const SizedBox(width: 16), Expanded(child: title), value]),
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: AppColors.primaryGreen, size: 24));
  }

  Widget _buildQuantityControl(int quantity, Function(int) onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _buildCircularButton(Icons.remove, AppColors.greyBackground, AppColors.darkText, () => onChanged(-1)),
      SizedBox(
          width: 32,
          child: Text('$quantity',
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700))),
      _buildCircularButton(Icons.add, AppColors.primaryGreen, AppColors.white, () => onChanged(1))
    ]);
  }

  Widget _buildCircularButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onPressed) {
    return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9999)),
        child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, size: 16, color: iconColor), onPressed: onPressed));
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reminder', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildBoxDecoration(),
          child: Column(children: [
            Row(children: [
              _buildIconBox(Icons.notifications_active),
              const SizedBox(width: 16),
              const Expanded(
                  child: Text('Set Reminder', style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))),
              Switch(value: _isReminderOn, onChanged: (val) => setState(() => _isReminderOn = val), activeColor: AppColors.primaryGreen)
            ]),
            const Padding(padding: EdgeInsets.only(top: 12.0), child: Divider(color: AppColors.greyDivider, height: 1)),
            Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                  Text('Remind me before', style: TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('1 hour', style: TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600))
                ]))
          ]),
        ),
      ],
    );
  }

  void _showMealSelectionDialog(BuildContext context, MealPlannerViewModel viewModel) {
    viewModel.fetchRecipesFromFirebase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16),
            child: Consumer<MealPlannerViewModel>(
              builder: (context, vm, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a Meal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.errorMessage != null
                              ? Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.primaryRed)))
                              : vm.availableMeals.isEmpty
                                  ? const Center(child: Text("No meals found in database."))
                                  : ListView.builder(
                                      itemCount: vm.availableMeals.length,
                                      itemBuilder: (context, index) {
                                        final meal = vm.availableMeals[index];
                                        return ListTile(
                                          leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: meal.imageUrl.startsWith('http')
                                                  ? Image.network(meal.imageUrl,
                                                      width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                                                  : Image.asset(meal.imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                                          title: Text(meal.name),
                                          subtitle: Text('${meal.preparationTimeMinutes} min • ${meal.kcal} kcal'),
                                          onTap: () {
                                            vm.selectMeal(meal);
                                            Navigator.pop(modalContext);
                                          },
                                        );
                                      },
                                    ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRepeatDialog(BuildContext context, MealPlannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Weekly Repeat'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final dayMap = {'T2': 'Mon', 'T3': 'Tue', 'T4': 'Wed', 'T5': 'Thu', 'T6': 'Fri', 'T7': 'Sat', 'CN': 'Sun'};
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: viewModel.plan.repeatDays.keys.map((dayKey) {
                  return CheckboxListTile(
                    title: Text(dayMap[dayKey] ?? dayKey),
                    value: viewModel.plan.repeatDays[dayKey] ?? false,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        setState(() {
                           viewModel.toggleRepeatDay(dayKey);
                        });
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done'))],
        );
      },
    ).then((_) => setState(() {}));
  }
}
