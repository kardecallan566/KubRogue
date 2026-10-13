# KubRogue

**KubRogue** é um jogo single-player de ação roguelite arcade, em um campo gramado aberto em visão superior 2.5D com cubos 3D manipuláveis. A mão do jogador é controlada pelo mouse e "resolve" cubos coloridos por rotações válidas de suas camadas. Cada cubo completado concede moedas e experiência, enquanto ondas mais exigentes introduzem cubos maiores, variantes, escolhas de melhorias e decisões de risco.

> **Estado do desenvolvimento:** o **C0 está integrado à main**. O Checkpoint **C1** está na branch `dev/checkpoint-01-hand-2x2`: protótipo jogável com mão 3D, cubo 2×2 real e recompensas **provisórias em memória**. Ainda não há ondas, economia persistente, cartas, hub ou MVP completo.

## Conceito em uma frase

**Mova a mão, encaixe as cores, resolva cubos, ganhe moedas e construa uma combinação de poderes capaz de vencer cinco ondas de desafios.**

## Decisões fundamentais

- **Referência de sensação:** ação com mouse, ondas, upgrades e partidas repetíveis inspiradas por [King of Pickaxe](https://store.steampowered.com/app/4264240/King_of_Pickaxe/). Identidade, mecânicas de resolução, arte, interface, efeitos, nomes e conteúdo devem ser originais.
- **Resolução arcade, não simulador de speedcubing:** um comando da mão aplica um movimento legal que aproxima o cubo do estado resolvido. No MVP, o jogo utiliza a inversão de um embaralhamento controlado — não promete um solucionador geral nem exige que o usuário conheça algoritmos de cubo mágico.
- **Mapa e visual:** gramado pastel contínuo, câmera quase superior ortográfica e fixa no MVP; cubos e mão 3D destacados. Sem palco circular ou paredes visíveis.
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
2. Mova o mouse sobre o cubo de oito peças. Uma mão estilizada 3D acompanha o cursor e o alvo ganha um anel de seleção.
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
