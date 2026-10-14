# KubRogue

**KubRogue** é um jogo single-player de ação roguelite arcade, em um campo gramado aberto em visão superior 2.5D com cubos 3D manipuláveis. A mão do jogador é controlada pelo mouse e "resolve" cubos coloridos por rotações válidas de suas camadas. Cada cubo completado concede moedas e experiência, enquanto ondas mais exigentes introduzem cubos maiores, variantes, escolhas de melhorias e decisões de risco.

> **Estado do desenvolvimento:** C0–C4 integrados à `main`. O **C5** está na branch `dev/checkpoint-05-polish-windows`: efeitos sonoros e música originais gerados no Godot, interface revisada, efeitos configuráveis, otimização do cenário e preset de exportação para Windows. **Ainda requer validação visual e build Windows real antes de considerar o MVP distribuível.**

## Conceito em uma frase

**Mova a mão, encaixe as cores, resolva cubos, ganhe moedas e construa uma combinação de poderes capaz de vencer cinco ondas de desafios.**

## Decisões fundamentais

- **Referência de sensação:** ação com mouse, ondas, upgrades e partidas repetíveis inspiradas por [King of Pickaxe](https://store.steampowered.com/app/4264240/King_of_Pickaxe/). Identidade, mecânicas de resolução, arte, interface, efeitos, nomes e conteúdo devem ser originais.
- **Resolução arcade, não simulador de speedcubing:** um comando da mão aplica um movimento legal que aproxima o cubo do estado resolvido. No MVP, o jogo utiliza a inversão de um embaralhamento controlado — não promete um solucionador geral nem exige que o usuário conheça algoritmos de cubo mágico.
- **Mapa e visual:** gramado pastel contínuo, câmera quase superior ortográfica e fixa no MVP; cubos 3D e cursor de mão 2D destacados. Sem palco circular ou paredes visíveis.
- **Loop:** solucionar cubos -> ganhar moedas e XP -> escolher cartas durante a run em pausa segura -> superar ondas -> comprar melhorias permanentes -> recomeçar.
- **Primeiro destino:** PC Windows, mouse e teclado, Godot 4.x + GDScript, com meta de 60 FPS na configuração-alvo de desenvolvimento. Outras plataformas vêm depois.
- **MVP:** 5 ondas, cubo 2x2 comum, 2x2 reforçado e elite 3x3; mão, moedas, XP, 8 habilidades, 3 melhorias permanentes, interface, áudio, salvamento local e fluxo completo de vitória/derrota.
- **Modelos 3D existentes:** cubo 3×3×3 procedural adaptado de [Kubos](https://github.com/kardecallan566/Kubos), com 26 cubinhos e 54 adesivos; C1 adiciona um **2×2 real** com oito cubinhos, 24 adesivos e o mesmo motor de rotação por camada.

## Documentação de planejamento

| Documento | Conteúdo |
|---|---|
| [00 — Visão e princípios](docs/00-visao-e-pilares.md) | Pitch, público, fantasia e limites |
| [01 — Jogabilidade e regras](docs/01-jogabilidade-e-regras.md) | Controles, ondas, condições, tutorial e fluxo |
| [02 — Sistema de cubos 3D](docs/02-cubos-e-resolucao.md) | Regras do quebra-cabeça, animação, embaralhamentos e dificuldades |
| [03 — Progressão e economia](docs/03-economia-e-progressao.md) | Moedas, XP, loja persistente e balanceamento |
| [04 — Habilidades e combinações](docs/04-habilidades-e-sinergias.md) | Catálogo inicial, ofertas e limites |
| [05 — Direção artística e UX](docs/05-arte-ui-e-audio.md) | Cenário, mão, feedback, HUD, acessibilidade e som |
| [06 — Arquitetura técnica](docs/06-arquitetura-godot.md) | Cenas, dados, sistemas, importação e persistência |
| [07 — Escopo e aceitação do MVP](docs/07-mvp-e-criterios.md) | Exatamente o que será entregue e como validar |
| [08 — Roadmap e backlog](docs/08-roadmap-e-backlog.md) | Checkpoints e divisão das entregas |
| [09 — Qualidade e riscos](docs/09-testes-riscos-e-originalidade.md) | Plano de testes, qualidade, propriedade intelectual |
| [10 — Valores de balanceamento](docs/10-balanceamento-inicial.md) | Parâmetros iniciais verificáveis e ajuste por playtest |
| [11 — Mapa aberto](docs/11-mapa-campo-aberto-e-camera.md) | Gramado, câmera, spawn, atmosfera, composição e testes |
| [12 — Gamefeel](docs/12-gamefeel-eventos-visuais-e-detalhamento.md) | Toque, giros, mão, recompensas, UI e sons |
| [13 — Auditoria](docs/13-auditoria-de-consistencia.md) | Problemas corrigidos, contratos e riscos remanescentes |

## Ordem sugerida

Validar o modelo 3D e o campo aberto -> protótipo de rotação -> validar o prazer de resolver cubos com a mão -> construir uma onda jogável -> conectar progressão de uma partida -> completar cinco ondas -> integrar economia persistente -> acabamento e testes.

O **teste obrigatório do C1** é comprovar no Godot, com janela gráfica, que resolver cubos movendo uma mão estilizada é confortável, satisfatório e legível. Não investir em uma loja extensa ou dezenas de variantes antes dessa prova.

## Fonte técnica e referência

- [King of Pickaxe — página oficial na Steam](https://store.steampowered.com/app/4264240/King_of_Pickaxe/)
- [Godot — documentação estável](https://docs.godotengine.org/en/stable/)
- [Godot — importação de cenas 3D](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/)

Nenhuma implementação, modelo ou código de terceiros é copiado pela documentação.

## Checkpoint C0 — Inspeção técnica 3D (integrado à main)

O C0 reutiliza exclusivamente o núcleo procedural do [Kubos](https://github.com/kardecallan566/Kubos), sem copiar os sistemas econômicos ou o jogo. **Não é um MVP** nem um combate jogável: é uma cena de validação do modelo.

- **Abrir C0:** use Godot **4.7.2**, abra `project.godot` e execute diretamente `scenes/c0/cube_inspection.tscn` com F6. A cena contém gramado aberto, câmera ortográfica fixa e cubo 3×3×3.
- **Painel:** Embaralhar (seed determinística), Resolver próximo giro, Resolver todos, Reiniciar.
- **Tests:** `godot --headless --editor --path . --import --quit`; depois `godot --headless --path . --script res://tests/unit/test_cube_state.gd` e `godot --headless --path . --script res://tests/integration/test_c0_cube.gd`.
- **Docs:** [Auditoria técnica e origem](docs/checkpoints/C0-kubos-asset-audit.md) e [checklist manual](docs/checkpoints/C0-test-plan.md).
- **Histórico:** o CI do C0 foi aprovado e o checkpoint foi integrado na `main`. A aprovação visual foi dada pelo usuário; o C0 continua disponível para inspeção individual no editor. Não contém mão ou ondas.

O projeto **Kubos não é alterado** por esse trabalho. O KubRogue continua um jogo separado.

## Checkpoint C1 — Primeira interação jogável (branch de teste)

**Branch:** `dev/checkpoint-01-hand-2x2`. **Godot:** 4.7.2.

1. Abra `project.godot` e pressione **F5** para abrir `scenes/c1/hand_puzzle_prototype.tscn`.
2. Mova o mouse sobre o cubo de oito peças. Uma mão 2D estilizada acompanha o cursor e o alvo ganha um anel de seleção.
3. **Clique esquerdo** ou **segure o botão esquerdo** para realizar giros válidos da face, com cooldown por tempo real e animação de 90°/180°.
4. O embaralhamento é reversível e reproduzível por seed; o último giro alinha os adesivos e soma **+10 moedas e +1 XP provisórios** na HUD.
5. Um novo 2×2 embaralhado aparece para repetir o teste. O botão *Novo cubo* pula para outra seed sem dar recompensa.
6. Para inspecionar o 3×3 do C0, abra a cena antiga via F6 (ela não foi removida).

**Ainda ausente:** ondas, relógio, progressão de cartas, mão com rig profissional, sons definitivos, moedas persistentes, loja e export final. O protótipo de mão é procedural e leve; sua qualidade visual requer playtest.

**Testes automatizados:**

```powershell
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/unit/test_cube_state.gd
godot --headless --path . --script res://tests/unit/test_cube_state_2x2.gd
godot --headless --path . --script res://tests/integration/test_c0_cube.gd
godot --headless --path . --script res://tests/integration/test_c1_cube_2x2.gd
godot --headless --path . --script res://tests/integration/test_c1_stage.gd
```

Documentação e validação manual: [Checkpoint C1](docs/checkpoints/C1-hand-2x2.md).

### Correção de layout do cubo e cursor (C1)

O 2×2 agora usa espaçamento **físico compacto**: os centros dos cubinhos vizinhos ficam separados por `STEP = 0.338`, com juntas de apenas `STEP - CELL = 0.011`. O domínio matemático continua com coordenadas ±1, mas a geometria usa `_grid_step() = STEP / 2`; o 3×3 C0 preserva a escala antiga. Isso elimina os espaços largos vistos no Windows sem distorcer as peças durante giros.

O antigo modelo de mão 3D foi **retirado do C1** e substituído por `scripts/visual/hand_cursor_2d.gd`: cursor de mão original desenhado em 2D, sem importação externa, na `CanvasLayer` e sem capturar cliques. Sobre a HUD, o ponteiro normal do Windows volta a aparecer; ao sair da cena ele é restaurado. O gramado usa material sem iluminação dinâmica para evitar ficar esbranquiçado na configuração Compatibility.

## Checkpoint C2 — Ondas e economia de partida

**Branch de validação:** `dev/checkpoint-02-waves-economy` · Godot 4.7.2.

A cena de abertura (F5) agora é `scenes/c2/wave_stage.tscn`. Ela apresenta **duas ondas de demonstração**, uma arena gramada aberta, mão 2D e cubos 2×2 reais, com no máximo quatro simultâneos. Cubos **aprendizes** têm 2–4 movimentos; **reforçados** têm 5–8, corpo escuro e anel dourado. Clique ou segure sobre o cubo, resolva suas faces e ganhe moedas e XP da run (**10/1** ou **18/2**).

- A onda possui cronômetro, agendamento gradual de aparições, estabilidade inicial de 100 e penalidade de 25 por cubo **apresentado mas não resolvido** ao expirar o tempo.
- Cubos ainda na fila de spawn **não** penalizam o jogador; a tela de resultado diferencia "não resolvidos" e "não exibidos".
- Se restar estabilidade ao fim da onda 1, surge opção de prosseguir para a onda 2. Ao sobreviver às duas ondas, aparece vitória **do protótipo C2**; não é a vitória do MVP completo.
- Botões **Pausar/Continuar** e **Recomeçar**. A moeda e XP só existem enquanto a run está aberta, sem salvar em disco.
- C0 e C1 continuam disponíveis nas cenas anteriores, para regressão.

Testes automatizados:
```powershell
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/unit/test_c2_rules.gd
godot --headless --path . --script res://tests/integration/test_c2_stage.gd
```

[Documentação detalhada e checklist do C2](docs/checkpoints/C2-waves-economy.md). **Nenhum merge em main até teste visual e aprovação deste checkpoint.**

## Checkpoint C3 — Roguelite com cinco ondas (branch de teste)

**Código em `dev/checkpoint-03-roguelite`, não integrado à main enquanto faltar sua validação visual.**

Execute F5 para abrir `scenes/c3/roguelite_stage.tscn`, em Godot 4.7.2. C0/C1/C2 seguem acessíveis via cenas antigas (F6).

- **Cinco ondas** com 5, 8, 9, 11 e 10 cubos previstos, cronômetros 45/55/65/70/90 s.
- Cubos 2×2 aprendiz e reforçado, além de **elite 3×3** na onda 5. Um espaço fica reservado para a elite surgir por volta do segundo 18–20 da última onda, mesmo se há três comuns em tela.
- **XP cumulativo 5/12/21/32/45**: escolha 1 de 3 cartas, com cronômetro e surgimento de cubos congelados durante a oferta. Cartas podem subir até nível 3 e têm efeito na run atual.
- **Oito habilidades reais:** Pulso ágil (velocidade), Dedo certeiro (giro extra), Luva magnética (alcance), Bolsa encantada (moedas), Ritmo de mestre (combo), Fôlego extra (tempo futuro), Olhar de cubista (menos giros dos novos reforçados), Mão paciente (recuperação de estabilidade).
- **Pagamento único por resolução legítima**, inclusive +80 moedas/+6 XP da elite; bônus de moedas limitados a +150%; dinheiro não salva ainda.
- Vitória exige completar a quinta onda e **resolver** a elite; estabilidade em zero ou elite não resolvida significam derrota.

Veja [Checklist do C3](docs/checkpoints/C3-roguelite.md). **Não é o MVP final**: a economia persistente, loja, tutorial e exportação são C4–C5.

## Checkpoint C4 — Hub, Loja e progresso persistente

**Branch de validação:** `dev/checkpoint-04-hub-save-shop` · **Godot 4.7.2**. Pressione **F5** para abrir a nova **hub**.

- **JOGAR:** na primeira vez exibe o tutorial em português antes de iniciar a run. Depois abre o Jardim dos Cubos com as cinco ondas, 2×2, 3×3 e cartas do C3.
- **LOJA:** Treino da mão (custos 200/500/1200; -4% de cooldown por nível), Bolso do cubista (250/650/1300; +5% de moedas por nível) e Arena estável (300/800/1600; +5 estabilidade máxima e inicial por nível).
- **MOEDAS:** ganhos por cubos resolvidos são registrados em `user://kubrogue_progress_v1.json` **antes do popup de confirmação**, não apenas no saldo da run. XP e cartas continuam temporários; perder a partida não apaga dinheiro confirmado.
- **RECORDES:** melhor onda, mais cubos resolvidos numa run e maior combo; tutorial e preferências também ficam salvos.
- **CONFIGURAÇÕES:** volumes e preferências de partículas/tremor ficam registrados. A implementação dos efeitos sonoros definitivos será realizada no C5.
- **SEGURANÇA DO SAVE:** IDs impedem créditos duplicados na mesma run. Escrita em arquivo temporário e backup `.bak` para recuperar estado anterior se um arquivo ficar corrompido. Se não conseguir gravar, pausa o combate e permite tentar salvar novamente.

**Executar testes C4:**
```powershell
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/unit/test_c4_progress.gd
godot --headless --path . --script res://tests/integration/test_c4_hub_game.gd
```

**Atenção:** não haverá login, internet, AdMob nem compras com dinheiro real. O C4 permanece separado na branch até validação visual e manual; cenas C0–C3 continuam disponíveis por F6.

Detalhes e checklist: [C4 — Hub, loja e salvamento](docs/checkpoints/C4-hub-save-shop.md).

## Checkpoint C5 — Polimento e preparo da build Windows (branch)

**Branch de validação:** `dev/checkpoint-05-polish-windows`. A cena principal é `scenes/c5/hub_stage.tscn`. Mão 2D, cenário em campo gramado aberto, rotação real de 2×2/3×3, cinco ondas, oito cartas e progresso do C4 continuam intactos. Cenas C0–C4 permanecem disponíveis para regressão via F6.

**Novidades incluídas:** efeitos `turn/solved/coins/level/spawn/elite/wave/error/victory/tap` e música leve em loop, **sintetizados localmente**, sem usar arquivos de terceiros; volumes configuráveis que agora realmente afetam áudio; interface com paleta e botões uniformes, modal da loja rolável; feedback 2D de anéis, partículas e texto, com modo de partículas reduzidas; tremor opcional e desligado por padrão. Os 66 tufos de grama decorativos são combinados em um MultiMesh para reduzir draw calls.

**Para executar no Windows:**
```powershell
git fetch origin
git switch dev/checkpoint-05-polish-windows
git pull origin dev/checkpoint-05-polish-windows
godot .
```

**Exportar executável localmente** (requer templates de exportação **Godot 4.7.2** instalados no editor: Editor → Gerenciar Templates de Exportação):
```powershell
godot --headless --editor --path . --import --quit
New-Item -ItemType Directory -Force builds/windows | Out-Null
godot --headless --path . --export-release "Windows Desktop" builds/windows/KubRogue.exe
```

A pasta `builds/windows` deve conter `KubRogue.exe` e `KubRogue.pck`; mantenha os dois arquivos juntos. O `.exe` não é instalador nem build assinada. Alternativamente, o workflow [C5 — Windows test build](.github/workflows/windows-export.yml), executado ao publicar na branch C5 ou acionado manualmente em GitHub Actions, poderá gerar um ZIP de teste após importar os templates oficiais. **Não afirmar que o ZIP foi gerado antes de executar esse workflow.**

Manual e lista de testes: [Checkpoint C5](docs/checkpoints/C5-polish-windows.md). Não integrar à main antes de sua aprovação no Windows.

### C5.1 — HUD arcade e trilha energética

**Atualização na mesma branch `dev/checkpoint-05-polish-windows`**, sem merge automático na `main`.

O tema das interfaces agora é **cartoon arcade com profundidade**: botões ilustrados procedurais com base marrom, frente dourada/verde/azul/vermelha, listras diagonais, brilho no topo, sombra e estados de hover/pressed. Não há arquivo de fonte, textura externa ou imagem copiada da referência. O estilo é aplicado à hub, loja, tutorial, configurações, cartas de habilidades, resumos de onda e ações da HUD.

A HUD da partida agora destaca **onda e progresso**, **tempo**, **estabilidade**, **moedas/XP** e **saldo permanente**, com barras distintas, mantendo a região principal do campo gramado livre para os cubos. O spawn desvia dinamicamente da área real ocupada pelo painel.

A música procedural foi substituída por uma composição original de **oito compassos em 132 BPM**, com melodia pluck, acordes rítmicos, baixo, bumbo, caixa e chimbal. O loop dura aproximadamente **14,55 segundos** em dó maior, com progressão C–F–Am–G. O arquivo é gerado em memória e os volumes/mute anteriores continuam funcionando.

**Testar:** iniciar `godot .`, percorrer hub/loja, verificar hover/press dos botões, iniciar partida e conferir as três barras da HUD, cartas, pausa e a trilha com volume 0%, 50% e 100%. Acompanhar os testes C0–C5 e a exportação Windows na branch.

### C5.2 — Revisão de legibilidade e cards de habilidades

Após testar a primeira versão arcade, a hub, a HUD e o seletor de habilidades foram **reconstruídos visualmente**, sem alterar as regras nem recompensas.

- **Hub:** painel menor e mais equilibrado, título/saldo/recordes separados, duas ações principais e ações secundárias discretas; sem botões gigantes empilhados.
- **HUD:** ocupa largura reduzida, com onda, tempo, estabilidade, XP, moedas e contexto agrupados; barra de tempo/onda/estabilidade permanece integrada à lógica C3. Ações de pausar, reiniciar e voltar cabem em uma linha; a recuperação de salvamento só surge se há moedas pendentes.
- **Cartas:** três cards próprios em `scripts/c5/skill_card.gd`, com categoria, nome, transição de nível, bônus, descrição e botão **Escolher** separados. Lado a lado em larguras comuns de PC e empilhados com rolagem em janelas estreitas. Selecionar ainda chama `RunBuild.select_card`, com cronômetro congelado.
- **Loja:** cada melhoria permanente tem cartão com nome, nível, benefício e preço, sem texto comprimido.
- **Estilo:** botões continuam coloridos e táteis, mas têm bevel/sombra discretos em `StyleBoxFlat` em vez de imagens enormes esticadas; painel claro, hierarquia tipográfica e melhor espaçamento.

Os testes C5 foram atualizados para verificar os cards, os estados de botões, o congelamento do cronômetro e a nova HUD, além das regressões C0–C4. A branch C5 continua separada da main até validação visual.

## Checkpoint C6 — Desafio Diário e uma troca de cartas

**Branch para teste:** `dev/checkpoint-06-daily-challenge`. C5 aprovado já está na main, via PR #6. Esta branch utiliza Godot **4.7.2**, mantém todas as cenas C0–C5 e deixa o **C6 como cena principal**.

- **Modo Normal:** cinco ondas, recompensas permanentes e melhorias anteriores. A cada nova run, uma seed diferente gera os embaralhamentos e ofertas das habilidades; a seed fica visível na HUD.
- **Desafio do Dia (offline):** acessível na hub; congela a data em **UTC** no momento da seleção e deriva uma seed determinística daquela data, igual em Windows/Linux e para qualquer jogador. Uma nova tentativa no mesmo dia tem a **mesma seed**; muda à meia-noite UTC.
- **Recordes pessoais do dia:** tentativas, vitórias, maior onda e mais cubos resolvidos, registrados em `user://kubrogue_daily_v1.json` com backup `.bak`, **isolados** do save das moedas do C4/C5. Pode jogar quantas vezes quiser no dia; sem backend/placar online.
- **Troca de cartas:** uma única vez por partida, na tela de escolha de habilidade. Substitui o trio por habilidades válidas diferentes, quando disponíveis, sem gastar XP. Depois de usá-la, o botão fica desabilitado até a próxima run. As oito cartas, níveis, bônus e suas regras continuam inalterados.
- **Sem impacto no saldo:** moedas e melhorias permanentes continuam usando o sistema aprovado; nenhum reset nem migração da carteira atual. Desafio diário permite comprar melhorias e ganhar moedas normalmente, então os recordes são **pessoais, não uma competição balanceada entre contas**.

**Testar no Windows:**
```powershell
git fetch origin
git switch dev/checkpoint-06-daily-challenge
git pull origin dev/checkpoint-06-daily-challenge
godot .
```

Abra `DESAFIO DO DIA`, escolha uma carta ou use `TROCAR AS 3 CARTAS` e confira seu resultado ao voltar à hub. Veja o [checklist C6](docs/checkpoints/C6-daily-challenge.md). O C6 só entrará na main após CI verde e sua aprovação no Windows.
