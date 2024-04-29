import 'package:flutter/material.dart';
import 'package:front_opt120/screens/login_screen.dart';
import 'package:front_opt120/screens/user_home_screen.dart';
import 'package:front_opt120/utils/jwt_utils.dart';

import 'admin_home_screen.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTokenSP(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else{
            if (snapshot.hasData && snapshot.data != null){
              var decodedToken = decodeJwtToken(snapshot.data!);
              var userProfile = decodedToken['profile'];

              if (userProfile['name'] == 'ADMIN'){
                return const AdminHomePage();
              }else {
                return const UserHomePage();
              }
            } else {
              return const LoginPage();
            }
          }

     },
    );
  }
}
