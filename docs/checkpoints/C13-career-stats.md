# C13 — Painel de carreira e filtros do Histórico

**Branch:** `dev/checkpoint-13-career-stats` · **Base temporária:** `dev/checkpoint-12-results-medals` · **Godot:** 4.7.2 · **Integração bloqueada até C12 ser aprovado**.

## Objetivo

Dar sentido ao Salão de Medalhas sem aumentar a hub e sem inventar progresso permanente. A nova visão de carreira aparece **dentro do Histórico de Partidas no Bestiário**.

## Funcionalidades

- Indicadores calculados **somente sobre até 12 runs finais salvas pelo C12**: quantidade de partidas e vitórias, porcentagem de vitórias, maior série de vitórias, medalhas, cubos, moedas e Fever.
- Botões **TODAS / NORMAL / DIÁRIO** mudam tanto os indicadores quanto os cards em tempo real, sem nova navegação na hub.
- Estado vazio por filtro, inclusive se não há runs em um dos modos.
- Estatísticas estritamente **locais e derivadas**, sem segundo arquivo de save, recompensas ou alterações em moeda, XP, contratos, Fever e desafio diário.
- As medalhas e os registros antigos continuam válidos; o banco de histórico permanece versão 1. São dados *recentes*, não estatísticas vitalícias.

## Arquitetura

- `scripts/c13/career_stats.gd`: agregação pura, read-only e testável.
- `scripts/c13/hub_stage.gd`: herda do C12 e adiciona painel/filtros ao modal existente; combate continua na cena C12.
- `scenes/c13/hub_stage.tscn`: novo ponto de entrada. Main continua no C11; PR #13 continua em rascunho.
- O PR deste checkpoint deve apontar inicialmente para a branch C12. Depois da aprovação/merge do C12, pode ser atualizado para `main`.

## Testes exigidos

- Unitários de percentuais, séries, medalhas, agregados, modos e imutabilidade.
- Integração com três runs reais persistidas: alternância de filtros, botão do Bestiário, quatro ações da hub, arquivo de save idêntico após inspeção e reload.
- Cold start sem `.godot`, regressão C0–C12 e build Windows x86_64.

## Checklist manual

- [ ] Testar em 1280×720 e 1920×1080 a barra dos três filtros no Histórico.
- [ ] Alternar Normal e Diário; validar que os indicadores e os cards mudam juntos.
- [ ] Testar histórico vazio, só Normal, só Diário, mistura e 12 runs.
- [ ] Voltar ao Bestiário e ao menu principal sem perda de navegação.
- [ ] Resolver cubos e confirmar que não surgiram moedas extras.
- [ ] Fechar/reabrir o jogo e confirmar o histórico intacto.

**Gate:** CI e build Windows verdes, mais validação visual/jogável do usuário. Sem merge automático.
