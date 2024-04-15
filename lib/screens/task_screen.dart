import 'package:flutter/material.dart';

import '../components/menu.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

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
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: Color.fromRGBO(198, 230, 232, 100),
                    ),
                    label: Text("Data: ",
                      style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
               SizedBox(
                 width: 140,
                 child: FloatingActionButton(
                   backgroundColor: const Color.fromRGBO(57, 9, 133, 100),
                   onPressed: (){

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
