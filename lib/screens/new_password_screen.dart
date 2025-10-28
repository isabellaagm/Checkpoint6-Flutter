import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  // --- Variáveis de Estado da UI ---
  double _passwordLength = 12.0;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  String _generatedPassword = 'Senha não informada';
  bool _isLoading = false;

  // --- API (MÉTODO CORRIGIDO) ---
  Future<void> _generatePassword() async {
    setState(() {
      _isLoading = true;
      _generatedPassword = 'Gerando...';
    });

    // 1. Definir a URL correta para POST (sem query params)
    final uri = Uri.parse('https://safekey-api-a1bd9aa97953.herokuapp.com/generate');

    // 2. Criar o CORPO (body) da requisição, conforme a documentação
    final Map<String, dynamic> body = {
      'length': _passwordLength.toInt(),
      'includeLowercase': _includeLowercase,
      'includeUppercase': _includeUppercase,
      'includeNumbers': _includeNumbers,
      'includeSymbols': _includeSymbols,
    };

    try {
      // 3. Fazer a chamada POST
      final response = await http.post(
        uri,
        headers: {
          // Informar à API que estamos enviando dados em formato JSON
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // 4. Codificar o Map (body) para uma string JSON
        body: jsonEncode(body),
      );

      // 5. Tratar a resposta
      if (response.statusCode == 200 || response.statusCode == 201) { // 200 (OK) ou 201 (Created)
        final data = json.decode(response.body);
        setState(() {
          // A API retorna 
          _generatedPassword = data['password'];
        });
      } else {
        // A API retornou um erro (400, 404, 500, etc.)
        throw Exception('Falha ao carregar senha. Status: ${response.statusCode}, Resposta: ${response.body}');
      }
    } catch (e) {
      // Erro de rede (sem conexão, timeout) ou de exceção
      setState(() {
        _generatedPassword = 'Erro ao gerar';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na API: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // --- FIRESTORE ---
  Future<void> _savePassword() async {
    if (_generatedPassword == 'Senha não informada' || _generatedPassword.contains('...')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gere uma senha antes de salvar.')),
      );
      return;
    }

    // 1. Obter o usuário logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; 

    // 2. Pedir o Rótulo (Label) via AlertDialog
    final labelController = TextEditingController();
    String? label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salvar senha'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(hintText: 'Tipo da senha (ex: Email)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(labelController.text);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    // 3. Salvar no Firestore
    if (label != null && label.isNotEmpty) {
      try {
        final collection = FirebaseFirestore.instance.collection('passwords');

        await collection.add({
          'label': label,
          'password': _generatedPassword,
          'created_at': FieldValue.serverTimestamp(),
          'userId': user.uid,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Senha salva com sucesso!'),
              backgroundColor: Colors.green, // Feedback visual
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de Senhas'),
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gerador de Senhas',
                applicationVersion: '1.0.0',
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget de Resultado
            _buildPasswordResultWidget(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Opções de Geração
            Text('Tamanho da senha: ${_passwordLength.toInt()}'),
            Slider(
              value: _passwordLength,
              min: 8.0,
              max: 32.0,
              divisions: 24,
              label: _passwordLength.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _passwordLength = value;
                });
              },
            ),
            _buildOptionSwitch(
              title: 'Incluir letras minúsculas (a-z)',
              value: _includeLowercase,
              onChanged: (val) => setState(() => _includeLowercase = val),
            ),
            _buildOptionSwitch(
              title: 'Incluir letras maiúsculas (A-Z)',
              value: _includeUppercase,
              onChanged: (val) => setState(() => _includeUppercase = val),
            ),
            _buildOptionSwitch(
              title: 'Incluir números (0-9)',
              value: _includeNumbers,
              onChanged: (val) => setState(() => _includeNumbers = val),
            ),
            _buildOptionSwitch(
              title: 'Incluir símbolos (!@#\$...)',
              value: _includeSymbols,
              onChanged: (val) => setState(() => _includeSymbols = val),
            ),

            const SizedBox(height: 24),

            // Botão Gerar Senha
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _generatePassword,
                child: const Text('Gerar Senha'),
              ),
          ],
        ),
      ),
      // botão para Salvar
      floatingActionButton: FloatingActionButton(
        onPressed: _savePassword,
        tooltip: 'Salvar Senha',
        child: const Icon(Icons.save),
      ),
    );
  }

  // Widget auxiliar para o resultado
  Widget _buildPasswordResultWidget() {
    bool isGenerated = _generatedPassword != 'Senha não informada' && !_generatedPassword.contains('...');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _generatedPassword,
              style: TextStyle(
                fontSize: 18,
                fontFamily: isGenerated ? 'monospace' : null, // Fonte monoespaçada
                fontWeight: isGenerated ? FontWeight.bold : FontWeight.normal,
                color: isGenerated ? Colors.black : Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isGenerated)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _generatedPassword));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha copiada!')),
                );
              },
            ),
        ],
      ),
    );
  }

  // Widget auxiliar para os switches
  Widget _buildOptionSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}