import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_opt120/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final loginRoute = dotenv.env['LOGIN_ROUTE'];
final userRoute = dotenv.env['USER_ROUTE'];



const storage = FlutterSecureStorage();

Future<void> login(String email, String password,
    BuildContext context) async {
  final response = await http.post(
    Uri.parse(loginRoute!),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200){
    print('Dados enviados com sucesso: ${response.body}');
    try{
      print('Decodificando a resposta do servidor');
      var responseBody = jsonDecode(response.body);
      print('Decodificando a resposta do servidor 2');
      var jwtToken = responseBody['token'];
      print('Decodificando a resposta do servidor 3 token: $jwtToken');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', jwtToken);
      checkTokenExpiration(jwtToken);
      print('Decodificando a resposta do servidor 4');
      var decodedToken = decodeJwtToken(jwtToken);
      print('Decodificando a resposta do servidor 5');
      var userProfile = decodedToken['profile'];
      print('User profile: ${userProfile}');


      if(userProfile['name'] == 'ADMIN'){
        print('EU SOU ADMIN');
        Navigator.pushNamed(context, '/adminHome');
      } else {
        print('EU NAO SOU ADMIN');
        Navigator.pushNamed(context, '/userHome');
      }
    } catch (e){
      print('Erro ao decodificar a resposta do servidor: $e');
    }
  } else {
    var responseBody = jsonDecode(response.body);
    var errorMessage = responseBody['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$errorMessage',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
    throw Exception('Falha ao enviar dados');
  }

}

Future<void> postData(String name, String email, String password,
    BuildContext context) async {
  final response = await http.post(
    Uri.parse(userRoute!),
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dados enviados com sucesso!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
        ),
    );
  } else {
    throw Exception('Falha ao enviar dados');
  }

}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSigningIn = true;
  bool isPasswordVisible = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _swapSigning(){
    setState(() {
      _isSigningIn = !_isSigningIn;

      nameController.clear();
      emailController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            padding: const EdgeInsets.all(13),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: VerticalPainter(isSigningIn: _isSigningIn),
                ),
                SizedBox(
                  height: 700,
                  width: 700,
                  child: Row(
                    children: [
                      Container(
                        width: 350,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              _isSigningIn ? 'Login' : 'Cadastro',
                              style: TextStyle(
                                  fontSize: 50 ,
                                  color: _isSigningIn ? Colors.deepPurple : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                if(!_isSigningIn)
                                  TextFormField(
                                    controller: nameController,
                                    style: TextStyle(
                                        color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100)
                                    ),
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100),
                                      ),
                                      label: Text("Username: ",
                                        style: TextStyle(
                                            color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100),
                                      ),
                                    ),
                                    )
                                  ),
                                TextFormField(
                                  controller: emailController,
                                    style: TextStyle(
                                        color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100)
                                    ),
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100),
                                      ),
                                      label: Text("Email: ",
                                        style: TextStyle(
                                          color: _isSigningIn ? Colors.deepPurple: const Color.fromRGBO(198, 230, 232, 100),
                                        ),
                                      ),
                                    )
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  style: TextStyle(
                                    color: _isSigningIn ? Colors.deepPurple : const Color.fromRGBO(198, 230, 232, 100)
                                  ),
                                  obscureText: isPasswordVisible,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: _isSigningIn ? Colors.deepPurple : const Color.fromRGBO(198, 230, 232, 100),
                                    ),
                                    label: Text("Senha: ",
                                    style: TextStyle(
                                      color: _isSigningIn ? Colors.deepPurple : const Color.fromRGBO(198, 230, 232, 100),
                                    ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        !isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: _isSigningIn ? Colors.deepPurple : const Color.fromRGBO(198, 230, 232, 100),
                                      ),
                                      onPressed: (){
                                        setState(() {
                                          isPasswordVisible = !isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 120,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (_isSigningIn){
                                          login(emailController.text, passwordController.text, context);
                                        } else {
                                          postData(nameController.text, emailController.text, passwordController.text, context);
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(_isSigningIn ? Colors.deepPurple : Colors.white),
                                        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(20)),
                                      ),
                                      child: Text(
                                        _isSigningIn ? 'Entrar' : 'Cadastrar',
                                        style: TextStyle(
                                          color: _isSigningIn ? Colors.white : Colors.deepPurple,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: _swapSigning,
                                 child: Text(_isSigningIn ? 'Não tem uma conta?' : 'Já tem uma conta?',
                                  style: TextStyle(
                                    color: _isSigningIn ? Colors.deepPurple : Colors.white,
                                    fontSize: 14,
                                  ),
                                 ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ]
            ),
          ),
        ),
      )
    );
  }
}

class VerticalPainter extends CustomPainter {
  final bool isSigningIn;

  VerticalPainter({required this.isSigningIn});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    var path = Path();

    // Draw the right half of the screen
    paint.color = isSigningIn ? Colors.deepPurple : Colors.white;
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2 , size.height );
    path.lineTo(size.width /2, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Draw the left half of the screen
    paint.color = isSigningIn ? Colors.white : Colors.deepPurple;
    path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
