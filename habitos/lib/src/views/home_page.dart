import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitos/src/models/habito.dart';
import 'package:habitos/src/providers/habito_provider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final habitProvider = HabitProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Hábitos"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.replace('/login');
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          context.pushNamed('new-habit');
        },
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('habits')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Habit.fromJson(data);
          }).toList();

          if (habits.isEmpty) {
            return Center(child: Text("Aún no tienes hábitos creados"));
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];

              return Dismissible(
                key: Key(habit.id),

                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),

                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.edit, color: Colors.white),
                ),

                confirmDismiss: (direction) async {

                  // 👉 EDITAR
                  if (direction == DismissDirection.endToStart) {
                    context.pushNamed(
                      'update-habit',
                      pathParameters: {'id': habit.id},
                      extra: habit,
                    );
                    return false;
                  }

                  // 👉 ELIMINAR
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("¿Eliminar hábito?"),
                      content: Text("Esta acción no se puede deshacer."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('habits')
                                .doc(habit.id)
                                .delete();

                            Navigator.of(ctx).pop(true);
                          },
                          child: Text("Eliminar"),
                        ),
                      ],
                    ),
                  );
                },

                child: ListTile(
                  title: Text(habit.name),
                  subtitle: Text("Duración: ${habit.suggestedDuration} min"),
                  onTap: () {
                    context.pushNamed(
                      'update-habit',
                      pathParameters: {'id': habit.id},
                      extra: habit,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
