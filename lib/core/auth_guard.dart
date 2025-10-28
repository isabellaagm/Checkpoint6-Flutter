import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:checkpoint6/screens/home_screen.dart'; 
import 'package:checkpoint6/screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder escuta as mudanças de autenticação
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Estado de Carregamento:
        // Enquanto o Firebase decide se o usuário está logado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuário ESTÁ logado:
        // Se o snapshot tem dados (tem um usuário)
        if (snapshot.hasData) {
          return const HomeScreen(); // Mostra a tela Home
        }

        // Usuário NÃO ESTÁ logado:
        // Se o snapshot não tem dados
        return const LoginScreen(); // Mostra a tela de Login
      },
    );
  }
}