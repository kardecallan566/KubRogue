# C8 — Bestiário do Jardim e Contratos de Partida

**Branch:** `dev/checkpoint-08-bestiary-contracts`. **Godot:** 4.7.2, renderer Compatibility. **Estado:** validação antes do merge. **Base:** C7 aprovado, PR #8 integrado na main.

## O que o jogador vê

A hub recebe **BESTIÁRIO DO JARDIM**, acessível sem conexão. Ao abrir, mostra sete entradas: Aprendiz 2×2, Reforçado 2×2, Dourado 2×2, Blindado 2×2, Elite 3×3, Mestre 4×4 e Titã 5×5. Cada cubo resolvido e pago desbloqueia seus detalhes e aumenta o contador acumulado de resoluções. A tela usa os cartões, painéis e paleta arcade do C5; espécies desconhecidas aparecem bloqueadas.

Há também **três contratos disponíveis em toda partida**. Eles não gastam moeda, não substituem cartas e não alteram as cinco ondas:
- **Primeiros passos:** resolver 4 cubos; **+20 moedas** na quarta solução.
- **Caçador de raros:** resolver 2 cubos especiais (Dourado, Blindado, Elite, Mestre ou Titã); **+35 moedas** na segunda solução.
- **Mestre das camadas:** resolver 1 cubo 4×4 ou 5×5; **+60 moedas** na primeira solução.

O painel da partida exibe progresso e número de contratos completos. Cada bônus é incorporado na **mesma transação C4 `credit_cube`** que paga o cubo que completou o contrato, impedindo cobrança ou crédito independentes. Máximo possível **+115 moedas por run**, sem aumentar o XP base dos cubos. Em uma nova partida os contratos reiniciam.

## Persistência e segurança

A coleção é armazenada em `user://kubrogue_journal_v1.json` (adaptador `SaveStore`, arquivo temporário e backup) e não interfere com `kubrogue_progress_v1.json` nem com `kubrogue_daily_v1.json`. Contadores e IDs de evento são validados, e os últimos 512 pagamentos registrados impedem descoberta duplicada após reinício. Se a escrita do bestiário falhar, o dinheiro continua salvo pelo C4 e o registro permanece pendente **em memória** para nova tentativa na sessão; ao fechar o jogo antes de salvar, uma observação pendente pode ser perdida, sem perda de moedas. Não existe servidor, conta, leaderboard ou coleta de dados.

## Checklist do Windows

- [ ] `godot .` a partir de um clone sem cache `.godot`; sem erro de preload PNG ou class_name.
- [ ] Hub 720p/1080p com BESTIÁRIO visível, sem cortes ou botões sobrepostos.
- [ ] Bestiário inicialmente tem 7 cartões bloqueados; uma espécie resolvida desbloqueia o cartão correspondente.
- [ ] Reabrir o jogo preserva as descobertas e quantidades.
- [ ] Quatro Aprendizes 2×2 pagam 40 moedas base + 20 do contrato, sem segunda transação.
- [ ] Duas espécies especiais resolvidas dão 35 moedas extras na segunda.
- [ ] Resolver um 4×4 ou 5×5 dá +60 moedas extras na primeira vez por run, além do próprio pagamento.
- [ ] Reiniciar partida permite cumprir contratos outra vez, sem apagar a coleção permanente.
- [ ] Falhar ao salvar dinheiro mantém recuperação com TENTAR SALVAR; bônus não são pagos duas vezes.
- [ ] Permanecem os 2×2, 3×3, 4×4, 5×5, cinco ondas, Boss, desafios diários, habilidades/reroll, som e cursor 2D.
- [ ] CI C0–C8 e build Windows ZIP aprovados. Testar desempenho no Windows antes do merge.

**Fora do C8:** colecionáveis compráveis, conquistas Steam, placar online, monetização e alterações ao formato dos saves anteriores.

## C8.1 — Menu e HUD redesenhados após avaliação visual

Após capturas reais do Godot, o usuário aprovou a nova direção: **menos botões**, **apenas habilidades de partida como upgrades acessíveis**, **HUD iconográfica** e **cartas ilustradas**.

