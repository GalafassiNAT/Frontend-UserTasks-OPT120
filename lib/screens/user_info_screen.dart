import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/models/user.dart';
import 'package:front_opt120/models/user_task.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

Future<List<UserTask>> fetchUserTasksByUserId(String userIdO) async {
  print('Fetching tasks for user $userIdO');
  print("${userTaskRoute!}user/$userIdO");
  final response = await http.get(Uri.parse("${userTaskRoute!}user/$userIdO"));
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

Future<double> fetchScore(String taskId, String userId) async {
  print('Fetching score for task $taskId and user $userId');
  print("${userTaskRoute!}user/$userId/task/$taskId");
  final response = await http.get(Uri.parse("${userTaskRoute!}user/$userId/task/$taskId"));
  if(response.statusCode == 200){
    dynamic data = jsonDecode(response.body);
    print('Data retrieved: $data');
    double score = data['Score'];
    print('Score retrieved: $score');
    return score;
  } else {
    throw Exception("Failed to load score");
  }
}

Future<User> fetchUser(String userId) async {
  print('Fetching user $userId');
  print("${userRoute!}$userId");
  final response = await http.get(Uri.parse("${userRoute!}$userId"));
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
  print('Fetching task $taskId');
  print("${taskRoute!}$taskId");

  final response = await http.get(Uri.parse("${taskRoute!}$taskId"));
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
  print('Updating score for task $taskId and user $userId');
  print('Score: $score');
  print("${userTaskRoute!}score/$userId/$taskId");
  final response = await http.put(
    Uri.parse("${userTaskRoute!}score/$userId/$taskId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
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



class ScoreHolder{
  double score;
  ScoreHolder(this.score);
}

class UserInfoPage extends StatefulWidget {
  final User user;
  const UserInfoPage({super.key, required this.user});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Key key = UniqueKey();
  ScoreHolder startScore = ScoreHolder(0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            const SizedBox(height: 8),
            FutureBuilder<List<UserTask>>(
              future: fetchUserTasksByUserId(widget.user.id.toString()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<UserTask>> snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: FutureBuilder<Task>(
                            future: fetchTask(
                                snapshot.data![index].taskId.toString()),
                            builder: (BuildContext context,
                                AsyncSnapshot<Task> taskSnapshot) {
                              if (taskSnapshot.hasData) {
                                return Text(
                                    'Tarefa: ${taskSnapshot.data!.title}');
                              } else if (taskSnapshot.hasError) {
                                return Text("Erro: ${taskSnapshot.error}");
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                          subtitle: FutureBuilder<Task>(
                            future: fetchTask(
                                snapshot.data![index].taskId.toString()),
                            builder: (BuildContext context,
                                AsyncSnapshot<Task> taskSnapshot) {
                              if (taskSnapshot.hasData) {
                                String formattedDate;
                                formattedDate =
                                    DateFormat('dd/MM/yyyy HH:mm:ss').format(
                                        taskSnapshot.data!.deliveryDate);
                                return Text(
                                    'Data de validade: ${formattedDate}');
                              } else if (taskSnapshot.hasError) {
                                return Text("Erro: ${taskSnapshot.error}");
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              FutureBuilder<double>(
                                future: fetchScore(
                                    snapshot.data![index].taskId.toString(),
                                    snapshot.data![index].userId.toString()),
                                builder: (BuildContext context,
                                    AsyncSnapshot<double> scoreSnapshot) {
                                  if (scoreSnapshot.hasData) {
                                    startScore.score = scoreSnapshot.data!;
                                    print('Score FUTURE: ${startScore.score}');
                                    return Text('Nota: \n${startScore.score}',
                                      style: TextStyle(fontSize: 15,
                                          color: startScore.score >= 6 ? Colors
                                              .green : Colors.red
                                      ),
                                    );
                                  } else if (scoreSnapshot.hasError) {
                                    return Text("Erro: ${scoreSnapshot.error}");
                                  }
                                  return const CircularProgressIndicator();
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditScorePage(
                                            initialScore: snapshot.data![index]
                                                .score,
                                            taskId: snapshot.data![index].taskId
                                                .toString(),
                                            userId: snapshot.data![index].userId
                                                .toString(),
                                          ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(
                                    Icons.edit, color: Colors.blue),
                                tooltip: 'Editar nota',

                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
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
  const UpdateUserPage({Key? key, required this.user}) : super(key: key);

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


// Pagina de edição da nota.
class EditScorePage extends StatefulWidget {
  final double initialScore;
  final String userId;
  final String taskId;

   EditScorePage({super.key,
  required this.initialScore,
    required this.taskId,
  required this.userId});

  @override
  _EditScorePageState createState() => _EditScorePageState();
}

class _EditScorePageState extends State<EditScorePage> {
  late double initialScore;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    initialScore = widget.initialScore;
    _controller = TextEditingController(text: initialScore.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Nota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Nota',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                     try{
                       bool success = await updateScore(
                           context,
                           widget.taskId,
                           widget.userId,
                            _controller.text
                       );
                       if(success){
                         initialScore = double.parse(_controller.text);
                       }
                     } catch(e){
                       print('Erro ao atualizar nota: $e');
                     }
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
