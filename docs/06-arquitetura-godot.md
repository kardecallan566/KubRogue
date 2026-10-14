# 06 — Plano de arquitetura técnica em Godot

> **Arquitetura de MVP planejada.** O projeto Godot da **inspeção C0** já existe, mas a arquitetura completa de gameplay descrita neste documento **ainda não está implementada**.

## 1. Stack e princípios

- **Engine:** Godot 4.x estável, GDScript 2.0, cenas 3D com UI em Control; testar especificamente na instalação utilizada no desenvolvimento antes de fixar versão mínima.
- **Render:** proposta Compatibility ou Forward+ após medir o visual e FPS em Windows. Evitar depender de recursos exclusivos de renderer sem justificativa.
- **Arte:** .glb / .gltf preferenciais para importar o cubo 3D; materiais com instâncias e parâmetros por variante.
- **Persistência:** JSON ou Resource serializado em user://, com esquema versionado e escrita atômica.
- **Desacoplamento:** lógica do cubo pura e testável; apresentação reage a sinais; EconomyService é única origem de transações.

## 2. Árvore de diretórios PROPOSTA

- project.godot
- scenes/bootstrap/ (inicialização)
- scenes/ui/ (hub, loja, pausa, resultado e ofertas durante a run que congelam timer/spawner)
- scenes/world/ (campo gramado, câmera ortográfica fixa, spawn e vegetação)
- scenes/gameplay/ (diretor do campo, mão, cubo, VFX)
- scripts/core/ (estado global, eventos, save, configuração)
- scripts/puzzle/ (modelo do cubo, movimentos, embaralhamento e solução inversa)
- scripts/gameplay/ (atores, spawn, ondas, run, targeting)
- scripts/progression/ (catálogo de upgrades, XP, economia, meta)
- scripts/ui/ (controladores da HUD e menus)
- data/ (recursos .tres com tabelas de cubos, ondas, cartas, preços)
- assets/models/ (modelos autorizados), assets/materials/, assets/audio/, assets/fonts/, assets/vfx/
- tests/ (lógica e testes de integração executáveis)
- docs/ (estes arquivos)

Esses caminhos são um **contrato de organização**; não criar pastas vazias ou fingir que arquivos já existem.

## 3. Cenas e papéis

| Cena/nó | Responsabilidade | Não deve fazer |
|---|---|---|
| **AppRoot** | iniciar serviços, carregar save, alternar menu/run | calcular movimentos do cubo |
| **HubMenu** | navegar, mostrar dinheiro, chamar loja | alterar moeda diretamente |
| **GameArena** | coordenar campo gramado contínuo, câmera ortográfica fixa, HUD e atores | guardar saldo persistente |
| **HandController (Node)** | ler input, converter cursor para o plano XZ, selecionar alvo e pedir giro; apresentar um cursor 2D separado em CanvasLayer | gerar/editar solução lógica |
| **CubeActor (Node3D)** | ciclo spawn->ativo->rotação->conclusão, sinais e recompensa solicitada | armazenar dados globais |
| **CubeView3D (Node3D)** | apresentar peças e animar giro validado | decidir vitória pelo brilho/material |
| **WaveDirector (Node)** | agenda de spawn em anel, timer, elite com slot reservado, penalidade só por cubos spawnados | penalizar spawns que nunca apareceram |
| **RunDirector (Node)** | transição de ondas, estabilidade, vitória/derrota, sessão | executar compras meta |
| **HUD (Control)** | exibição reativa de estado | ser fonte de dados econômicos |
| **OfferPanel (Control)** | escolha 1/3 de cartas | gerar efeitos fora do catálogo |
| **ShopPanel (Control)** | apresentação de preços, estado do botão | debitar saldos sem serviço |

## 4. Serviços e classes de lógica

- **PuzzleState / PuzzleMove:** coordenadas discretas, adesivos/cores, giro de face/camada, teste de estado resolvido e operações de inversão.
- **ScrambleGenerator:** semente local da run, tamanho do cubo, profundidade, prevenção de cancelamentos óbvios.
- **SolutionPlan:** sequência reversa conhecida; nunca se apresentar como solver de solução mínima.
- **CubeCatalog:** dados por tipo, incluindo N, movimentos, moedas, XP, peso de spawn e prefab.
- **WaveCatalog:** lista de tipos, tempos, quotas, elite e total de spawns, determinísticos por seed.
- **TargetingService:** mouse->plano XZ usando câmera fixa, limites invisíveis, filtros de estado, apenas atores válidos, impedindo input sobre UI/vegetação.
- **EconomyService:** única API para creditar moedas resolvidas e comprar upgrades; valida IDs de pagamento únicos.
- **ProgressionService:** XP, níveis, ofertas pendentes, níveis de cartas e limites.
- **MetaService:** níveis permanentes, cálculo de bônus iniciais da run.
- **SaveService:** esquema, leitura, verificação, snapshot e escrita **atômica antes de exibir moedas confirmadas**.
- **AudioService / SettingsService:** volumes, acessibilidade e persistência.

