import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/screens/task_screen.dart';
import 'package:front_opt120/screens/user_profile_screen.dart';
import 'package:front_opt120/screens/user_screen.dart';

import '../models/user.dart';
import '../screens/admin_home_screen.dart';
import '../screens/user_home_screen.dart';
import '../screens/user_task_screen.dart';
import '../utils/jwt_utils.dart';
import 'package:http/http.dart' as http;

final userRoute = dotenv.env['USER_ROUTE'];


class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<String?> getThisToken() async {
    return await getTokenSP();
  }

  Future<User> fetchUser() async {
    String? jwtToken = await getTokenSP();
    var decodedToken = decodeJwtToken(jwtToken!);
    String userId = decodedToken['id'].toString();
    print('Fetching user $userId');
    print("${userRoute!}$userId");
    final response = await http.get(
        Uri.parse("${userRoute!}$userId"),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        }
    );
    if(response.statusCode == 200){
      dynamic data = jsonDecode(response.body);
      print('Data retrieved: $data');
      User user = User.fromJson(data);
      print('User retrieved: $user');
      return user;
    } else {
      throw Exception("Failed to load user");
    }

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
                ),
              if(profileName == 'USER')
                ListTile(
                  title: const Text("Home"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=> const UserHomePage()));
                  },
                ),
              if(profileName == 'USER')
                FutureBuilder<User>(
                  future: fetchUser(),
                  builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListTile(
                        title: const Text("Perfil"),
                        leading: const Icon(Icons.person),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => UserProfilePage(user: snapshot.data!),
                          ));
                        },
                      );
                    }
                  },
                )
            ],
          ),
        );
      }
    );
  }
}

