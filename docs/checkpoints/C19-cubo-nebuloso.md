# C19 — Nova espécie: Cubo Nebuloso

**Estado:** planejado; nenhum código C19 existe. **Base:** C18 aprovado. **Branch sugerida:** `dev/checkpoint-19-misty-cube`.

## Objetivo

Adicionar uma espécie que desafia a leitura sem esconder informação de forma injusta. A aparência dos adesivos fica menos saturada quando o cubo está longe da mão e recupera contraste quando recebe foco. Os símbolos do C17 permanecem visíveis em qualquer estado.

## Lógica

- ID permanente da espécie: `mist`; nome exibido: Cubo Nebuloso.
- O estado do puzzle é um cubo legal já embaralhado; a névoa é exclusivamente visual.
- Perfil visual: saturação/contraste reduzidos à distância, foco legível quando a mão seleciona o cubo. Evitar transparência alfa para não criar sorting/depth artifacts no GL Compatibility.
- A transição visual deve ser curta e suave; no modo Movimento Reduzido, usar troca imediata ou duração mínima.
- A espécie entra em slots de ondas definidos pelo diretor, sem aumentar o máximo de quatro cubos ativos.
- Profundidade inicial sugerida: 5–7 movimentos legais; moeda/XP devem ser hipótese até medir C18, não valor definitivo.
- O jogador sempre consegue identificar o alvo e a ação necessária. Nunca ocultar a única indicação de face.

## Implementação por arquivo

- `scripts/c19/misty_visuals.gd`: `apply(actor_root, cube, focused, accessibility_profile)` e `set_focus(focused)`.
- `scripts/c19/special_director.gd`: herdar do diretor de variantes mais recente aprovado; adicionar `mist` ao catálogo e aos slots de ondas.
- `scripts/c19/game_stage.gd`: herdar da cena de gameplay mais recente e aplicar o visual ao spawn/foco.
- `scripts/c19/misty_profile.gd`: dados de profundidade/recompensa como constantes ou Resource, sem duplicar catálogo inteiro.
- Atualizar `KubeJournal.CATALOG` com ID estável, nome, dimensão, recompensa e descrição.
- Atualizar `medal_service.gd` sem invalidar o marco antigo das sete espécies: preservar a conquista histórica e acrescentar uma conquista de coleção para oito espécies (ou tornar a regra versionada).
- `tests/unit/test_c19_misty.gd` e `tests/integration/test_c19_misty_game.gd`.

## Regras de integração

- O Bestiário deve contar `mist` automaticamente nas abas e na maestria C14.
- Contagem antiga do save recebe zero para a espécie nova; não resetar descobertas existentes.
- O evento de solução passa pela mesma transação de moeda e registro de espécie já existente.
- O Laboratório não recebe a nova espécie automaticamente; ele continua sendo um ambiente de puzzle neutro.

## Testes e aceitação

- Repetir a mesma seed produz o mesmo estado lógico e visual inicial.
- Focar/desfocar não muda snapshot, movimentos disponíveis, moeda, XP ou tempo.
- Todos os seis marcadores de face continuam distinguíveis em modo padrão e C17.
- Resolver a espécie registra exatamente uma solução e uma recompensa.
- Save antigo carrega sem migração destrutiva; maestrias e conquistas antigas permanecem desbloqueadas.
- Testar 4 atores simultâneos e modo GL Compatibility no Windows.

**Fora do escopo:** cubo invisível, mudança de regra de rotação ou solver novo.