Evitar Autoload para cada objeto. Usar Autoload somente para serviços de vida longa (save/economia/configurações) e instâncias locais para run e puzzle.

## 5. Contratos de eventos (conceituais)

Eventos sugeridos, emitidos uma vez com tipos claros:
- cube_spawned(cube_id, cube_type)
- cube_targeted(cube_id)
- cube_move_started(cube_id, move)
- cube_move_completed(cube_id, move, moves_remaining)
- cube_solved(cube_id, coin_value, xp_value)
- cube_expired(cube_id)
- coins_changed(total, delta)
- xp_changed(level, xp_total)
- upgrade_offered(choices, run_id)
- upgrade_selected(upgrade_id, new_level)
- stability_changed(new_value)
- wave_finished(wave_number, unresolved_count)
- run_finished(victory, stats)

O produtor de eventos **não** chama UI por caminho absoluto. Consumidores devem se desconectar ao sair de cena. O serviço de economia verifica IDs processados dentro da run antes de creditar saldo.

## 6. Configuração por recursos

Preferir recursos tipados para cubos, ondas, cartas e melhorias permanentes. Cada entrada deve conter ID estável, valores, descrição, ícone ou referência visual e limites. Centralizar números de balanceamento em dados, não espalhar literais em GDScript. Dados ausentes devem produzir erro legível no desenvolvimento e fallback seguro em runtime.

## 7. Modelo->animação (sequenciamento seguro)

1. HandController verifica seleção, entrada permitida e cooldown.
2. CubeActor reserva uma ação, sem modificar economia.
3. PuzzleState produz movimento legal do plano.
4. CubeView3D anima camada correspondente e notifica finalização.
5. PuzzleState finaliza/valida movimento, sincroniza posições.
6. CubeActor verifica vitória; se verdadeiro, emite cube_solved **uma só vez**.
7. EconomyService credita moedas, ProgressionService credita XP, HUD recebe atualização.
8. CubeActor finaliza animação cosmética e libera/retira a instância.

Se ocorrer interrupção, encerrar animação com estado lógico consistente ou desfazer ação em andamento; nunca pagar por progresso não confirmado.

## 8. Importação e testes do modelo 3D

O asset do cubo já existe segundo o idealizador, mas **não está aqui**. A futura etapa deve registrar: autoria/licença, formato, pivô, número de submalhas, mapeamento das faces, unidade de escala, materiais, animações e cena de inspeção. Caso o modelo não seja desmontável em cubinhos, protótipo procedural antes de modificar o arquivo original.

A documentação oficial Godot recomenda glTF 2.0/.glb; veja https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/ e https://docs.godotengine.org/en/stable/getting_started/first_3d_game/02.player_input.html.

## 9. Save e idempotência

- Save local versionado com chaves explícitas; valores numéricos inteiros, não negativos.
- Receita por cubo ganha ID de transação único dentro da run e marcador de crédito confirmado; persistir pagamento atômico **antes** do popup de moedas.
- Compra de upgrade valida saldo + nível e salva alteração como única operação coerente.
- Ao encerrar run antecipadamente, não ressuscitar cubos antigos nem conceder moeda por cena fechada.
- **Não** incluir login, backend, ranking global, anúncios, analytics invasivo ou rede no MVP.

## 10. Performance

Alvo de teste inicial: resolução 1280x720 e 1920x1080, 60 FPS no PC de desenvolvimento, **4 cubos ativos** e efeito máximo. Mídia 3D deve escalar para máquinas inferiores. Usar profiler: medir frame time, draw calls, nós e custo de sombra. Evitar alocar cubinhos/partículas todo frame; pooling só após diagnóstico, mas não fechar os olhos para vazamentos de nós.

## 11. Testabilidade/CI futura

