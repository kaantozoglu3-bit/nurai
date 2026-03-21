import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.ageCtrl,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.fitnessLevel,
    required this.injuries,
    required this.onFitnessLevelChanged,
    required this.onInjuryAdded,
    required this.onInjuryRemoved,
    required this.onSave,
  });

  final TextEditingController ageCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final String fitnessLevel;
  final List<String> injuries;
  final ValueChanged<String> onFitnessLevelChanged;
  final ValueChanged<String> onInjuryAdded;
  final ValueChanged<String> onInjuryRemoved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Boy (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: fitnessLevel,
            decoration: const InputDecoration(
              labelText: 'Fitness Seviyesi',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Başlangıç')),
              DropdownMenuItem(value: 'intermediate', child: Text('Orta')),
              DropdownMenuItem(value: 'advanced', child: Text('İleri')),
            ],
            onChanged: (v) => onFitnessLevelChanged(v ?? 'beginner'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                ...injuries.map(
                  (inj) => Chip(
                    label: Text(inj),
                    onDeleted: () => onInjuryRemoved(inj),
                  ),
                ),
                ActionChip(
                  label: const Text('+ Ekle'),
                  onPressed: () async {
                    final ctrl = TextEditingController();
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sakatlık/Rahatsızlık Ekle'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                            hintText: 'örn: Bel fıtığı',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, ctrl.text),
                            child: const Text('Ekle'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      onInjuryAdded(result.trim());
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('Profili Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
