// lib/screens/home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkpoint6/screens/new_password_screen.dart';
import 'package:checkpoint6/widgets/password_list_item.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pega o usuário logado
  final User? _user = FirebaseAuth.instance.currentUser;

  late final CollectionReference _passwordsCollection;

  @override
  void initState() {
    super.initState();
    _passwordsCollection = FirebaseFirestore.instance.collection('passwords');
  }

  // Método para fazer Logout
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Método para deletar a senha 
  Future<void> _deletePassword(String documentId) async {
    try {
      await _passwordsCollection.doc(documentId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha deletada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar senha: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerador de Senhas"),
        actions: [
          // Mostra o email do usuário logado
          if (_user?.email != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(_user!.email!, style: const TextStyle(fontSize: 12)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair",
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Premium
          _buildPremiumBanner(),
          
          // Título "Minhas Senhas"
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Minhas Senhas",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Lista de Senhas (com StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Constrói o stream filtrando pelo userId 
              stream: _passwordsCollection
                  .where('userId', isEqualTo: _user!.uid)
                  .orderBy('created_at', descending: true) // Ordena pelas mais novas
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Estado de Carregamento 
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Estado de Erro 
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Ocorreu um erro ao carregar os dados.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                // 3. Estado de Lista Vazia 
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhum registro encontrado.\nAdicione uma senha para começar!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // 4. Dados Disponíveis (Mostrar a Lista) 
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Usa o widget que criamos
                    return PasswordListItem(
                      label: data['label'] ?? 'Sem Rótulo',
                      password: data['password'] ?? '******',
                      documentId: doc.id,
                      onDelete: _deletePassword, // Passa a função de deletar
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Botão
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewPasswordScreen(),
            ),
          );
        },
        tooltip: 'Nova Senha',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget para o banner 
  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      color: Colors.purple.shade800,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          const Text(
            "GET PREMIUM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              // Ação do botão
            },
            child: const Text("BUY", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}