# 🔐 Gerador de Senhas (Checkpoint 6)

Um aplicativo de gerenciador de senhas completo construído com Flutter e Firebase.

Este projeto permite aos usuários se autenticarem, gerar senhas seguras através de uma API externa e salvar/recuperar suas senhas de forma segura no Cloud Firestore.

## ✨ Funcionalidades

* **Autenticação de Usuários:** Login e Registro usando Firebase Authentication (Email/Senha).

* **Geração de Senhas:** Conecta-se a uma API (`safekey-api`) via POST para gerar senhas com base em critérios do usuário (tamanho, maiúsculas, números, símbolos).

* **Segurança no Firestore:** Salva e lê senhas usando Regras de Segurança (Security Rules) e Índices (Indexes) do Firestore, garantindo que um usuário só possa ver suas próprias senhas.

* **Interface Reativa:** Uso de `StreamBuilder` para atualizar a lista de senhas em tempo real.

* **Tema Personalizado:** Interface estilizada (atualmente em tons de Roxo 💜).

## 🚀 Como Rodar Localmente

Este projeto usa Firebase, então alguns passos são necessários para rodá-lo:

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/isabellaagm/Checkpoint6-Flutter.git](https://github.com/isabellaagm/Checkpoint6-Flutter.git)
   cd Checkpoint6-Flutter
