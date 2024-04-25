import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/components/menu.dart';
import 'package:front_opt120/screens/user_info_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../models/user.dart';

final userRoute = dotenv.env['USER_ROUTE'];
final taskRoute = dotenv.env['TASK_ROUTE'];



class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  final refreshNotifier = ValueNotifier<int>(0);

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(taskRoute!));
    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      print('Data retrieved: $data');
      List<Task> tasks = data.map((task) => Task.fromJson(task)).toList();
      print('Tasks retrieved: $tasks');
      return tasks;
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(userRoute!));
    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      print('Data retrieved: $data');
      List<User> users = data.map((user) => User.fromJson(user)).toList();
      print('Users retrieved: $users');
      return users;
    } else {
      throw Exception("Failed to load users");
    }
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      ValueListenableBuilder(
          valueListenable: refreshNotifier,
        builder: (context, value, child) {
          return FutureBuilder<List<User>>(
            key: ValueKey(value),
            future: fetchUsers(),
            builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text(snapshot.data![index].email),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfoPage(user: snapshot.data![index]),
                        ),
                    ).then((_) => refresh()),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          );
        }
      ),
      FutureBuilder<List<Task>>(
        future: fetchTasks(),
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Data de validade: \n${DateFormat('dd/MM/yyyy HH:mm:ss').format(
                              snapshot.data![index].deliveryDate)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: (){},
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar tarefa',
                      ),
                    ],
                  ),

                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        },
      ),
    ];
  }

  void refresh(){
    setState(() {
      refreshNotifier.value++;
    });
  }

  @override
  void dispose() {
    refreshNotifier.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opt120", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(208, 207, 209, 100),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tarefas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      )
    );
  }
}
