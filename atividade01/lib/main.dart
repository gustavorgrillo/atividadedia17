import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class BaseScreen extends StatelessWidget {
  final String title;
  final List<String> disciplinas;

  const BaseScreen({
    super.key,
    required this.title,
    this.disciplinas = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: disciplinas.isEmpty
          ? const Center(
              child: Text(
                'Selecione um semestre no menu lateral.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: disciplinas.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(disciplinas[index]),
                  ),
                );
              },
            ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void abrirTela(BuildContext context, Widget tela) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => tela),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Maria Silva'),
            accountEmail: Text('maria.silva@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48, color: Colors.blue),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => abrirTela(context, const HomeScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.looks_one),
            title: const Text('Primeiro Semestre'),
            onTap: () => abrirTela(context, const PrimeiroScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.looks_two),
            title: const Text('Segundo Semestre'),
            onTap: () => abrirTela(context, const SegundoScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.looks_3),
            title: const Text('Terceiro Semestre'),
            onTap: () => abrirTela(context, const TerceiroScreen()),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Home',
    );
  }
}

class PrimeiroScreen extends StatelessWidget {
  const PrimeiroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Primeiro Semestre',
      disciplinas: [
        'Algoritmos',
        'Fundamentos de Computação',
        'Matemática Discreta',
      ],
    );
  }
}

class SegundoScreen extends StatelessWidget {
  const SegundoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Segundo Semestre',
      disciplinas: [
        'Programação Orientada a Objetos',
        'Estrutura de Dados',
        'Banco de Dados',
      ],
    );
  }
}

class TerceiroScreen extends StatelessWidget {
  const TerceiroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: 'Terceiro Semestre',
      disciplinas: [
        'Desenvolvimento Mobile',
        'Engenharia de Software',
        'Arquitetura de Computadores',
      ],
    );
  }
}
