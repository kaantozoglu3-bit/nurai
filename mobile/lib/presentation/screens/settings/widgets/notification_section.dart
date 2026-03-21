import 'package:flutter/material.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.exerciseNotifEnabled,
    required this.exerciseTime,
    required this.painLogNotifEnabled,
    required this.painLogTime,
    required this.onExerciseNotifChanged,
    required this.onExerciseTimeChanged,
    required this.onPainLogNotifChanged,
    required this.onPainLogTimeChanged,
    required this.onSave,
  });

  final bool exerciseNotifEnabled;
  final TimeOfDay exerciseTime;
  final bool painLogNotifEnabled;
  final TimeOfDay painLogTime;
  final ValueChanged<bool> onExerciseNotifChanged;
  final ValueChanged<TimeOfDay> onExerciseTimeChanged;
  final ValueChanged<bool> onPainLogNotifChanged;
  final ValueChanged<TimeOfDay> onPainLogTimeChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Egzersiz Hatırlatıcısı'),
          value: exerciseNotifEnabled,
          onChanged: onExerciseNotifChanged,
        ),
        if (exerciseNotifEnabled)
          ListTile(
            title: const Text('Egzersiz Saati'),
            trailing: Text(exerciseTime.format(context)),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: exerciseTime,
              );
              if (t != null) onExerciseTimeChanged(t);
            },
          ),
        SwitchListTile(
          title: const Text('Ağrı Günlüğü Hatırlatması'),
          value: painLogNotifEnabled,
          onChanged: onPainLogNotifChanged,
        ),
        if (painLogNotifEnabled)
          ListTile(
            title: const Text('Günlük Kayıt Saati'),
            trailing: Text(painLogTime.format(context)),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: painLogTime,
              );
              if (t != null) onPainLogTimeChanged(t);
            },
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('Bildirimleri Kaydet'),
            ),
          ),
        ),
      ],
    );
  }
}