- Testar PuzzleState e ScrambleGenerator sem cena gráfica.
- Testar pagamentos e compra com dados sintéticos.
- Testar temporalidade de ondas com clock injetável/falso.
- Smoke test de inicializar projeto e abrir arena.
- Relatórios de erro com seed, onda, cubo e transação (sem dados pessoais).
- Gatilho de integração no GitHub após existir projeto executável; não publicar badge verde sem pipeline real.

## 12. Implementação do mapa aberto no Godot

Cena planejada `FieldWorld.tscn` com `MeshInstance3D` plano grande, material de gramado original, `WorldEnvironment`, `DirectionalLight3D`, `Camera3D` ortográfica **fixa** e `MultiMeshInstance3D` opcional para tufos sem colisão. O mundo excede a câmera para esconder a borda do chão, porém `FieldBounds` limita logicamente o alvo/mão; não há streaming infinito nem paredes. `SpawnPlanner` usa anel periférico **visível**, valida distância da mão/cubos/UI e reserva quarto slot para a elite na onda 5. Veja [11](11-mapa-campo-aberto-e-camera.md).

Converter cursor com `Camera3D.project_ray_origin()` e `Camera3D.project_ray_normal()` no plano XZ, validando interseção não paralela; a HUD recebe e bloqueia cliques antes de cubos. A câmera não segue a posição calculada com o próprio cursor, impedindo loop de deriva.

## 13. Prioridade canônica de eventos

1. Completar giro e validar estado lógico SOLVED.
2. Persistir moeda única e atualizar XP, registrar oferta pendente.
3. Se a onda encerrou, penalizar cubos apresentados não resolvidos e atualizar estabilidade; **depois** verificar resultado terminal (derrota/vitória tem prioridade sobre novas cartas).
4. Se continuar jogando, mostrar oferta de carta na próxima pausa segura e congelar timer/spawn/ação.
5. Retomar do estado congelado após escolha, sem adicionar ticks de timer.

Testes de save, idempotência e carta terminal são obrigatórios; a especificação documental não substitui teste real no editor. Ver [13](13-auditoria-de-consistencia.md).

## 14. Implementação atual vs proposta

**Atuais no C0:** `project.godot`, `scenes/c0/cube_inspection.tscn`, `scripts/c0/cube_inspection.gd`, `scripts/puzzle/cube_state.gd`, `scripts/visual/cube_3x3.gd`, `scripts/visual/rounded_box_mesh.gd`, testes e workflow. **Apenas propostos:** `HandController`, `WaveDirector`, `EconomyService`, 2×2, hub, cartas e persistência. Não classificar código futuro como implementado. [Auditoria de origem](checkpoints/C0-kubos-asset-audit.md).

## 15. Checkpoint C1 — núcleo jogável em implementação

- **Domain:** `scripts/puzzle/cube_state_2x2.gd`, subclasse do motor discreto 3×3; oito cantos, 24 adesivos. Reutiliza `move/scramble/reversed_history` e substitui `is_valid/is_solved`.
- **Render:** `scripts/visual/cube_2x2.gd` herda o adaptador visual do C0, que agora oferece `_new_puzzle()` para injetar 2×2 ou 3×3 sem duplicar geometria/pivôs.
- **Mão:** `scripts/visual/hand_cursor_2d.gd`, cursor vetorial 2D autoral em CanvasLayer que ignora cliques e usa hotspot real. O script de mão 3D foi retirado do C1.
- **Stage:** `scripts/c1/hand_puzzle_prototype.gd`, projeta cursor pelo raio da Camera3D fixa para localizar alvos, desenha mão em screen-space, verifica distância e bloqueio de HUD, aplica cooldown e recompensa apenas após `is_solved`. Nenhuma recompensa é persistida no C1.
- **Cena:** `scenes/c1/hand_puzzle_prototype.tscn` usa Jardim dos Cubos e é a main scene nesta branch; a inspeção C0 continua no projeto.
- **CI:** import headless, domínio C0/C1, modelos 3×3/2×2, teste de estágio e boot.

Nada disso substitui `HandController` com controle avançado, `RunDirector`, `EconomyService` ou quadros de onda previstos nos checkpoints posteriores. Ver [documento C1](checkpoints/C1-hand-2x2.md).

## 16. Correção da malha do 2×2 e input 2D

No domínio, os oito cantos do 2×2 ocupam posições inteiras `(-1,1)` por eixo, necessárias ao motor de giros herdado. Para **renderização**, a distância entre vizinhos deve ser `STEP=0.338`, não `2×STEP`. Por isso `scripts/visual/cube_3x3.gd` oferece o método virtual `_grid_step()` com valor padrão `STEP`, enquanto `scripts/visual/cube_2x2.gd` o sobrescreve com `STEP/2`. `sync_poses()` usa a versão adequada depois de cada rotação, evitando peças distantes novamente. O cubo 3×3 de C0 mantém seu posicionamento.

