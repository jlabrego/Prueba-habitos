import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitos/src/models/habito.dart';

class HabitProvider {
  // Obtener todos los hábitos del usuario
  Future<List<Habit>> getAllHabits() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final db = FirebaseFirestore.instance;

    final snapshot = await db
      .collection('users')
      .doc(userId)
      .collection('habits')
      .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Habit.fromJson(data);
    }).toList();
  }

  // Guardar hábito (crear o actualizar)
  Future<void> saveHabit(Habit habit) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final db = FirebaseFirestore.instance;

    final docRef = db
      .collection('users')
      .doc(userId)
      .collection('habits')
      .doc(habit.id);

    await docRef.set(habit.toJson());
  }

  // Guardar progreso de un hábito
  Future<void> saveProgress(String habitId, int minutesDone, DateTime date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final db = FirebaseFirestore.instance;

    await db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .collection('progress')
        .doc(date.toIso8601String())
        .set({
      'minutesDone': minutesDone,
      'completed': minutesDone > 0,
      'date': date.toIso8601String(),
    });
  }

  // Marcar hábito como completado (si lo necesitas)
  Future<bool> markAsComplete(String habitId, bool value) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final db = FirebaseFirestore.instance;

      final docRef = db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId);

      await docRef.update({'completed': value});
      return true;
    } catch (e) {
      return false;
    }
  }
}
