import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/components/menu.dart';
import 'package:front_opt120/models/user.dart';
import 'package:front_opt120/models/user_task.dart';
import 'package:front_opt120/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;


import '../models/task.dart';

final userTaskRoute = dotenv.env['USERTASK_ROUTE'];
final taskRoute = dotenv.env['TASK_ROUTE'];
final userRoute = dotenv.env['USER_ROUTE'];


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
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Future<List<UserTask>> fetchUserTasksByUserId(String userIdO) async {
  String? jwtToken = await getTokenSP();
  print('Fetching tasks for user $userIdO');
  print("${userTaskRoute!}user/$userIdO");
  final response = await http.get(
      Uri.parse("${userTaskRoute!}user/$userIdO"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      }
  );
  if(response.statusCode == 200){
    List<dynamic> data = jsonDecode(response.body);
    print('Data retrieved: $data');
    List<UserTask> tasks = data.map((task) {
      print('Task: $task');
      return UserTask.fromJson(task);
    }).toList();

    print('Tasks retrieved: $tasks');
    return tasks;
  } else {
    throw Exception("Failed to load tasks");
  }
}


Future<User> fetchUser(String userId) async {
  String? jwtToken = await getTokenSP();
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


Future<Task> fetchTask(String taskId) async {
  String? jwtToken = await getTokenSP();
  print('Fetching task $taskId');
  print("${taskRoute!}$taskId");

  final response = await http.get(
      Uri.parse("${taskRoute!}$taskId"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      }
  );
  if(response.statusCode == 200){
    print('Response body: ${response.body}');
    dynamic data = jsonDecode(response.body);
    print('Data retrieved: $data');
    Task task = Task.fromJson(data);
    print('Tasks retrieved: $task');
    return task;
  } else {
    throw Exception("Failed to load tasks");
  }
}

Future<bool> updateScore(BuildContext context, String taskId,
    String userId, String score) async {
  String? jwtToken = await getTokenSP();
  print('Updating score for task $taskId and user $userId');
  print('Score: $score');
  print("${userTaskRoute!}score/$userId/$taskId");
  final response = await http.put(
    Uri.parse("${userTaskRoute!}score/$userId/$taskId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'score': score,
    }),
  );

  if (response.statusCode == 200){
    print('Dados enviados com sucesso: ${response.body}');
    showSuccessDialog(context, 'Nota');
    return true;
  } else {
    throw Exception('Falha ao enviar dados');
  }
}

Future<bool> updateUser(BuildContext context, String userId, String name, String email, String password) async {
  String? jwtToken = await getTokenSP();
  print('Updating user $userId');
  print('Name: $name');
  print('Email: $email');
  print('Password: $password');
  print("${userTaskRoute!}user/$userId");

  Map<String, String> body = {
    'name': name,
    'email': email,
  };

  if(password.isNotEmpty){
    body['password'] = password;
  }

  final response = await http.put(
    Uri.parse("${userRoute!}$userId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200){
    print('Dados enviados com sucesso: ${response.body}');
    showSuccessDialog(context, 'Usuário');
    return true;
  } else {
    throw Exception('Falha ao enviar dados');
  }
}

Future<String> getProfileFromToken() async {
  String? jwtToken = await getTokenSP();
  var decodedToken = decodeJwtToken(jwtToken!);
  var userProfile = decodedToken['profile'];
  return userProfile['name'];
}


class UserProfilePage extends StatefulWidget {
  final User user;
  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: FutureBuilder<User>(
          future: fetchUser(widget.user.id.toString()),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name,
                style: const TextStyle(
                    color: Colors.white
                ),
              );
            } else if (snapshot.hasError) {
              return Text("Erro: ${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateUserPage(user: widget.user),
                ),
              ).then((_) {
                setState(() {});
              });
            },
            tooltip: 'Editar usuário',
          ),
        ],

        backgroundColor: Colors.deepPurple,
      ),
      drawer: const Menu(),
      body: Padding(
        key: key,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<User>(
                future: fetchUser(widget.user.id.toString()),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Nome: ${snapshot.data!.name}',
                      style: const TextStyle(fontSize: 20),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Erro: ${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                }
            ),
            const SizedBox(height: 8),
            FutureBuilder<User>(
                future: fetchUser(widget.user.id.toString()),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Email: ${snapshot.data!.email}',
                      style: const TextStyle(fontSize: 20),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Erro: ${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                }
            ),
          ],
        ),
      ),

    );
  }

  void refresh() {
    setState(() {
      key = UniqueKey();
    });
  }

}

// Pagina de atualização do user.
class UpdateUserPage extends StatefulWidget {
  final User user;
  const UpdateUserPage({super.key, required this.user});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;


  @override
  void initState(){
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    passwordController = TextEditingController();
  }

  bool isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar usuário',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Nome',
                ),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon:  Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,

                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),

                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    updateUser(
                        context,
                        widget.user.id.toString(),
                        nameController.text,
                        emailController.text,
                        passwordController.text);
                  },
                  child: const Text('Atualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
