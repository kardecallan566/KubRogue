# C14 — Conquistas permanentes e Maestrias do Jardim

**Branch:** `dev/checkpoint-14-garden-achievements` · **Base:** C13 integrado à `main` · **Godot:** 4.7.2 Compatibility · **Status:** validação pendente.

## Por que este checkpoint

O PR alternativo #14 trazia medalhas permanentes, mas alterava os mesmos scripts do C12 (resultado de partidas). Este C14 reaproveita a lógica de conquistas sem substituir o C12/C13 já aprovados: uma camada de UI sobre o Bestiário e uma camada leve de notificação sobre a arena.

## Entregas

- Doze conquistas retroativas derivadas do diário C8 (contagem permanente por espécie) e recorde de combo do C4.
- Maestrias por espécie: Bronze 5, Prata 20 e Ouro 50 soluções. Esconde progressão para espécies ainda não descobertas.
- Bestiário em abas **CUBOS / MEDALHAS / CONTRATOS**, com botão de Histórico sempre acessível.
- Salão de Medalhas, filtros e estatísticas recentes do C13 continuam integralmente funcionais.
- Aviso temporário no HUD quando a gravação do Bestiário conclui um desbloqueio novo. Reiniciar a run atualiza o snapshot e não repete avisos de conquistas antigas.
- Nenhum arquivo adicional de save, migração, pagamento, alteração da seed diária, manipulação do XP, Fever ou regras de jogo.
- Cenas C12/C13 continuam disponíveis para regressão; cena inicial C14 herda o funcionamento do C13.

## Qualidade

Unitário de retroatividade, 12 conquistas, 5/20/50, combo recorde e deduplicação; integração com as três abas e histórico C13; teste cold start; regressão C0–C14 e exportação Windows.

## Roteiro manual

- [ ] Abrir em 1280×720 e 1920×1080.
- [ ] Bestiário: alternar Cubos, Medalhas e Contratos.
- [ ] Bestiário → Histórico: verificar as medalhas de partida e filtros C13.
- [ ] Em save antigo, confirmar conquistas retroativas sem apagar moedas.
- [ ] Fazer uma nova solução; verificar o aviso de conquista e que não há pagamento extra.
- [ ] Testar maestrias por 5, 20 e 50 resoluções.
- [ ] Validar na arena Rotas, Oficina, contratos, Fever e cubos 2×2 a 5×5.
- [ ] Reiniciar o jogo; conquista existente não gera novo aviso.

**Gate:** aprovação do CI, build Windows, testes visuais/jogáveis. Não integrar à `main` sem avaliação.
