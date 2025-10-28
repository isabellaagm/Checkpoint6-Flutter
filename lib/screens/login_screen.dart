import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variável para a instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variáveis de estado da UI
  bool _isLoading = false;
  bool _isObscure = true;

  // --- MÉTODOS DE AUTENTICAÇÃO ---

  // Método para Login
  Future<void> _signIn() async {
    // Valida o formulário antes de tentar o login
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se o login for bem-sucedido, o AuthGuard irá automaticamente navegar para a HomeScreen.
    } on FirebaseAuthException catch (e) { // Captura exceções específicas do Firebase
      String errorMessage = "Ocorreu um erro desconhecido.";
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar("Erro ao entrar: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método para Registro
  Future<void> _signUp() async {
    // Valida o formulário antes de tentar o registro
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Após o registro, o AuthGuard também navegará para a HomeScreen.
    } on FirebaseAuthException catch (e) { // Captura exceções específicas do Firebase
      String errorMessage = "Ocorreu um erro desconhecido.";
      if (e.code == 'weak-password') {
        errorMessage = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está em uso por outra conta.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
       _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar("Erro ao registrar: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Método auxiliar para mostrar SnackBar de erro
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- CONSTRUÇÃO DA UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo e Textos de Boas-Vindas
                    const Icon(Icons.lock_outline, size: 80, color: Colors.purple),
                    const SizedBox(height: 16),
                    Text(
                      "Bem-vindo!",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Acesse ou crie sua conta", // Texto atualizado
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Campo de Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // --- VALIDADOR DE E-MAIL ATUALIZADO ---
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha o e-mail';
                        }
                        // Validação simples de e-mail (deve conter @)
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Digite um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // --- VALIDADOR DE SENHA ATUALIZADO ---
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha a senha';
                        }
                        // Validação de senha (mínimo de 6 caracteres)
                        if (value.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Indicador de Loading ou Botões
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              // Botão Entrar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _signIn,
                                  child: const Text(
                                    "Entrar",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Botão Registrar
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.purple,
                                    side: const BorderSide(
                                        color: Colors.purple, width: 2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Padding ajustado
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _signUp,
                                  child: const Text(
                                    "Registrar",
                                    style: TextStyle(fontSize: 16), // Fonte padronizada
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
