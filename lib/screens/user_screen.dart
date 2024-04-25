import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/components/menu.dart';
import 'package:http/http.dart' as http;

final userPost = dotenv.env['USER_ROUTE'];

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  bool isPasswordVisible = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


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
          content: Text('Usuário criado com sucesso'),
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


  Future<void> postData(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(userPost!),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
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
        title: const Text("Usuário", style: TextStyle(color: Colors.white)),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                 const Text("Usuário", style: TextStyle(fontSize: 30,
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
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Color.fromRGBO(198, 230, 232, 100),
                      ),
                      label: Text("Username: ",
                        style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Color.fromRGBO(198, 230, 232, 100),
                      ),
                      label: Text("E-mail: ",
                        style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color.fromRGBO(198, 230, 232, 100),
                      ),
                      label: const Text("Senha: ",
                        style: TextStyle(color: Color.fromRGBO(198, 230, 232, 100)),
                      ),
              
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromRGBO(198, 230, 232, 100),
                        ),
                        onPressed: (){
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
              
                      ),
              
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: SizedBox(
                      width: 140,
                      child: FloatingActionButton(
                        backgroundColor: const Color.fromRGBO(57, 9, 133, 100),
              
                        onPressed: (){
                          print('ROTA: ${userPost}');
                          postData(nameController.text, emailController.text, passwordController.text);
                      },
                        child: const Text("Criar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
