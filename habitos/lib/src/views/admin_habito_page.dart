import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitos/src/models/habito.dart';
import 'package:habitos/src/providers/habito_provider.dart';
import 'package:habitos/src/shared/utils.dart';
import 'package:uuid/uuid.dart';

class AdminHabitPage extends StatefulWidget {
  final Habit? habit;

  const AdminHabitPage({super.key, this.habit});

  @override
  State<AdminHabitPage> createState() => _AdminHabitPageState();
}

class _AdminHabitPageState extends State<AdminHabitPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();

  final habitProvider = HabitProvider();

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      titleController.text = widget.habit!.name;
      descriptionController.text = widget.habit!.description ?? '';
      durationController.text =
          widget.habit!.suggestedDuration.toString();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitId = GoRouterState.of(context).pathParameters['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit == null
              ? "Crear nuevo hábito"
              : "Editando hábito #$habitId",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                label: Text('Nombre del hábito'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text('Descripción'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                label: Text('Duración sugerida (minutos)'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.timer),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.save, color: Colors.white),
        onPressed: () async {
          if (titleController.text.isEmpty ||
              durationController.text.isEmpty) {
            Utils.showSnackBar(
              context: context,
              title: "Nombre y duración son obligatorios",
              color: Colors.red,
            );
            return;
          }

          final newHabit = Habit(
            id: habitId ?? Uuid().v4(),
            name: titleController.text,
            description: descriptionController.text,
            suggestedDuration: int.parse(durationController.text),
            startDate: DateTime.now(),
            totalDaysCompleted:
                widget.habit?.totalDaysCompleted ?? 0,
          );

          await habitProvider.saveHabit(newHabit);

          if (!mounted) return;

          Utils.showSnackBar(
            context: context,
            title: "Hábito guardado correctamente",
            color: Colors.green,
          );

          context.pop();
        },
      ),
    );
  }
}
