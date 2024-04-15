import 'package:flutter/material.dart';
import 'package:front_opt120/components/menu.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  bool isPasswordVisible = true;

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
    );
  }
}
