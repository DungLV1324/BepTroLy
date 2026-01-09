import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../goi_y_mon_an/views/recipe_detail_screen.dart';
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
      create: (_) => MealPlannerViewModel(),
      child: const AddMealPlanScreenContent(),
    );
  }
}

class AddMealPlanScreenContent extends StatefulWidget {
  const AddMealPlanScreenContent({super.key});

  @override
  State<AddMealPlanScreenContent> createState() =>
      _AddMealPlanScreenContentState();
}

class _AddMealPlanScreenContentState extends State<AddMealPlanScreenContent> {
  bool _isReminderOn = true;

  String _formatDate(DateTime date) {
    const dayOfWeekMap = {
      1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
      4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
    };
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final dayOfWeek = dayOfWeekMap[date.weekday] ?? '';

    return '$dayOfWeek, $day/$month/$year';
  }

  Widget _buildSafeImage(String path, {double size = 70}) {
    final cleanPath = path.replaceAll(r'\', '/').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: cleanPath.startsWith('http')
          ? Image.network(
              cleanPath,
              width: size, height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size, height: size, color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            )
          : Image.asset(
              cleanPath,
              width: size, height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: size, height: size, color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
    );
  }

  void _showMealSelectionDialog(BuildContext context, MealPlannerViewModel viewModel) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a Meal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Thanh tìm kiếm
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search online (Spoonacular)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          viewModel.searchMeals('');
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (value) async {
                      await viewModel.searchMeals(value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: viewModel,
                      builder: (context, _) {
                        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());

                        final list = viewModel.availableMeals;
                        if (list.isEmpty) return const Center(child: Text("No meals found."));

                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final meal = list[index];
                            return ListTile(
                              leading: _buildSafeImage(meal.imageUrl, size: 50),
                              title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${meal.preparationTimeMinutes} min • ${meal.kcal} kcal'),
                              onTap: () {
                                viewModel.selectMeal(meal);
                                Navigator.pop(modalContext);
                              },
                            );
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
      },
    );
  }

