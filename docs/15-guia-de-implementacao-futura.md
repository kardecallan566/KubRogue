# 15 — Guia de implementação futura do KubRogue

> **Playbook técnico revisado em 06/11/2026.** Este documento é a referência operacional para implementar os próximos checkpoints. Ele descreve padrões e contratos; não significa que os checkpoints C17–C30 já estejam codificados.

## 1. Estado e regra de início

- A branch `main` consultada em 06/11/2026 contém C0–C13.
- C14, C15 e C16 estão implementados em PRs encadeados #16–#18, mas ainda aguardam validação manual e integração.
- O PR #19 reúne documentação e permanece separado da integração de gameplay.
- **Não iniciar C17 sobre uma base incompleta.** Primeiro validar e integrar C14 → C15 → C16, reexecutando CI e build Windows após cada atualização de base.
- C17–C30 são planejamento. Nenhuma branch de implementação, cena ou sistema desses checkpoints deve ser presumido existente.

## 2. Stack e arquitetura que devem ser preservadas

- Godot **4.7.2**, GDScript, renderer **GL Compatibility**.
- Viewport de referência 1280×720; validar também 1920×1080 e proporções 16:10/21:9.
- Produto single-player e offline; Windows é o primeiro destino.
- A lógica do puzzle fica separada da apresentação 3D: `scripts/puzzle/` contém estado e movimentos; `scripts/visual/` contém cubos renderizados e animações.
- As cenas e scripts de gameplay seguem uma cadeia de checkpoints. C16 usa `scripts/c16/game_stage.gd` herdando de C15, e a hub C16 herda de C15. Para uma futura etapa, herdar do **último checkpoint realmente integrado e aprovado**, não de uma branch pendente.
- O laboratório C16 é uma cena independente e não deve chamar os serviços de recompensa da campanha.

### Autoloads observados na base C16

| Autoload | Arquivo | Contrato |
|---|---|---|
| KubeSession | `scripts/c4/progress_service.gd` | carteira, upgrades, recordes, preferências e transações persistentes |
| KubeAudio | `scripts/c5/audio_director.gd` | música e efeitos |
| KubeChallenge | `scripts/c15/challenge_service.gd` | modos Normal/Diário/Semanal e seeds/recordes dos desafios |
| KubeJournal | `scripts/c8/journal_service.gd` | catálogo de espécies, descobertas e contratos |
| KubeHistory | `scripts/c15/history_service.gd` | resultados locais das partidas |

Não criar um segundo serviço de carteira, histórico ou Bestiário. Antes de alterar qualquer autoload, conferir a versão atual na branch aprovada e manter os nomes/contratos usados pelas cenas existentes.

## 3. Responsabilidade por camada

1. **Estado/modelo:** regras puras, sem nós visuais, arquivos ou controles de UI.
2. **Serviço:** coordena regras, valida entradas, expõe métodos e sinais; não desenha interface.
3. **Diretor de gameplay:** define ondas, spawns, espécies, transições e condições de vitória/derrota.
4. **Cena/controlador:** conecta input, serviço, diretor, animação e HUD; não deve se tornar a fonte permanente de dados.
5. **Visual:** apresenta um estado já decidido pela lógica; nunca declara vitória ou concede moedas por conta própria.
6. **Teste:** verifica regras e contratos sem depender de screenshots ou do editor gráfico.

Manter funções pequenas e tipadas. Usar IDs estáveis em inglês para dados salvos e nomes localizados somente na interface. Evitar números mágicos espalhados: centralizar valores em constantes ou recursos de dados.

## 4. Convenção de arquivos por checkpoint

A estrutura atual organiza scripts e cenas por checkpoint. Manter o padrão:

- `scripts/cXX/`: regras e serviços introduzidos pela etapa.
- `scenes/cXX/`: cenas da etapa, quando houver mudança de cena.
- `tests/unit/test_cXX_*.gd`: lógica isolada.
- `tests/integration/test_cXX_*.gd`: inicialização, cenas, serviços e regressão.
- `docs/checkpoints/CXX-*.md`: escopo, decisões, testes e checklist manual.
- `data/`: somente para catálogos/recursos que realmente precisem ser carregados como dados; não criar pastas vazias.

