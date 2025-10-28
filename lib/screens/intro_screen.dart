import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkpoint6/core/auth_guard.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

// Classe interna para guardar o conteúdo de cada página
class _IntroPage {
  final String lottieAsset;
  final String title;
  final String subtitle;

  _IntroPage({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
  });
}

class _IntroScreenState extends State<IntroScreen> {
  // Lista de páginas da introdução [cite: 32]
  final List<_IntroPage> _pages = [
    _IntroPage(
      lottieAsset: 'assets/animations/intro_1.json', 
      title: 'Bem-vindo ao App',
      subtitle: 'Aprenda a usar o app passo a passo.',
    ),
    _IntroPage(
      lottieAsset: 'assets/animations/intro_2.json', 
      title: 'Funcionalidades',
      subtitle: 'Explore as diversas funcionalidades de segurança.',
    ),
    _IntroPage(
      lottieAsset: 'assets/animations/intro_3.json', 
      title: 'Vamos começar?',
      subtitle: 'Pronto para usar o seu app com segurança.',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Função chamada ao clicar em "Concluir"
  Future<void> _onFinish() async {
  final prefs = await SharedPreferences.getInstance();
  if (_dontShowAgain) {
    await prefs.setBool('intro_seen', true);
  }

  if (context.mounted) {
    // Navega para o AuthGuard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGuard()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // Verifica se está na última página
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. PageView com as páginas 
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPageContent(
                    lottieAsset: page.lottieAsset,
                    title: page.title,
                    subtitle: page.subtitle,
                  );
                },
              ),
            ),

            // 2. Checkbox (só aparece na última página) 
            if (isLastPage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _dontShowAgain,
                      onChanged: (bool? value) {
                        setState(() {
                          _dontShowAgain = value ?? false;
                        });
                      },
                    ),
                    const Text('Não mostrar essa introdução novamente.'),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),

            // 3. Botões de Navegação 
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão "Voltar"
                  // (só aparece se não for a primeira página)
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text('Voltar'),
                    )
                  else
                    const SizedBox(width: 50), // Espaço vazio para alinhar

                  // Botão "Avançar" ou "Concluir"
                  ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        _onFinish();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(isLastPage ? 'Concluir' : 'Avançar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir o conteúdo de cada página
  Widget _buildPageContent({
    required String lottieAsset,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottieAsset, height: 300),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}