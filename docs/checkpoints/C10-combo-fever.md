# C10 — Combo Fever: feedback arcade e domínio de sequência

**Branch:** `dev/checkpoint-10-combo-fever` · **Godot:** 4.7.2 Compatibility · **Estado:** testes e validação pelo jogador antes de merge.

## Motivação

O C9 foi aprovado e integrado na `main` no PR #10. O próximo passo transforma o combo já existente num momento memorável, premiando **ritmo de solução real dos cubos** sem criar mais botões ou monetização.

## Regras precisas

- Cada cubo resolvido validamente pelo diretor aumenta a sequência enquanto o intervalo entre soluções não passa de **12 segundos de gameplay**.
- No **4.º** cubo de uma sequência começa **FEVER por 9 segundos de gameplay**, com +20% moedas **no próprio pagamento daquele cubo** e nos seguintes enquanto FEVER estiver ativo. No **8.º** e em outros múltiplos de 4, se FEVER ainda estiver ativo, renova +3 segundos, até 12 segundos restantes.
- Resolver durante FEVER devolve **1 segundo** ao tempo restante, no máximo **+6 segundos por onda**. Tempo é limitado ao tempo inicial da onda +6s, sem acumular além disso.
- Todas as bonificações de moedas (habilidades, Workshop, Rotas e FEVER) mantêm a proteção do multiplicador total **até +150%** já existente. Bonus é pago somente depois de resolver um cubo real, pelo `credit_cube` idempotente de C4. Contratos continuam incorporados no mesmo crédito. Não existe pagamento secundário.
- O cronômetro FEVER **não avança** em pausas, telas de XP, resumo, Oficina e escolha de Rotas. O estado de FEVER é apenas memória, reinicia a cada onda e a cada nova run, sem afetar coleção, recordes ou saves.
- No HUD, abaixo das barras de onda/tempo, surge um cartão com barra **0–4** de combo. Quando FEVER começa, muda para dourado, mostra **COMBO xN**, tempo restante e **+20%**. Há som e efeitos de moedas originais (respeitando configurações de partículas e shake).
- Mesmo sem habilidades de XP, o jogador alcança FEVER resolvendo cubos rapidamente; o efeito combina com as habilidades da categoria Combo e o bônus das Rotas sem ocultar a mão 2D.

## Arquitetura

`scripts/c10/fever_engine.gd`: serviço `RefCounted` sem I/O, RNG nem temporizador do sistema. A arena C10 usa `fever.tick(delta)` **somente enquanto está em combate ativo**; `fever.on_solve(cube_id)` é chamado após confirmar solução do cubo, garantindo um aumento de combo por ID. `scripts/c10/game_stage.gd` adapta HUD, efeitos e bônus. As cenas C0–C9 permanecem disponíveis.

## Plano de teste Windows

- [ ] `godot .` abre a hub C10 sem erro de preload numa cópia limpa do repositório.
- [ ] Uma sequência de 1–3 cubos preenche a barra verde, mas não aumenta as moedas.
- [ ] Quarto cubo resolvido em até 12s do anterior ativa FEVER dourado e 20% extra; os quatro Aprendizes mais um contrato totalizam **62 moedas** (40+2+20), sem skills/rotas de bônus.
- [ ] Verificar que o cartão FEVER troca de 0–4 para contagem de 9s, com animação leve e som.
- [ ] Passar 12s sem resolver outro cubo cancela sequência; FEVER expira normalmente.
- [ ] Durante pausa e cartas de nível, o relógio não avança. Oficina e Rotas também não descontam FEVER.
- [ ] Resolver vários cubos durante FEVER recupera no máximo +6s por onda, sem ultrapassar o tempo máximo previsto.
- [ ] O C9 continua oferecendo duas Rotas, com a Oficina do C8.2 acessível; o chefe 3×3 permanece obrigatório na 5.ª onda.
- [ ] Reiniciar reseta sequência/FEVER, mas preserva recordes, moedas e Bestiário.
- [ ] 1280×720 e 1920×1080: painel continua legível e não cobre a arena/cursor.
- [ ] Testes C0–C10 e Windows ZIP no Actions aprovados; validar ritmo de áudio e duração em uma partida real.

**Fora do C10:** leaderboard online, monetização, novos tipos de cubo e efeitos permanentes que provoquem desbalanceamento.
