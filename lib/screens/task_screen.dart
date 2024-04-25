import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../components/menu.dart';

final taskRoute = dotenv.env['TASK_ROUTE'];

final titleController = TextEditingController();
final descriptionController = TextEditingController();
final deliveryDateController = TextEditingController();


class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

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
          content: Text('Tarefa criada com sucesso'),
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
        deliveryDateController.text = pickedDateTime.toString();
      }
    }
  }




  Future<void> postData(BuildContext context, String title, String description,
      DateTime deliveryDate) async {
    final response = await http.post(
        Uri.parse(taskRoute!),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'description': description,
          'deliveryDate': deliveryDate.toIso8601String(),
        }),
    );

    if (response.statusCode == 201){
      print('Dados enviados com sucesso: ${response.body}');
      showSuccessDialog(context);
    } else {
      throw Exception('Falha ao enviar dados');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarefas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(50),
            height: 700,
            width: 700,
            decoration: const BoxDecoration(color: Colors.deepPurple,
                borderRadius: BorderRadius.all(Radius.circular(23))
            ),
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                const Text("Tarefas", style: TextStyle(fontSize: 30,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 0.6,
                        color: Colors.black,
                      )
                    ]), ),
                const SizedBox(height: 50,),
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.task,
                      color: Color.fromRGBO(198, 230, 232, 100),
                    ),
                    label: Text("Tarefa: ",
                      style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                    ),
                  ),
                ),
                TextFormField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color.fromRGBO(198, 230, 232, 100),
                    ),
                    label: Text("Descrição: ",
                      style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                  ),
                  ),
                ),
                TextFormField(
                  controller: deliveryDateController,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.date_range,
                      color: Color.fromRGBO(198, 230, 232, 100),
                    ),
                    label: const Text("Data de Vencimento: ",
                      style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: (){
                        _selectDate(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
               SizedBox(
                 width: 140,
                 child: FloatingActionButton(
                   backgroundColor: const Color.fromRGBO(57, 9, 133, 100),
                   onPressed: (){
                      postData(context, titleController.text,
                          descriptionController.text, DateTime.parse(deliveryDateController.text));
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
    );
  }
}
