import 'package:flutter/material.dart';

class GoalsSection extends StatelessWidget {
  const GoalsSection({
    super.key,
    required this.weeklyGoal,
    required this.onChanged,
    required this.onSave,
  });

  final int weeklyGoal;
  final ValueChanged<int> onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Haftalık Egzersiz Hedefi: $weeklyGoal gün'),
          Slider(
            value: weeklyGoal.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$weeklyGoal gün',
            onChanged: (v) => onChanged(v.round()),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('Hedefi Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
