# C18 — Métricas locais de playtest

**Estado:** planejado; nenhum código C18 existe. **Base:** C17 aprovado. **Branch sugerida:** `dev/checkpoint-18-playtest-metrics`.

## Objetivo e privacidade

Medir o ritmo real das partidas para orientar balanceamento sem depender de memória ou palpites. A coleta é **local, opt-in e desativada por padrão**. Não enviar dados pela rede, não criar conta, não coletar nome, caminho de usuário, IP, hardware ID ou conteúdo pessoal.

## Dados permitidos

Por run: ID local aleatório/serial, modo, seed, duração, onda alcançada, estabilidade final, cubos spawnados/resolvidos/expirados por espécie, tempo aproximado até resolver por espécie, cartas escolhidas, Fever ativado e resultado. Opcionalmente registrar buckets de frame-time (não dados contínuos de máquina). Não guardar input bruto nem sequência completa de mouse.

## Fluxo lógico

1. Ao iniciar run, `RunMetricsRecorder.begin_run(context)` cria buffer em memória.
2. O diretor emite eventos após transições confirmadas: `cube_spawned`, `cube_solved`, `cube_expired`, `wave_finished`, `card_selected`, `fever_started`.
3. O recorder valida IDs e agrega contadores; nunca concede recompensa nem interfere no gameplay.
4. Ao terminar, `finish_run(result)` normaliza e grava somente se o jogador ativou métricas.
5. Manter no máximo 100 runs e um limite de tamanho de arquivo. Se a gravação falhar, gameplay continua normalmente e a falha fica visível na tela de exportação.
6. Um painel em Configurações mostra consentimento, quantidade de runs e botão Exportar JSON. O jogador escolhe o destino; nada é enviado automaticamente.

## Implementação por arquivo

- `scripts/c18/run_metrics_recorder.gd`: buffer e agregação; funções `begin_run`, `record_event`, `finish_run`, `snapshot`, `clear_local_data`.
- `scripts/c18/metrics_store.gd`: persistência usando SaveStore; versão, retenção 100, limite sugerido 512 KiB.
- `scripts/c18/metrics_exporter.gd`: serialização e exportação manual, sem rede.
- `scripts/c18/hub_stage.gd` e/ou componente de Configurações: consentimento e exportação.
- `scripts/c18/game_stage.gd`: conectar sinais do diretor ao recorder; não duplicar regras de C16.
- `tests/unit/test_c18_metrics.gd`: agregação, limites, IDs duplicados e serialização.
- `tests/integration/test_c18_opt_in.gd`: coleta desligada, ligada, reinício e exportação.

## Contratos de código

- `record_event(event_name: String, event_id: int, payload: Dictionary) -> void`.
- Whitelist de eventos e campos; rejeitar strings enormes, números negativos e espécies desconhecidas.
- `finish_run(result: Dictionary) -> bool` persiste um resumo; mesmo run_id não pode ser gravado duas vezes.
- Arquivo sugerido: `user://kubrogue_playtest_metrics_v1.json`. Não reutilizar o save de carreira nem o arquivo semanal.
- O sistema não pode chamar KubeSession para creditar moeda ou KubeHistory para registrar resultados; apenas observa eventos já confirmados.

## Testes e aceitação

- Com opt-in desligado, nenhuma métrica é persistida.
- Com opt-in ligado, uma run completa gera um único resumo coerente.
- Uma segunda chamada de `finish_run` para o mesmo ID não duplica.
- Arquivo inválido ou versão futura é preservado; limite de retenção funciona.
- Exportação é legível e não contém PII.
- Jogar 20 runs com métricas ligadas não altera FPS de forma perceptível nem muda resultados, moedas, XP ou saves de campanha.

**Fora do escopo:** analytics online, telemetria externa, leaderboard ou coleta silenciosa.
