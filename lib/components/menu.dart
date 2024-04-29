import 'package:flutter/material.dart';
import 'package:front_opt120/screens/task_screen.dart';
import 'package:front_opt120/screens/user_screen.dart';

import '../screens/admin_home_screen.dart';
import '../screens/user_task_screen.dart';
import '../utils/jwt_utils.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<String?> getThisToken() async {
    return await getTokenSP();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getThisToken(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        String? name;
        String? profileName;
        if(snapshot.connectionState == ConnectionState.waiting){
          return const CircularProgressIndicator();
        } else if (snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        } else {
          var decodedToken = decodeJwtToken(snapshot.data!);
          name = decodedToken['name'];
          profileName = decodedToken['profile']['name'];
        }
        return Drawer(
          child: ListView(
            children: [
               Container(
                color: Colors.deepPurple,
                child: ListTile(
                  title: Text("Bem-vindo $name!",
                      style: const TextStyle(color: Colors.white)
                  ),
                  leading: const Icon(
                      Icons.person,
                      color: Colors.white,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    onPressed: () async {
                      await removeTokenSP();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  )
                ),
              ),
              if(profileName == 'ADMIN')
                ListTile(
                  title: const Text("Home"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> const AdminHomePage()));
                  },
                ),
              if(profileName == 'ADMIN')
                ListTile(
                  title: const Text("Usuário"),
                  leading: const Icon(Icons.person_add),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> const UserPage()));
                  },
                ),
              if(profileName == 'ADMIN')
                ListTile(
                  title: const Text("Tarefa"),
                  leading: const Icon(Icons.task),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> const TaskPage()));
                  },
                ),
              if(profileName == 'ADMIN')
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
    );
  }
}

