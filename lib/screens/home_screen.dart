import 'package:flutter/material.dart';
import 'package:front_opt120/components/menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Opt120", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),

      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white
        ),
        child: const Center(
            child:
          Text("Home", style: TextStyle(fontSize: 30,
              color: Colors.deepPurple,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0.6,
                  color: Colors.black,
                )
              ])
          ),
        ),
      ),
    );
  }
}