O `HandCursor2D` é um Control dentro de CanvasLayer, com desenho próprio via CanvasItem, mouse filter IGNORE e posição igual ao ponteiro real menos hotspot. No campo a mão personalizada substitui o cursor visual; na HUD/saída do jogo restaura ponteiro nativo. O `HandController` futuro **não é Node3D**; apenas a interação do cubo pertence ao mundo 3D. O material do gramado é unshaded para não estourar sua cor no renderer Compatibility. Testes de distância pós-giro e apresentação do cursor completam o C1.

## 17. Implementação C2: sistemas separados e regras verificáveis

- `scripts/c2/run_wallet.gd`: créditos em memória por ID único de ator, tipos aprendiz (10 moedas / 1 XP) e reforçado (18 moedas / 2 XP). Uma solução só paga uma vez. **Não salva saldo em disco.**
- `scripts/c2/wave_director.gd`: duas ondas de demonstração, tempo de 42/55 s, fila de 6/8 cubos, intervalo de 2,1 s e máximo de quatro ativos. Estabilidade 100 e perda de 25 por cubo que **foi apresentado e não resolvido** ao fechar a onda; jamais por spawns pendentes.
- `scripts/c2/wave_stage.gd`: compõe arena gramada, cursor 2D, seleção por proximidade, ator 3D por ID e anel de foco, giros serializados, informações de tipo/giros, HUD, pausa e overlay de resultado.
- `scenes/c2/wave_stage.tscn` é a cena principal no C2. C0 e C1 não são alterados.
- `tests/unit/test_c2_rules.gd` e `tests/integration/test_c2_stage.gd` validam crédito único, tipos, limite de spawn, derrota, progresso e reinício.

A prévia C2 tem **duas ondas**, não é a regra final de cinco ondas: C3 substituirá as tabelas e adicionará habilidades/elite; C4 persistirá as moedas com transação atômica. A mão continua em CanvasLayer; o puzzle continua 3D e não usa HP.

## 18. Implementação C4 — persistência e integração

- **Autoload:** `KubeSession` / `scripts/c4/progress_service.gd` gerencia estado durável (`coins`, `meta`, `records`, `tutorial_completed`, `settings`, `run_number` e `paid_ids`). Compra e crédito alteram snapshot candidato e só confirmam após `write_json` retornar sucesso.
- **Disk adapter:** `scripts/c4/save_store.gd` encapsula `user://kubrogue_progress_v1.json`, limita tamanho, usa escrita `.tmp`, backup `.bak`, recuperação de JSON inválido e fornece caminho parametrizável para testes.
- **Hub:** `scenes/c4/hub_stage.tscn` e `hub_stage.gd`; navegação, loja 0–3 por upgrade, tutorial contextual, configurações, records e saldo. Nenhuma UI debita moeda diretamente.
- **Arena:** `scenes/c4/game_stage.tscn` reutiliza as cinco ondas e cubos do C3, aplica melhorias meta, confirma crédito persistente por cubo resolvido e permite voltar à hub após término. Falha de gravação suspende progresso e disponibiliza retentativa.
- **Regra importante:** um `run_number` é incrementado no início de cada nova run, e `paid_ids` é zerado **somente** nesse momento; reabrir o app durante a mesma run não recredita ID antigo. As cartas e XP são descartadas após sair.
- **Sem backend:** progresso somente local, sem identidades online, métricas remotas, anúncios ou monetização.

## 19. C5 — Camada de acabamento isolada

A cena C5 de hub/arena herda **a lógica via cópia controlada do C4**, que permanece acessível via F6 para evitar regressões. `scripts/c5/audio_director.gd` é autoload `KubeAudio` criado **depois** de `KubeSession`; gera uma vez sons PCM 16-bit 22.050 Hz e música original simples com loop, aplica volumes salvos em tempo real, limita polifonia a seis vozes e desconhece o gameplay. O `scripts/c5/feedback_layer.gd` é um `Control` de `MOUSE_FILTER_IGNORE`, desenha partículas temporárias limitadas e desliga seu `_process` quando ocioso; acessibilidade `reduced_particles` mostra só anéis e o cursor 2D mantém os eventos de mouse. O shake opt-in desloca a câmera poucos centímetros, com amortecimento, sem interferir na fonte lógica do puzzle. `scripts/c5/ui_skin.gd` compartilha StyleBoxFlat para botões/painéis. A grama passa a `MultiMeshInstance3D`, reduzindo 66 nós visuais a um só lote. O export Windows é separado do CI normal para não baixar templates grandes em cada push. Confira [C5](checkpoints/C5-polish-windows.md).

