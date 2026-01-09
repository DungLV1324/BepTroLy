import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_view_model.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.read<HomeViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,

        onChanged: (val) {
          setState(() {});
          viewModel.onSearchQueryChanged(val);
        },
        onSubmitted: (val) => viewModel.performSearch(val),

        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Find food...',
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          // Nút Clear
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              viewModel.clearSearch();
              setState(() {});
            },
          )
              : null,
        ),
      ),
    );
  }
}

Widget buildSearchResults(HomeViewModel viewModel) {
  if (viewModel.isLoadingSearch) {
    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
  }

  if (viewModel.searchResults.isEmpty) {
    return const Center(child: Text("No recipes found.", style: TextStyle(color: Colors.grey)));
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: viewModel.searchResults.length,
    itemBuilder: (context, index) {
      final recipe = viewModel.searchResults[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Image.network(recipe.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          title: Text(recipe.name),
          onTap: () => context.push('/recipe_detail',extra : recipe),
        ),
      );
    },
  );
}