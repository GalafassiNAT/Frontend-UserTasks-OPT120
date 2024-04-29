import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/models/task.dart';
import 'package:front_opt120/models/user.dart';
import 'package:http/http.dart' as http;
import '../components/menu.dart';
import '../utils/jwt_utils.dart';

final taskGet = dotenv.env['TASK_ROUTE'];
final userRoute = dotenv.env['USER_ROUTE'];
final userTaskRoute = dotenv.env['USERTASK_ROUTE'];

class UserTaskPage extends StatefulWidget{
  const UserTaskPage({super.key});

  @override
  State<UserTaskPage> createState() => _UserTaskPageState();
}

class _UserTaskPageState extends State<UserTaskPage> {

  Task? selectedTask;
  User? selectedUser;



  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: <Widget> [
              Icon(Icons.check, color: Colors.green),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Sucesso'),
              ),
            ],
          ),
          content: Text('Tarefa associada ao usuário com sucesso'),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> postData(int userId, int taskId) async{
    String? jwtToken = await getTokenSP();
    print('FUNCTION!!! User: $userId Task: $taskId');
    print('Route: $userTaskRoute');
    print('Map: ${<String, int>{'userId': userId, 'taskId': taskId}}');
    try {
      final response = await http.post(
        Uri.parse(userTaskRoute!),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(<String, int>{
          'userId': userId,
          'taskId': taskId
        }),
      );

      if (response.statusCode == 201) {
        print('Dados enviados com sucesso: ${response.body}');
        showSuccessDialog(context);
      } else {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Falha ao enviar dados');
      }
    } catch (e){
      print('Error: $e');
      print('Exception details: ${e.toString()}');
    }
  }


  Future<List<Task>> fetchTasks() async {
    String? jwtToken = await getTokenSP();
    final response = await http.get(
        Uri.parse(taskGet!),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        }
    );
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
    String? jwtToken = await getTokenSP();
    final response = await http.get(
        Uri.parse(userRoute!),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        }
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarefas do usuário", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(50),
                width: 700,
                decoration: const BoxDecoration(color: Colors.deepPurple,
                    borderRadius: BorderRadius.all(Radius.circular(23))
                ),
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    const Text("Tarefa do usuário", style: TextStyle(fontSize: 30,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 0.6,
                            color: Colors.black,
                          )
                        ]), ),
                    const SizedBox(height: 50,),
                    FutureBuilder<List<Task>>(
                      future: fetchTasks(),
                      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                        if(snapshot.hasData){
                          List<Task> tasks = snapshot.data!;
                          selectedTask ??= tasks[0];

                          return DropdownButtonFormField(
                            dropdownColor: const Color.fromRGBO(57, 9, 133, 100),
                            value: selectedTask,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.task,
                                color: Color.fromRGBO(198, 230, 232, 100),
                              ),
                              label: Text("Tarefa: ",
                                style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                              ),
                            ),
                            onChanged: (Task? newValue){
                              selectedTask = newValue;
                            },
                            items: tasks.map<DropdownMenuItem<Task>>((Task task){
                              return DropdownMenuItem<Task>(
                                value: task,
                                child: DefaultTextStyle(
                                  style: const TextStyle(color: Colors.white),
                                  child: Text(task.title),
                                ),
                              );
                            }).toList(),
                          );
                        } else if (snapshot.hasError){
                          return Text("Error: ${snapshot.error}");
                        } else{
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    FutureBuilder<List<User>>(
                      future: fetchUsers(),
                      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                        if(snapshot.hasData){
                          List<User> users = snapshot.data!;
                         selectedUser ??= users[0];
                          return DropdownButtonFormField(
                            dropdownColor: const Color.fromRGBO(57, 9, 133, 100),
                            value: selectedUser,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color.fromRGBO(198, 230, 232, 100),
                              ),
                              label: Text("Usuário: ",
                                style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                              ),
                            ),
                            onChanged: (User? newValue){
                              selectedUser = newValue;
                            },
                            items: users.map<DropdownMenuItem<User>>((User user){
                              return DropdownMenuItem<User>(
                                value: user,
                                child: DefaultTextStyle(
                                  style: const TextStyle(color: Colors.white),
                                  child: Text('${user.name} - ${user.email}'),
                                ),
                              );
                            }).toList(),
                          );
                        } else if (snapshot.hasError){
                          return Text("Error: ${snapshot.error}");
                        } else{
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 50,),
                    SizedBox(
                      width: 140,
                      child: FloatingActionButton(
                        backgroundColor: const Color.fromRGBO(57, 9, 133, 100),
                        onPressed: (){
                          print('User: ${selectedUser!.id} Task: ${selectedTask!.id}');
                          if(selectedUser != null && selectedTask != null){
                            postData(selectedUser!.id, selectedTask!.id);
                          } else {
                            print("User or Task is not selected");
                          }
                        },
                        child: const Text("Criar", style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
