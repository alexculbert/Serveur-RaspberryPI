import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _conversationLog = '''
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

const _defaultApiBaseUrl =
    String.fromEnvironment('CODEX_API_URL', defaultValue: 'http://localhost:8080');

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
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Parler à Codex'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CodexConsolePage(),
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
                  _conversationLog,
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

class CodexConsolePage extends StatefulWidget {
  const CodexConsolePage({super.key});

  @override
  State<CodexConsolePage> createState() => _CodexConsolePageState();
}

class _CodexConsolePageState extends State<CodexConsolePage> {
  final TextEditingController _promptController = TextEditingController();
  bool _isSending = false;
  String? _stdoutResult;
  String? _stderrResult;
  String? _error;

  Uri get _codexUri => Uri.parse('$_defaultApiBaseUrl/codex/exec');

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _error = "Écris d'abord une instruction pour Codex.";
      });
      return;
    }
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      final response = await http.post(
        _codexUri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _stdoutResult = decoded['stdout'] as String? ?? '';
          _stderrResult = decoded['stderr'] as String? ?? '';
          _error = null;
        });
      } else {
        setState(() {
          _error =
              'Erreur ${response.statusCode} : ${response.body.isEmpty ? 'Réponse vide' : response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de contacter Codex (${e.toString()})';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Codex'),
        backgroundColor: const Color(0xFF0F2027),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Envoie une instruction à Codex (API locale par défaut sur http://localhost:8080).',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _promptController,
                        minLines: 3,
                        maxLines: 6,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          hintText: 'Ex: Ajoute une page Flutter pour consulter Codex.',
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isSending ? null : _sendPrompt,
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(_isSending ? 'Envoi...' : 'Envoyer'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_stdoutResult != null) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sortie',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            _stdoutResult!,
                            style: const TextStyle(
                              fontFamily: 'FiraCode',
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      if ((_stderrResult != null && _stderrResult!.trim().isNotEmpty)) ...[
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Erreurs',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF45171D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            _stderrResult!,
                            style: const TextStyle(
                              fontFamily: 'FiraCode',
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
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
