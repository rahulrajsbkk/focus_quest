import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
    super.key,
  });

  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  static const List<MoodItem> moods = [
    MoodItem('🤩', 'Super'),
    MoodItem('🙂', 'Good'),
    MoodItem('😐', 'Okay'),
    MoodItem('😴', 'Tired'),
    MoodItem('😫', 'Stressed'),
    MoodItem('😡', 'Angry'),
    MoodItem('😢', 'Sad'),
    MoodItem('🤓', 'Focused'),
    MoodItem('🌈', 'Creative'),
    MoodItem('🧘', 'Calm'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = selectedMood == mood.emoji;

        return InkWell(
          onTap: () => onMoodSelected(mood.emoji),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : null,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoodItem {
  const MoodItem(this.emoji, this.label);

  final String emoji;
  final String label;
}
