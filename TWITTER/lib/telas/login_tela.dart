import 'package:flutter/material.dart';

import '../api.dart';
import '../sessao.dart';
import 'home_tela.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _cadastro = false;
  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final usuario = _cadastro
          ? await Api.cadastrar(_nome.text.trim(), _email.text.trim(), _senha.text)
          : await Api.login(_email.text.trim(), _senha.text);
      await Sessao.salvar(usuario);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeTela(usuario: usuario)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.flutter_dash, size: 72, color: cores.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Twitter Tavin',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cadastro ? 'Crie sua conta' : 'Entre na sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cores.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  if (_cadastro) ...[
                    TextFormField(
                      controller: _nome,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    obscureText: _ocultarSenha,
                    onFieldSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarSenha ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 4) ? 'Mínimo de 4 caracteres' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _carregando ? null : _enviar,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _carregando
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_cadastro ? 'Cadastrar' : 'Entrar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _carregando ? null : () => setState(() => _cadastro = !_cadastro),
                    child: Text(_cadastro ? 'Já tenho conta. Entrar' : 'Não tem conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