  void _navigateToRecipeDetail(BuildContext context, MealPlannerViewModel viewModel) {
    if (viewModel.selectedMeals.isEmpty) return;

    if (viewModel.selectedMeals.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(recipe: viewModel.selectedMeals.first.toRecipeModel()),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select a meal to view recipe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...viewModel.selectedMeals.map((meal) => ListTile(
                  leading: _buildSafeImage(meal.imageUrl, size: 40),
                  title: Text(meal.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: meal.toRecipeModel()),
                      ),
                    );
                  },
                )),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _handleSave(BuildContext context, MealPlannerViewModel viewModel) async {
    final success = await viewModel.saveMealPlan();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan saved successfully!'), backgroundColor: AppColors.primaryGreen),
        );
        GoRouter.of(context).pop();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(viewModel.errorMessage ?? "An unknown error occurred."),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<MealPlannerViewModel>(
      builder: (context, viewModel, child) {
        final hasMeals = viewModel.selectedMeals.isNotEmpty;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
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
                    ...viewModel.selectedMeals.map(
                      (meal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildMealInfo(context, viewModel, meal),
                      ),
                    ),
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
              if (viewModel.isLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(context, viewModel, hasMeals),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MealPlannerViewModel viewModel, bool hasMeals) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.darkText),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      centerTitle: true,
      title: Text('Add Plan', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700)),
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
                  child: Text('Save', style: TextStyle(color: hasMeals ? AppColors.white : AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: isDark ? Colors.grey[800]! : AppColors.greyDivider, height: 1),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, MealPlannerViewModel viewModel, bool hasMeals) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.background,
        border: Border(top: BorderSide(width: 1, color: isDark ? Colors.grey[800]! : AppColors.greyDivider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: hasMeals ? () => _navigateToRecipeDetail(context, viewModel) : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                side: BorderSide(color: hasMeals ? AppColors.primaryGreen : AppColors.greyDivider, width: 1),
              ),
              child: Text('View Recipe', style: TextStyle(color: hasMeals ? AppColors.primaryGreen : AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w700)),
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
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
        TextSpan(text: 'Selected Meals ', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        TextSpan(text: '* ', style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w600))
      ]),
    );
  }

  Widget _buildAddMealButton(BuildContext context, MealPlannerViewModel viewModel, {bool isMore = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => _showMealSelectionDialog(context, viewModel),
        icon: const Icon(Icons.add, color: AppColors.white, size: 20),
        label: Text(isMore ? 'Add More Meal' : 'Add Meal', style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context, MealPlannerViewModel viewModel, dynamic meal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _buildBoxDecoration(context),
      child: Row(
        children: [
          _buildSafeImage(meal.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${meal.preparationTimeMinutes} min • ${meal.kcal} kcal', style: const TextStyle(color: AppColors.greyText, fontSize: 14)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildPlanDetailRow(
      context: context,
      icon: Icons.calendar_today,
      title: Text.rich(TextSpan(children: [
        TextSpan(text: 'Cooking Date ', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
        TextSpan(text: '* ', style: TextStyle(color: AppColors.primaryRed, fontSize: 16, fontWeight: FontWeight.w500))
      ])),
      value: Text(_formatDate(viewModel.plan.date), style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
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
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
      }
  }

  Widget _buildMealTypeSegmentedControl(BuildContext context, MealPlannerViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
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
          child: Text(text, style: TextStyle(color: isSelected ? AppColors.yellow : AppColors.greyText, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildSpecificTimeRow(BuildContext context, MealPlannerViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildPlanDetailRow(
      context: context,
      icon: Icons.access_time_filled,
      title: Text('Specific Time', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Text(viewModel.plan.specificTime.format(context), style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(context: context, initialTime: viewModel.plan.specificTime);
        if (picked != null) viewModel.setSpecificTime(picked);
      },
    );
  }

  Widget _buildServingSizeSection(BuildContext context, MealPlannerViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servings', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildBoxDecoration(context),
          child: Column(
            children: [
              Row(
                children: [
                  _buildIconBox(context, Icons.people),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Number of servings', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))),
                  _buildQuantityControl(context, viewModel.plan.servings, (delta) => viewModel.changeServings(delta)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Adjust servings based on your needs', style: TextStyle(color: AppColors.greyText, fontSize: 12)),
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
          decoration: _buildBoxDecoration(context),
          child: TextFormField(
            initialValue: viewModel.plan.notes,
            onChanged: (value) => viewModel.updateNotes(value),
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'e.g. For guests, make more...', hintStyle: TextStyle(color: Color(0xFF6B7280)), border: InputBorder.none, contentPadding: EdgeInsets.all(4)),
            style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatSection(BuildContext context, MealPlannerViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDaysSummary = viewModel.plan.repeatDays.entries.where((e) => e.value).map((e) => e.key).join(', ');
    return _buildPlanDetailRow(
      context: context,
      icon: Icons.repeat,
      title: Text('Repeat this plan', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500)),
      value: Expanded(child: Text(selectedDaysSummary.isEmpty ? 'None' : selectedDaysSummary, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(color: selectedDaysSummary.isEmpty ? AppColors.greyText : AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w500))),
      onTap: () => _showRepeatDialog(context, viewModel),
    );
  }

  BoxDecoration _buildBoxDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isDark ? Colors.grey[800]! : AppColors.greyDivider, width: 1),
      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
    );
  }

  Widget _buildPlanDetailRow({required BuildContext context, required IconData icon, required Widget title, required Widget value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _buildBoxDecoration(context),
        child: Row(children: [_buildIconBox(context, icon), const SizedBox(width: 16), Expanded(child: title), value]),
      ),
    );
  }

  Widget _buildIconBox(BuildContext context, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: isDark ? Colors.green.withValues(alpha: 0.15) : AppColors.lightGreen, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.primaryGreen, size: 24),
    );
  }

  Widget _buildQuantityControl(BuildContext context, int quantity, Function(int) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircularButton(Icons.remove, isDark ? Colors.grey[800]! : AppColors.greyBackground, isDark ? Colors.white : AppColors.darkText, () => onChanged(-1)),
        SizedBox(width: 32, child: Text('$quantity', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 18, fontWeight: FontWeight.w700))),
        _buildCircularButton(Icons.add, AppColors.primaryGreen, AppColors.white, () => onChanged(1)),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onPressed) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9999)),
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, size: 16, color: iconColor), onPressed: onPressed),
    );
  }

  Widget _buildReminderSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reminder', style: TextStyle(color: AppColors.greyText, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _buildBoxDecoration(context),
          child: Column(children: [
            Row(children: [
              _buildIconBox(context, Icons.notifications_active),
              const SizedBox(width: 16),
              Expanded(child: Text('Set Reminder', style: TextStyle(color: isDark ? Colors.white : AppColors.darkText, fontSize: 16, fontWeight: FontWeight.w500))),
              Switch(value: _isReminderOn, onChanged: (val) => setState(() => _isReminderOn = val), activeColor: AppColors.primaryGreen)
            ]),
            const Padding(padding: EdgeInsets.only(top: 12.0), child: Divider(color: AppColors.greyDivider, height: 1)),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text('Remind me before', style: TextStyle(color: AppColors.greyText, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('1 hour', style: TextStyle(color: AppColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.w600))
              ])
            )
          ]),
        ),
      ],
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
                        setState(() { viewModel.toggleRepeatDay(dayKey); });
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