## 20. C6 — Sessão de desafios e recordes independentes

Autoload `KubeChallenge` vem após `KubeSession` e `KubeAudio`; oferece `select_mode`, `daily_seed`, `begin_run` e `record_result`, sem modificar `KubeSession`. O arquivo `user://kubrogue_daily_v1.json` usa o adaptador `SaveStore` com limite de tamanho, `.tmp` e `.bak`; guarda no máximo 120 dias de resultados, preservando o save histórico do usuário. O sorteio de cartas usa `scripts/c6/run_build.gd` (subclasse da implementação C3) com uma possibilidade de `reroll_offer` por run e RNG ligado à seed. Uma nova cena C6 de hub/arena mantém as cenas C0–C5 intocadas. A data diária é sempre UTC e congelada no momento de entrada, não recalculada durante a partida. Sem leaderboard remoto.

## 21. C7 — Diretor e variantes 2×2

`special_director.gd` estende C3, injeta Dourados e Blindados em slots da tabela de ondas C3 (não insere spawns adicionais, preserva reserva da elite 3×3). `special_wallet.gd` estende o wallet C2, substituindo o payout apenas dos novos tipos e mantendo proteção contra pagamentos duplicados. `special_visuals.gd` aplica material nas peças estruturais dos 2×2 e acrescenta halo e marcador, sem alterar adesivos/giro/lógica do cubo. O estágio C7 usa o diretor e itens de C6 sem sobrepor scripts de checkpoints anteriores. Não há alterações no schema dos saves.

## 22. C8 — KubeJournal e contratos atômicos

Autoload `KubeJournal` `scripts/c8/journal_service.gd` guarda dados persistentes de bestiário no `user://kubrogue_journal_v1.json`, separados da carteira e do modo diário. Na arena, `register_solve(kind, cube_id)` aplica alterações temporárias aos objetivos e devolve o bônus da conclusão; `director.resolve_cube` valida a solução antes disso. **O valor do bônus é acrescentado antes da chamada singular `KubeSession.credit_cube`**, e o pagamento segue a proteção idempotente e a recuperação de pendências do C4. O Bestiário só registra `record_cube` após confirmação do crédito, com tokens `run_number:cube_id` (últimos 512) para deduplicação. Escrita do Bestiário falha de maneira independente da carteira, mantendo tentativas pendentes em memória. A C8 mantém cenas C7 intactas e adiciona `scenes/c8/{hub_stage,game_stage}.tscn`.

## 23. C9 — RouteService sem dependência de backend/save

`scripts/c9/route_service.gd` é `RefCounted` por run, recebe `run_seed`, gera dois IDs distintos para cada transição 0–3 usando RNG local (seed + fator de onda), guarda escolha ou skip e só aplica efeito na próxima onda. `scripts/c9/game_stage.gd` é cópia isolada do C8, com modal de duas cartas e ponte para tempo/estabilidade, mutação controlada de um slot Apprentice→Golden e incremento temporário do `director.money_modifier` antes de `resolve_cube`. O efeito não escreve no save, não contorna o `KubeSession.credit_cube` e não altera a estrutura do Bestiário, Workshop ou desafio diário. Só a cena principal C9 é substituída; cenas C0–C8 continuam disponíveis. Regras/risco detalhados no [C9](checkpoints/C9-garden-routes.md).

## 24. C10 — Motor de streak desacoplado

`scripts/c10/fever_engine.gd` é uma máquina de estados por run `RefCounted`, sem mudanças persistentes, que processa `tick(delta)` apenas com jogo em andamento e `on_solve(actor_id)` uma única vez por identificador. O combo existente da C9 vira uma projeção de `fever.streak`, mantendo best combo do save. O bônus +20% entra no `director.money_modifier` antes de `director.resolve_cube` e não cria novas chamadas a `KubeSession.credit_cube`. O cronômetro de onda nunca passa `wave_start_duration + 6s`, e a janela FEVER é suspensa junto com a partida, inclusive nas telas de cartas/Oficina/Rotas. HUD especial usa `StyleBoxFlat` e `ProgressBar` compatíveis com OpenGL Compatibility. Não toca nos scripts C0–C9.
