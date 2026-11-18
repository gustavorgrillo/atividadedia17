import 'package:flutter/material.dart';

import '../api.dart';
import '../modelos.dart';
import '../telas/comentarios_tela.dart';

class PostagemCard extends StatefulWidget {
  const PostagemCard({
    super.key,
    required this.usuario,
    required this.postagem,
    this.aoMudarAmizade,
  });

  final Usuario usuario;
  final Postagem postagem;
  final VoidCallback? aoMudarAmizade;

  @override
  State<PostagemCard> createState() => _PostagemCardState();
}

class _PostagemCardState extends State<PostagemCard> {
  bool _ocupado = false;

  Postagem get p => widget.postagem;

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _curtir() async {
    try {
      final (curti, total) = await Api.curtir(widget.usuario.id, p.id);
      setState(() {
        p.curti = curti;
        p.curtidas = total;
      });
    } on ApiException catch (e) {
      _aviso(e.mensagem);
    }
  }

  Future<void> _solicitarAmizade() async {
    setState(() => _ocupado = true);
    try {
      final status = await Api.solicitarAmizade(widget.usuario.id, p.autorId);
      setState(() => p.amizade = status);
      _aviso(status == 'amigos' ? 'Agora vocês são amigos!' : 'Solicitação enviada para ${p.autorNome}');
      widget.aoMudarAmizade?.call();
    } on ApiException catch (e) {
      _aviso(e.mensagem);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirComentarios() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComentariosTela(usuario: widget.usuario, postagem: p)),
    );
    if (mounted) setState(() {});
  }

  Widget? _botaoAmizade() {
    switch (p.amizade) {
      case 'nenhuma':
        return TextButton.icon(
          onPressed: _ocupado ? null : _solicitarAmizade,
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Adicionar'),
        );
      case 'recebida':
        return TextButton.icon(
          onPressed: _ocupado ? null : _solicitarAmizade,
          icon: const Icon(Icons.how_to_reg, size: 18),
          label: const Text('Aceitar'),
        );
      case 'enviada':
        return const Chip(label: Text('Pendente'), visualDensity: VisualDensity.compact);
      case 'amigos':
        return const Chip(
          avatar: Icon(Icons.check, size: 16),
          label: Text('Amigos'),
          visualDensity: VisualDensity.compact,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final botao = _botaoAmizade();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: cores.primaryContainer,
            child: Text(p.autorNome.isEmpty ? '?' : p.autorNome[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.autorNome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text('  · ${tempoRelativo(p.criadoEm)}', style: TextStyle(color: cores.onSurfaceVariant)),
                    const Spacer(),
                    if (botao != null) botao,
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.texto, style: const TextStyle(fontSize: 15)),
                if (p.foto != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: Image.network(
                        Api.urlFoto(p.foto!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: cores.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ],
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _abrirComentarios,
                      icon: Icon(
                        p.podeComentar ? Icons.chat_bubble_outline : Icons.lock_outline,
                        size: 18,
                        color: cores.onSurfaceVariant,
                      ),
                      label: Text('${p.comentarios}', style: TextStyle(color: cores.onSurfaceVariant)),
                    ),
                    TextButton.icon(
                      onPressed: _curtir,
                      icon: Icon(
                        p.curti ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: p.curti ? Colors.pink : cores.onSurfaceVariant,
                      ),
                      label: Text(
                        '${p.curtidas}',
                        style: TextStyle(color: p.curti ? Colors.pink : cores.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
