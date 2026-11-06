# C23 — Sinergias de habilidades

**Estado:** planejado; nenhum código C23 existe. **Base:** C22 aprovado. **Branch sugerida:** `dev/checkpoint-23-skill-synergies`.

## Objetivo

Fazer escolhas de cartas C3 se combinarem sem criar um segundo sistema de progressão. Sinergias são temporárias, derivadas dos ranks atuais de uma run e não são salvas na carteira.

## Catálogo inicial proposto

| ID | Requisitos | Efeito inicial (hipótese) |
|---|---|---|
| `fluid_rhythm` | Pulso Ágil 2 + Dedo Certeiro 1 | reduz em 5% o cooldown após uma sequência de 3 soluções; duração curta |
| `golden_fever` | Bolsa Encantada 2 + Ritmo de Mestre 1 | +5 pontos percentuais no bônus de moedas durante Fever, respeitando cap global |
| `guardian_hand` | Luva Magnética 1 + Mão Paciente 2 | +2 de estabilidade ao fim de cada onda concluída, uma vez por onda |
| `deep_insight` | Olhar de Cubista 2 + Fôlego Extra 1 | reduz em 1 o próximo movimento exigido por reforçado, mínimo 2 |

Os números são hipóteses. C18 deve medir o impacto antes de fixá-los.

## Lógica

- `SynergyEngine.evaluate(ranks)` retorna lista de sinergias ativas e seus efeitos calculados.
- Recalcular apenas após `select_card` e em eventos de onda; não a cada frame.
- Cada sinergia tem ID estável, requisitos explícitos, texto de UI e efeito limitado.
- Efeitos aditivos/multiplicativos são acumulados em uma única camada e passam pelos caps de RunBuild/Wallet.
- Uma sinergia não pode conceder a mesma cura ou bônus duas vezes no mesmo evento.
- HUD mostra nome, requisito cumprido e descrição real; sem efeitos ocultos.

## Implementação por arquivo

- `scripts/c23/synergy_catalog.gd`: dados do catálogo e validação.
- `scripts/c23/synergy_engine.gd`: classe pura com `evaluate`, `effects_for`, `event_token`.
- `scripts/c23/run_build.gd`: extensão/adaptador do RunBuild mais recente; não duplicar o catálogo C3.
- `scripts/c23/game_stage.gd`: integrar recálculo e sinais da HUD.
- `scripts/c23/synergy_badge.gd`: componente visual reutilizando tema C5/C8.
- `tests/unit/test_c23_synergies.gd` e `tests/integration/test_c23_synergy_game.gd`.

## Testes e aceitação

- Todos os requisitos são testados em ranks abaixo, iguais e acima do limiar.
- Recalcular repetidamente não acumula efeitos nem cura duas vezes.
- Limites de cooldown, bônus de moedas e estabilidade continuam válidos.
- Oferta de cartas não inclui cartas maximizadas; C3 continua com oito cartas-base.
- UI explica cada sinergia ativa em 1280×720 e não cobre o campo.
- Métricas C18 demonstram que uma build sinérgica não torna a run trivial.

**Fora do escopo:** cartas permanentes, árvore de talentos, nova moeda ou bônus sem limite.