Quando um recurso for compartilhado por várias etapas, movê-lo para uma área comum somente em uma alteração explícita, testada e documentada. Não duplicar scripts inteiros para mudar poucas regras.

## 5. Contratos de lógica e eventos

### Resolução de um cubo na campanha

A ordem exata deve ser conferida na implementação aprovada, mas os invariantes são:

1. O estado matemático confirma `is_solved()`; animação concluída sozinha não basta.
2. O diretor marca aquele ator como resolvido uma única vez.
3. Contratos/contagens da run recebem o evento usando um `cube_id` único.
4. A carteira recebe o crédito total por uma única transação idempotente via KubeSession, incluindo qualquer bônus já calculado.
5. O Bestiário persiste a descoberta sem repetir o mesmo token de run/cubo.
6. HUD, som, partículas, Fever e conquistas reagem depois da confirmação durável.
7. O encerramento da run registra um resultado uma única vez via KubeHistory e o modo ativo via KubeChallenge.

Não mover pagamentos para animações, botões de UI ou callbacks de efeitos. Se o disco falhar, manter o crédito pendente e oferecer a recuperação existente; nunca exibir sucesso falso.

### Modos que não pagam recompensas

Laboratório, visualizadores e ferramentas de teste não devem chamar `begin_run`, `credit_cube`, `finish_run`, `record_cube` ou `record_result` da campanha. O C16 é a referência de isolamento.

## 6. Persistência segura

Usar `scripts/c4/save_store.gd` como adaptador, quando adequado. Todo novo arquivo de domínio deve:

- Ter caminho próprio em `user://`, versão explícita e tamanho máximo.
- Validar o tipo e o intervalo de cada campo antes de aceitar dados.
- Ler o arquivo principal e o backup conforme o contrato do SaveStore.
- Não sobrescrever arquivos ilegíveis nem schemas de versões futuras.
- Escrever em temporário, fazer flush, preservar backup válido e renomear atomicamente.
- Ter limites de retenção para listas/históricos.
- Usar IDs idempotentes para pagamentos, resultados, desbloqueios ou eventos.
- Ter testes de save novo, save antigo, backup, arquivo truncado, versão desconhecida e falha de escrita.

**Migração:** preferir campos opcionais com defaults quando isso for compatível. Se a estrutura mudar, escrever uma migração explícita, testada com fixtures reais da versão anterior. Nunca incrementar schema apenas por hábito; documentar por que é necessário.

## 7. Aleatoriedade e reprodutibilidade

- Usar `RandomNumberGenerator` local por sistema/run, com seed recebida explicitamente.
- Não depender de `hash()`, ordem incidental de Dictionary ou relógio local para desafios determinísticos.
- Separar seed de run, seed diária e seed semanal.
- Registrar seed e parâmetros relevantes nos dados de diagnóstico, se o jogador tiver habilitado métricas.
- Um mesmo conjunto de seed + versão de regras deve produzir o mesmo resultado lógico.

## 8. Godot: ciclo de vida, animação e input

- Não acessar `World3D`, câmera ou viewport antes de a cena estar no estado de árvore exigido pela API.
- Criar nós, conectar sinais e então iniciar animações. Se o objeto for removido durante um `await`, validar sua existência antes de continuar.
- Bloquear input durante giros/transições; liberar somente após o estado lógico e a apresentação estarem sincronizados.
- `queue_free()` não é destruição imediata; não reutilizar o nó no mesmo fluxo sem validar.
- UI deve consumir sinais/estado e nunca capturar input destinado ao cubo fora de sua área.
- Reusar os temas e componentes visuais C5/C8; não introduzir outro sistema de estilo.
- Não adicionar dependência de renderer que quebre GL Compatibility.

## 9. Padrões de código reutilizáveis

### Serviço com armazenamento injetável

~~~gdscript
extends RefCounted
signal changed