- Hub: somente **JOGAR / BESTIÁRIO / CONFIGURAÇÕES / SAIR**. A escolha entre Normal e Desafio Diário agora fica no modal JOGAR; a ajuda Como Jogar está dentro de Configurações e continua abrindo automaticamente para o primeiro jogador.
- Loja de melhorias: removida da navegação e das funções invocáveis do C8. **Os bônus permanentes comprados em versões anteriores continuam sendo respeitados**, sem perda de moeda/salvamento; não há novas compras no C8. Para novos jogadores, a evolução ocorre com as cartas selecionadas por XP dentro da partida.
- Oito ícones originais: `scripts/c8/skill_icon.gd`, desenhados em vetor via `CanvasItem` (sem arquivos PNG nem importação). Ícones diferentes para Pulso ágil, Dedo certeiro, Luva magnética, Bolsa encantada, Ritmo de mestre, Fôlego extra, Olhar de cubista e Mão paciente.
- Na HUD: grade compacta de habilidades ativas, número do nível por símbolo e um **i** visível. Mouse hover tem tooltip nativo (nome/nível/valor/descrição); ao clicar, a descrição aparece na própria HUD; clicar novamente recolhe. A frase usada é exatamente a descrição curta da carta.
- Cartas: `scripts/c8/skill_card.gd` tem ícone grande, nome, raridade/categoria, transição de nível, bônus e descrição; substitui apenas a UI do C8, **sem modificar as cartas originais de checkpoints C0–C7**.
- HUD: agora há agrupamentos de progresso, economia, contratos, poderes e ações; menos texto corrido na linha de combo; moldura verde e realces discretos de uma identidade de puzzle/arena.
- O C8 ainda usa cinco ondas, bestiário, contratos, XP, reroll, mão 2D, áudio e o 2×2/3×3/4×4/5×5 atuais. Não há mudança em arquivos de save.

**Validação adicional:** abrir menu em 1280×720 e 1920×1080, navegar Jogar→Normal/Diário, Configurações→Como Jogar, fechar modal, obter uma habilidade na partida, conferir ícone grande nas cartas, nível no badge, hover/click para descrição, botão de reroll e reset completo dos ícones ao reiniciar. `tests/integration/test_c8_ui.gd` cobre o fluxo além dos testes C0–C8 anteriores.

## C8.2 — Revisão visual da seleção de desafio e Bestiário + Oficina entre ondas

Após novo teste no Windows, o modal JOGAR tinha espaço vazio excessivo e o Bestiário era uma lista estreita com status cortado. A UX C8.2 altera somente cenas C8:

- **Escolha do modo:** modal horizontal compacto e adaptado a 1280×720, dois cards grandes (Normal e Desafio do Dia) com símbolo, título, benefício e botão Jogar; Voltar embaixo. Tutorial continua no primeiro acesso.
- **Bestiário:** galeria rolável em duas colunas, modal largo, sete cards com miniaturas isométricas próprias desenhadas em `scripts/c8/species_preview.gd`; cada card separa nome, raridade, dimensão, moedas, descrição e resoluções sem status excedendo a largura. Contratos aparecem em cards no mesmo fluxo.
- **Oficina do Cubista:** no resumo **entre ondas**, botão próprio abre oficina com 4 melhorias temporárias compradas apenas com moedas **ganhas na run atual**, limitadas também ao saldo persistido: `Relógio Extra` +10 segundos nas próximas ondas (30/60), `Coração do Jardim` +12 de estabilidade imediata (25/50/75), `Cubo da Fortuna` +10% moedas por cubo (45/90), `Mão Veloz` -6% intervalo de giro (40/80). Ofertas mostram nível atual, custo e saldo disponível. Loja não aparece durante o combate ou no fim da partida.
- **Economia transacional:** pagamento usa `KubeSession.spend_coins(amount)`, que primeiro grava a redução de moedas via `SaveStore`, só depois ativa o upgrade. A run usa `workshop.spent` para impedir gastar saldo de outras runs como se fosse dinheiro novo. Compras não são reembolsadas ao recomeçar; melhorias temporárias não sobrevivem ao fechamento. Dados de C4/C5/C6/C7 permanecem válidos.
- As habilidades obtidas com XP continuam sendo escolhidas nas cartas iconográficas, independentes dos upgrades da Oficina. O jogador pode visitar a Oficina durante a pausa entre ondas e voltar ao resumo para selecionar a próxima etapa.

**Testes:** `tests/unit/test_c8_workshop.gd` verifica saldo, custo, máximos, débito salvo e reinício; `tests/integration/test_c8_ux.gd` verifica os dois cards, a galeria, bloqueio da oficina durante combate, compra, bônus real no cronômetro e reinício. CI C0–C8 continua necessário; antes do merge, conferir também a exportação Windows no próprio computador.
