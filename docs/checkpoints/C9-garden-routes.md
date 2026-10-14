# Checkpoint C9 — Rotas do Jardim

**Branch:** `dev/checkpoint-09-garden-routes`. **Godot:** 4.7.2 Compatibility. **PR:** rascunho, sem merge até validação do jogador.

## Objetivo

Criar decisões roguelite interessantes e fáceis de ler entre as ondas, sem acrescentar botões na hub, mexer no sistema de cartas XP ou exigir outro save. Na tela de resumo das **ondas 1–4**, o jogador encontra **duas Rotas do Jardim**, em cartas com vantagem e risco visíveis. Pode escolher uma opção ou seguir sem evento. A decisão só vale na onda seguinte.

## Rotas possíveis

| Rota | Benefício | Risco |
|---|---|---|
| Corrida Relâmpago | +25% moedas por cubo na próxima onda | -10 segundos para resolver os cubos |
| Refúgio das Folhas | Recupera 18 pontos de estabilidade, até o limite | -8 segundos na próxima onda |
| Trilha Dourada | Um Aprendiz da próxima onda vira Dourado; pagamento maior, mesmo total de alvos | O Dourado exige mais giros |
| Torre do Tempo | +12 segundos na próxima onda | -12 estabilidade; nunca abaixo de 1 |

As ofertas são **duas rotas distintas**, sorteadas deterministamente com a seed e o índice da onda terminada (mesma data UTC, mesma oferta diária). Escolhas diferentes alteram o próximo conteúdo. O modo Normal mantém seeds variáveis. Nenhum evento dá moedas grátis: o bônus de moedas da Corrida só é calculado nos pagamentos de cubos resolvidos com a regra idempotente do C4. As moedas continuam disponíveis na Oficina do C8.2.

## Fluxo

1. Conclua uma onda (exceto a quinta).
2. O resumo mostra **ESCOLHER ROTA** e também o botão **OFICINA DO CUBISTA** do C8.2.
3. Continue: se ainda não escolheu, a seleção abre automaticamente; escolha uma carta ou **SEGUIR SEM EVENTO**.
4. Volte ao resumo, faça compras opcionais na Oficina e avance. Cartas de XP continuam oferecendo a próxima habilidade e não anulam a rota.
5. Na onda seguinte, a HUD mostra o nome da rota ativa; seus efeitos não persistem na onda posterior. A elite 3×3 no quinto estágio permanece obrigatória.

## Segurança do progresso e limites

As rotas **não escrevem arquivos**; são temporárias à partida. O livro, os contratos e a carteira C8 continuam no mesmo formato. Troca de rota e efeitos duplicados são bloqueados; comprar upgrade no Workshop segue débito atômico. Nenhuma rota aumenta o número total de cubos. A Trilha Dourada troca o primeiro Aprendiz por Dourado em uma onda já existente. Após reiniciar a run, as escolhas resetam e o mesmo desafio diário gera as mesmas ofertas.

## Checklist Windows

- [ ] `godot .` abre a nova hub C9 sem erros de scripts nem imagens.
- [ ] Primeiro resumo oferece duas cartas visuais com benefício/risco separados e botão de skip.
- [ ] Ainda é possível visitar a Oficina, comprar e voltar ao resumo.
- [ ] Após a escolha a rota não pode ser trocada, mesmo reabrindo telas.
- [ ] Corrida dá +25% moedas só na onda seguinte, com -10 s; prêmio nunca é pago duas vezes.
- [ ] Refúgio recupera até o máximo e reduz 8 s.
- [ ] Trilha troca somente um Aprendiz por Dourado, sem afetar o 3×3 obrigatório.
- [ ] Torre aumenta 12 s e desconta estabilidade sem matar instantaneamente o jogador.
- [ ] Ofertas do Desafio Diário são iguais ao reiniciar na mesma data UTC.
- [ ] Reabrir o jogo continua preservando carteira/Bestiário/recordes, sem precisar salvar rotas.
- [ ] 1280×720 e 1920×1080 legíveis; mão 2D e ícones não interceptam os controles.
- [ ] Testes C0–C9 e build Windows completos; jogar ao menos duas runs manualmente.

**Fora do C9:** biomas novos, multiplayer, eventos permanentes ou modificações nas probabilidades de desbloquear habilidades.