const Store = preload("res://scripts/c4/save_store.gd")
const VERSION := 1

var store: Store
var writable := true
var last_error := ""

func configure(adapter: Store) -> void:
    store = adapter
    # Carregar, validar e preservar arquivos incompatíveis.
    # Não gravar defaults por cima de um arquivo desconhecido.
    changed.emit()
~~~

O exemplo é um esqueleto, não um arquivo pronto para copiar sem adaptar o schema e os limites do domínio.

### Escrita idempotente

~~~gdscript
func commit_event(event_id: int, payload: Dictionary) -> bool:
    if event_id <= 0 or not writable or store == null:
        return false
    if seen_ids.has(event_id):
        return true
    var candidate := records.duplicate(true)
    # Validar e aplicar payload somente na cópia.
    if not store.write_json({"version": VERSION, "records": candidate}):
        last_error = "Falha ao persistir evento."
        return false
    records = candidate
    seen_ids.append(event_id)
    changed.emit()
    return true
~~~

A coleção de IDs também precisa estar dentro do documento gravado; o exemplo apenas demonstra a ordem validar → gravar → publicar estado.

### Seed determinística

~~~gdscript
var rng := RandomNumberGenerator.new()
rng.seed = seed_value
var index := rng.randi_range(0, pool.size() - 1)
~~~

Não chamar `randomize()` em um fluxo que precise ser reproduzível.

## 10. Testes obrigatórios

Para cada checkpoint, selecionar testes conforme o risco:

- **Unitário:** regras, limites, determinismo, cálculo, serialização e idempotência.
- **Integração:** cena fria sem cache, autoloads, navegação, modo ativo, save isolado e regressão dos sistemas anteriores.
- **Manual Windows:** câmera, legibilidade, mouse/controle, animações, áudio, modais e escala de interface.
- **Build:** importação limpa, suíte headless e exportação Windows x86_64 no commit candidato.
- **Regressão:** Normal, Diário, Semanal, Bestiário, contratos, Oficina, Rotas, Fever, histórico, medalhas, conquistas e laboratório, conforme a base integrada.

Padrão de execução local, ajustado aos scripts presentes:

~~~powershell
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/unit/test_cXX_feature.gd
godot --headless --path . --script res://tests/integration/test_cXX_feature.gd
~~~

O workflow `.github/workflows/godot-c0.yml` deve continuar cobrindo inicialização fria, testes e importação. `.github/workflows/windows-export.yml` deve produzir a build candidata. Conferir os comandos reais do workflow antes de adicionar etapas redundantes.

## 11. Fluxo GitHub de um checkpoint

1. Confirmar que o checkpoint anterior foi aprovado pelo usuário e integrado à main.
2. Atualizar main e registrar o SHA de base.
3. Criar uma branch única, por exemplo `dev/checkpoint-17-accessibility`.
4. Implementar uma fatia vertical pequena, com lógica, UI, persistência (se necessária) e testes.
5. Executar importação limpa, testes e exportação Windows.
6. Abrir PR com escopo, arquivos, riscos, testes e instruções de teste manual.
7. Deixar o PR aberto para o usuário testar. Não mesclar automaticamente.
8. Após aprovação explícita, mesclar; então começar o checkpoint seguinte a partir da nova main.

Não empilhar C17–C30 em branches agora. A documentação pode antecipar dependências, mas cada implementação deve partir da última base aceita.

## 12. Definition of Done

- Regra e fluxo documentados antes do código.
- Contratos de dados e eventos definidos; nenhuma segunda fonte de verdade.
- Testes unitários, integração e regressão aprovados.
- Inicialização limpa e export Windows aprovadas no commit do PR.
- Executável testado fora do editor pelo usuário quando houver alteração de UX/gameplay.
- Testes visuais em 1280×720 e 1920×1080, além de 16:10/21:9 quando houver layout.
- Saves antigos preservados; sem duplicação de moedas, XP, resultados ou conquistas.
- PR descreve o que mudou e o que não mudou; merge somente após aprovação do usuário.
