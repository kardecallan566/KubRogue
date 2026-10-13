# KubRogue

**KubRogue** é um jogo single-player de ação roguelite arcade, em um campo gramado aberto em visão superior 2.5D com cubos 3D manipuláveis. A mão do jogador é controlada pelo mouse e "resolve" cubos coloridos por rotações válidas de suas camadas. Cada cubo completado concede moedas e experiência, enquanto ondas mais exigentes introduzem cubos maiores, variantes, escolhas de melhorias e decisões de risco.

> **Estado atual: fase de pré-produção — somente documentação.** Este repositório ainda NÃO contém um projeto Godot jogável, o modelo 3D citado pelo idealizador, scripts nem assets. Os números e parâmetros são hipóteses iniciais para teste, não características implementadas.

## Conceito em uma frase

**Mova a mão, encaixe as cores, resolva cubos, ganhe moedas e construa uma combinação de poderes capaz de vencer cinco ondas de desafios.**

## Decisões fundamentais

- **Referência de sensação:** ação com mouse, ondas, upgrades e partidas repetíveis inspiradas por [King of Pickaxe](https://store.steampowered.com/app/4264240/King_of_Pickaxe/). Identidade, mecânicas de resolução, arte, interface, efeitos, nomes e conteúdo devem ser originais.
- **Resolução arcade, não simulador de speedcubing:** um comando da mão aplica um movimento legal que aproxima o cubo do estado resolvido. No MVP, o jogo utiliza a inversão de um embaralhamento controlado — não promete um solucionador geral nem exige que o usuário conheça algoritmos de cubo mágico.
- **Mapa e visual:** gramado pastel contínuo, câmera quase superior ortográfica e fixa no MVP; cubos e mão 3D destacados. Sem palco circular ou paredes visíveis.
- **Loop:** solucionar cubos -> ganhar moedas e XP -> escolher cartas durante a run em pausa segura -> superar ondas -> comprar melhorias permanentes -> recomeçar.
- **Primeiro destino:** PC Windows, mouse e teclado, Godot 4.x + GDScript, com meta de 60 FPS na configuração-alvo de desenvolvimento. Outras plataformas vêm depois.
- **MVP:** 5 ondas, cubo 2x2 comum, 2x2 reforçado e elite 3x3; mão, moedas, XP, 8 habilidades, 3 melhorias permanentes, interface, áudio, salvamento local e fluxo completo de vitória/derrota.
- **Modelo 3D existente:** a integração depende de receber e inspecionar o arquivo e sua licença. Até lá, o desenvolvimento posterior pode usar geometria provisória gerada no Godot.

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

O **primeiro teste obrigatório** é provar que resolver um cubo com uma mão visível é divertido e legível. Não investir em uma loja extensa ou dezenas de variantes antes dessa prova.

## Fonte técnica e referência

- [King of Pickaxe — página oficial na Steam](https://store.steampowered.com/app/4264240/King_of_Pickaxe/)
- [Godot — documentação estável](https://docs.godotengine.org/en/stable/)
- [Godot — importação de cenas 3D](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/)

Nenhuma implementação, modelo ou código de terceiros é copiado pela documentação.
