import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../components/menu.dart';
import '../models/task.dart';
import '../models/user_task.dart';
import '../utils/jwt_utils.dart';
import 'package:http/http.dart' as http;

import 'initial_screen.dart';

final taskRoute = dotenv.env['TASK_ROUTE'];
final userTaskRoute = dotenv.env['USERTASK_ROUTE'];

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

Future<void> deliverTask(String taskId) async{
  String? jwtToken = await getTokenSP();
  var decodedToken = decodeJwtToken(jwtToken as String);
  String userId = decodedToken['id'].toString();
  
  final response = await http.put(
    Uri.parse("${userTaskRoute!}$userId/$taskId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'delivered': DateTime.now().toIso8601String(),
    }),
  );
  if(response.statusCode != 200){
    throw Exception('Failed to deliver task');
  }
  print('Task delivered');
  
}

Future<List<UserTask>> fetchUserTasksByUserId() async {

  String? jwtToken = await getTokenSP();
  var decodedToken = decodeJwtToken(jwtToken as String);
  String userIdO = decodedToken['id'].toString();

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

Future<double> fetchScore(String taskId) async {
  String? jwtToken = await getTokenSP();
  var decodedToken = decodeJwtToken(jwtToken as String);
  String userId = decodedToken['id'].toString();
  print('Fetching score for task $taskId and user $userId');
  print("${userTaskRoute!}user/$userId/task/$taskId");
  final response = await http.get(
      Uri.parse("${userTaskRoute!}user/$userId/task/$taskId"),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      }
  );
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

class ScoreHolder{
  double score;
  ScoreHolder(this.score);
}

class DeliveredDateHolder{
  DateTime deliveredDate;
  bool isDelivered;
  DeliveredDateHolder(this.deliveredDate, this.isDelivered);
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  ScoreHolder startScore = ScoreHolder(0.0);
  DeliveredDateHolder deliveredDate = DeliveredDateHolder(DateTime.now(), false);

  @override
  void initState() {
    super.initState();
    verifyToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Página',
        style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
                future: fetchUserTasksByUserId(),
                builder: (BuildContext builder,
                AsyncSnapshot<List<UserTask>> snapshot){
                  if(snapshot.hasData){
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index){
                          return ListTile(
                            title: FutureBuilder<Task>(
                                future: fetchTask(
                                    snapshot.data![index].taskId.toString()),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Task> taskSnapshot){
                                  if(taskSnapshot.hasData){
                                    return Text(taskSnapshot.data!.title);
                                  } else if (taskSnapshot.hasError){
                                    return Text('Erro: ${taskSnapshot.error}');
                                  }
                                  return const CircularProgressIndicator();
                                }
                            ),
                            subtitle: Row(
                              children: [
                                FutureBuilder<Task>(
                                      future: fetchTask(snapshot.data![index].taskId.toString()),
                                      builder: (BuildContext context,
                                      AsyncSnapshot<Task> taskSnapshot){
                                        if(taskSnapshot.hasData){
                                          String formattedDate;
                                          formattedDate =
                                              DateFormat('dd/MM/yyyy HH:mm:ss').format(
                                                taskSnapshot.data!.deliveryDate);
                                          return Text('Data de vencimento: $formattedDate');
                                        } else if (taskSnapshot.hasError){
                                          return Text('Erro: ${taskSnapshot.error}');
                                        }
                                        return const CircularProgressIndicator();
                                      }
                                    ),
                                const SizedBox(width: 10,),
                                snapshot.data![index].isDelivered
                                  ? Text('Entregue em: ${
                                    DateFormat('dd/MM/yyyy HH:mm:ss')
                                        .format(snapshot.data![index].delivered)}',
                                  style: const TextStyle(
                                    color: Colors.green
                                  ),
                                  )
                                : const SizedBox.shrink(),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                FutureBuilder<double>(
                                  future:fetchScore(
                                      snapshot.data![index].taskId.toString()
                                  ),
                                  builder: (BuildContext context,
                                  AsyncSnapshot<double> scoreSnapshot){
                                    if(scoreSnapshot.hasData){
                                      startScore.score = scoreSnapshot.data!;
                                      return Text('Nota: ${startScore.score}',
                                        style: TextStyle(fontSize: 15,
                                        color: startScore.score >= 6 ?
                                        Colors.green : Colors.red
                                        )
                                      );
                                    } else if (scoreSnapshot.hasError){
                                      return Text('Erro: ${scoreSnapshot.error}');
                                    }
                                    return const CircularProgressIndicator();
                                  },
                                ),
                                const SizedBox(width: 10,),
                                if(!snapshot.data![index].isDelivered)
                                  IconButton(
                                      onPressed: (){
                                        deliverTask(snapshot.data![index].taskId.toString());
                                        setState(() {
                                          deliveredDate.deliveredDate = DateTime.now();
                                          deliveredDate.isDelivered = true;
                                        });
                                      },
                                      icon: const Icon(Icons.check,
                                      color: Colors.green,),
                                    tooltip: 'Confirmar envio',
                                  )
                              ],
                            ),
                          );
                        }
                      )
                    );
                  } else if (snapshot.hasError){
                    return Text('Erro: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                }
            ),
          ],
        )
      ),
    );
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

}


