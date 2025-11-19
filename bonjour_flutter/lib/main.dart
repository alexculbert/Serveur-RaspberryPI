import 'package:flutter/material.dart';

const conversationLog = '''
Utilisateur : quelle est le niveau d approv… ?
Assistant  : Mode never (lecture seule).
Utilisateur : fait le / supprime never ?
Assistant  : Impossible jusqu’à ce que sandbox passe en danger-full-access.
[…]
Utilisateur : je veux faire un serveur pour n8n.
Assistant  : Ajout docker-compose, README, script, etc.
Utilisateur : déplace tout dans serveur.
Assistant  : Config migrée, testée avec docker compose.
Utilisateur : package Flutter/Dart pour UI ?
Assistant  : Installation Flutter ARM64, création app web Bonjour.
Utilisateur : ouvre l’appli / ajoute conversation dans le site.
Assistant  : (vous y êtes !)
''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bonjour',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            color: Colors.white70,
          ),
        ),
      ),
      home: const BonjourScreen(),
    );
  }
}

class BonjourScreen extends StatelessWidget {
  const BonjourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 30,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bonjour !',
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ravi de te voir sur ton futur serveur personnel.\n'
                  'Ce message vient d’une appli Flutter Web prête à grandir.',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF203A43),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.waving_hand_outlined),
                      label: const Text('Dire bonjour'),
                      onPressed: () {},
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.terminal_rounded),
                      label: const Text('Voir la conversation'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ConversationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation du terminal'),
        backgroundColor: const Color(0xFF203A43),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF1e3c72),
              Color(0xFF2a5298),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.black.withOpacity(0.65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: SelectableText(
                  conversationLog,
                  style: const TextStyle(
                    fontFamily: 'FiraCode',
                    fontSize: 16,
                    color: Color(0xFFe0e0e0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
