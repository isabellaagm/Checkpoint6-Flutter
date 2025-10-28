// lib/widgets/password_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordListItem extends StatefulWidget {
  final String label;
  final String password;
  final String documentId;
  final Function(String) onDelete; // Função para deletar

  const PasswordListItem({
    super.key,
    required this.label,
    required this.password,
    required this.documentId,
    required this.onDelete,
  });

  @override
  State<PasswordListItem> createState() => _PasswordListItemState();
}

class _PasswordListItemState extends State<PasswordListItem> {
  bool _isObscure = true;

  // Método para copiar
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha copiada para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ListTile permite 'copiar' ao tocar
    return ListTile(
      onTap: _copyToClipboard,
      title: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        _isObscure ? '••••••••' : widget.password,
      ),
      // Ícone para mostrar/ocultar
      leading: IconButton(
        icon: Icon(
          _isObscure ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      ),
      // Ícone para deletar
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          // Chama a função de deletar que está na HomeScreen
          widget.onDelete(widget.documentId);
        },
      ),
    );
  }
}