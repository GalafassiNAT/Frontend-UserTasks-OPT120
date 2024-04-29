import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/components/menu.dart';
import 'package:front_opt120/screens/initial_screen.dart';
import 'package:front_opt120/screens/user_info_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../models/user.dart';
import '../utils/jwt_utils.dart';

final userRoute = dotenv.env['USER_ROUTE'];
final taskRoute = dotenv.env['TASK_ROUTE'];

void showSuccessDialog(BuildContext context, String object) {
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
        content: Text('$object criado(a) com sucesso'),
        actions: <Widget>[
          TextButton(
            child: const Text('Fechar'),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),
        ],
      );
    },
  );
}

class AdminHomePage extends StatefulWidget{
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  final refreshNotifier = ValueNotifier<int>(0);

  Future<List<Task>> fetchTasks() async {
    String? jwtToken = await getTokenSP();
    checkTokenExpiration(jwtToken!);
    final response = await http.get(
        Uri.parse(taskRoute!),
        headers: {
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
    print('Token: $jwtToken');
    final response = await http.get(
        Uri.parse(userRoute!),
        headers: {
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
  void initState() {
    super.initState();
    verifyToken();
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
      ValueListenableBuilder(
          valueListenable: refreshNotifier,
          builder: (context, value, child) {
          return FutureBuilder<List<Task>>(
            key: ValueKey(value),
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
                                  snapshot.data![index].deliveryDate.toLocal())}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(task: snapshot.data![index]),
                                ),
                              ).then((_) => refresh());
                            },
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
          );
        }
      ),
    ];
  }

  Future<void> verifyToken() async {
    String? jwtToken = await getTokenSP();
    if(!(await isTokenValid(jwtToken))){
      if(mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const InitialScreen(),
          ),
        );
      }
    }
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


class EditTaskPage extends StatelessWidget {
  final Task task;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController deliveryDateController;
  EditTaskPage({super.key,
    required this.task,
  }) : titleController = TextEditingController(text: task.title),
        descriptionController = TextEditingController(text: task.description),
        deliveryDateController = TextEditingController(
            text: DateFormat('dd/MM/yyyy HH:mm:ss').format(
                task.deliveryDate.toLocal()));


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        deliveryDateController.text = DateFormat('dd/MM/yyyy HH:mm:ss')
            .format(pickedDateTime);
      }
    }
  }

  Future<void> updateTask(BuildContext context) async {
    String? jwtToken = await getTokenSP();
    DateTime deliveryDate = DateFormat('dd/MM/yyyy HH:mm:ss')
        .parse(deliveryDateController.text);
    final response = await http.put(
      Uri.parse('$taskRoute${task.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode(<String, dynamic>{
        'title': titleController.text,
        'description': descriptionController.text,
        'deliveryDate': deliveryDate.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      print('Task updated');
      showSuccessDialog(context, 'Tarefa');
    } else {
      throw Exception('Failed to update task');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar tarefa", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: titleController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.task,
                    color: Color.fromRGBO(198, 230, 232, 100),
                  ),
                  labelText: 'Título',
                ),
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                controller: descriptionController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.description,
                    color: Color.fromRGBO(198, 230, 232, 100),
                  ),
                  labelText: 'Descrição',
                ),
              ),
              TextFormField(
                readOnly: true,
                controller: deliveryDateController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color.fromRGBO(198, 230, 232, 100),
                  ),
                  labelText: 'Data de Validade',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: (){
                      _selectDate(context);
                    },
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    updateTask(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Atualizar'),
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}

