# C22 — Guardião do Jardim: chefe em três fases

**Estado:** planejado; nenhum código C22 existe. **Base:** C21 aprovado. **Branch sugerida:** `dev/checkpoint-22-garden-guardian`.

## Objetivo

Evoluir o encontro obrigatório da quinta onda sem aumentar a quantidade de atores simultâneos nem multiplicar recompensas. O chefe é um único ator visual com três fases de puzzle encadeadas.

## Fases propostas

1. **Armadura:** puzzle 2×2, 4–6 movimentos legais. Quebra a proteção externa.
2. **Núcleo:** puzzle 3×3, 6–8 movimentos legais. Apresenta o padrão principal.
3. **Coração:** puzzle 3×3, 8–10 movimentos legais. Etapa final; somente aqui o chefe é derrotado.

Valores de profundidade são hipóteses e devem ser calibrados com C18. A dificuldade deve vir de leitura/decisão, não de exigir velocidade física impossível.

## Fluxo lógico

- `BossEncounter.start(boss_id, run_seed)` inicializa fase 1 com seed derivada de forma estável.
- Cada fase tem seu próprio puzzle, contador de movimentos e indicador visual.
- Ao confirmar `is_solved()`, travar input, animar transição e gerar a fase seguinte. Não pagar moeda, XP, Bestiário ou contrato por fases intermediárias.
- Na fase 3, resolver o puzzle chama `complete_boss(boss_id)` uma única vez.
- O diretor marca a elite final como concluída e só então aplica a recompensa final e o resultado de vitória existente.
- Se o timer/estabilidade encerrarem a run, registrar derrota sem pagar recompensa final do chefe.
- Pausa, modal e perda de foco não avançam a fase.

## Implementação por arquivo

- `scripts/c22/boss_encounter.gd`: máquina de estados `IDLE`, `ACTIVE`, `TRANSITION`, `DEFEATED`; métodos `start`, `current_phase`, `register_phase_solved`, `complete_boss`.
- `scripts/c22/boss_phase_definition.gd`: Resource/Dictionary validado com dimensão, profundidade, tempo visual e perfil de fase.
- `scripts/c22/guardian_visuals.gd`: modelo, barra de fase, animação de transição e feedback.
- `scripts/c22/special_director.gd`: substituir a ocorrência da elite final pelo encontro Guardião, mantendo a quota total e limite de quatro.
- `scripts/c22/game_stage.gd`: integrar o serviço e garantir que os pagamentos continuam no pipeline canônico.
- `tests/unit/test_c22_boss_encounter.gd` e `tests/integration/test_c22_boss_run.gd`.

## Testes e aceitação

- Resolver fases 1 e 2 não gera nenhuma transação nem registro de cubo concluído.
- Resolver fase 3 gera exatamente uma recompensa, uma descoberta apropriada e uma conclusão do chefe.
- Chamar conclusão duas vezes com o mesmo boss_id não duplica moedas/XP.
- Sair, pausar ou perder durante transição não pula fases nem paga prêmio.
- Quinta onda mantém limite de atores e janela de spawn do chefe.
- 100 seeds geram fases válidas; derrotas/vitórias e medalhas continuam coerentes.

**Fora do escopo:** chefes aleatórios em todas as ondas, múltiplos chefes simultâneos ou multiplayer.
