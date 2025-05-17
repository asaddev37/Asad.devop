import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

Widget buildButton({
  required String label,
  required VoidCallback onTap,
  required bool isDarkMode,
  required ThemeProvider themeProvider,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  TextStyle textStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Comic Sans MS',
  ),
}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.transparent,
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.purpleAccent, Colors.cyanAccent]
              : [Colors.orangeAccent, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: padding,
      child: Text(
        label,
        style: textStyle,
      ),
    ),
  ).animate().scale(
    begin: const Offset(0.8, 0.8),
    end: const Offset(1.0, 1.0),
    duration: 600.ms,
    curve: Curves.bounceOut,
  );
}

Widget buildRefreshButton({
  required VoidCallback onTap,
  required bool isDarkMode,
  required ThemeProvider themeProvider,
  required AnimationController animationController,
}) {
  return RotationTransition(
    turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: animationController.isAnimating ? 0.8 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                    : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.refresh,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ).animate().scale(
    begin: const Offset(0.8, 0.8),
    end: const Offset(1.0, 1.0),
    duration: 400.ms,
    curve: Curves.bounceOut,
  );
}

Widget buildHintButton({
  required VoidCallback onTap,
  required bool isDarkMode,
  required ThemeProvider themeProvider,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDarkMode
              ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
              : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: const Icon(
        Icons.lightbulb_outline,
        size: 32,
        color: Colors.white,
      ),
    ),
  ).animate().scale(
    begin: const Offset(0.8, 0.8),
    end: const Offset(1.0, 1.0),
    duration: 400.ms,
    curve: Curves.bounceOut,
  );
}

Widget buildTableSelector({
  required bool isDarkMode,
  required ThemeProvider themeProvider,
  required List<int> selectedTables,
  required Function(int) onToggleTable,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Choose Your Tables",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: List.generate(20, (index) {
            final table = index + 1;
            final isSelected = selectedTables.contains(table);
            return GestureDetector(
              onTap: () => onToggleTable(table),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? isDarkMode
                        ? [Colors.green.shade700, Colors.green.shade900]
                        : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor]
                        : isDarkMode
                        ? [Colors.grey.shade700, Colors.grey.shade900]
                        : [Colors.grey.shade200, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? (isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51))
                          : Colors.transparent,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$table',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Text('🌟', style: TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ),
              ).animate().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.bounceOut,
              ),
            );
          }),
        ),
      ),
    ],
  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5, end: 0.0);
}

Widget buildCustomInput({
  required String title,
  required int value,
  required List<int> options,
  required TextEditingController controller,
  required VoidCallback onAdd,
  required Function(int?) onChanged,
  required bool isDarkMode,
  required ThemeProvider themeProvider,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<int>(
                value: value,
                items: options.map((option) {
                  return DropdownMenuItem<int>(
                    value: option,
                    child: Text(
                      '$option',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'Comic Sans MS',
                ),
                decoration: InputDecoration(
                  hintText: 'Custom',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                    fontFamily: 'Comic Sans MS',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.greenAccent, Colors.yellowAccent]
                        : [Colors.green.shade300, Colors.yellow.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5, end: 0.0);
}

Widget buildDropdown({
  required String title,
  required List<String> items,
  required String value,
  required Function(String?) onChanged,
  required bool isDarkMode,
  required ThemeProvider themeProvider,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'Comic Sans MS',
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
          dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
          ),
        ),
      ),
    ],
  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5, end: 0.0);
}