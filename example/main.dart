import 'package:flutter/material.dart';

import 'package:tomza_kit/tomza_kit.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tomza_kit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TomzaColors.primary),
        textTheme: TomzaTypography.textTheme,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = InMemoryAuthService();
  final session = SessionManager();
  final printer = PrintManager();

  String status = 'No autenticado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo tomza_kit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Estado: $status'),
            const SizedBox(height: 12),
            TomzaButton(
              label: 'Login',
              onPressed: () async {
                final ok = await auth.signIn(
                  username: 'demo',
                  password: '1234',
                );
                if (ok) {
                  session.saveToken(
                    'token-demo',
                    ttl: const Duration(minutes: 15),
                  );
                }
                setState(() => status = ok ? 'Autenticado' : 'Falló login');
              },
            ),
            TomzaButton(
              label: 'Logout',
              onPressed: () {
                auth.signOut();
                session.clear();
                setState(() => status = 'No autenticado');
              },
            ),
            const Divider(),
            PrintButton(
              onPressed: () async {
                await printer.printItems([
                  PrintText('Hola Mundo'),
                  PrintQr('QRDATA'),
                ]);
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => const TomzaDialog(
                      title: 'Impresión',
                      message: 'Simulada',
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
