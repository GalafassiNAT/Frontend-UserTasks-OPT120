import 'package:flutter/material.dart';
import 'package:front_opt120/screens/task_screen.dart';
import 'package:front_opt120/screens/user_screen.dart';

import '../screens/home_screen.dart';
import '../screens/user_task_screen.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
           Container(
            color: Colors.grey,
            child: const ListTile(
              title: Text("Bem-vindo!"),
              leading: Icon(Icons.person),
            ),
          ),
          ListTile(
            title: const Text("Home"),
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> const HomePage()));
            },
          ),
          ListTile(
            title: const Text("Usuário"),
            leading: const Icon(Icons.person_add),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> const UserPage()));
            },
          ),
          ListTile(
            title: const Text("Tarefa"),
            leading: const Icon(Icons.task),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> const TaskPage()));
            },
          ),
          ListTile(
            title: const Text("Tarefas do Usuário"),
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> const UserTaskPage()));
            },
          )
        ],
      ),
    );
  }
}

