import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 250, 250, 250),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image(
                image: AssetImage('assets/images/pa.png'),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.quiz,
              color: Color.fromARGB(255, 238, 179, 69),
            ),
            title: const Text('Interactive Quiz'),
            onTap: () {
              
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: Color.fromARGB(255, 238, 179, 69),
            ),
            title: const Text('Help & FAQs'),
            onTap: () {
            
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.share,
              color: Color.fromARGB(255, 238, 179, 69),
            ),
            title: const Text('Social\'s & Share'),
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}
