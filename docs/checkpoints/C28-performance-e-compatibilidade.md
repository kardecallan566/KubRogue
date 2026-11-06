# C28 — Performance e compatibilidade

**Estado:** planejado; nenhum código C28 existe. **Base:** C27 concluído ou formalmente dispensado. **Branch sugerida:** `dev/checkpoint-28-performance`.

## Objetivo

Medir o jogo completo em hardware real e otimizar apenas gargalos comprovados. A meta inicial é 60 FPS, mas o critério final deve considerar frame-time estável e hardware-alvo documentado.

## Cenários de benchmark

- Hub e Bestiário com todas as abas.
- Combate com quatro cubos ativos, variante Nebuloso/Selado e efeitos.
- Chefe C22 em transição de fase.
- Biomas C21 com partículas ligadas/desligadas.
- Laboratório 5×5 com giros de camada interna.
- Troca repetida de cena durante 20 runs.

Registrar CPU main thread, GPU/frame time, memória, quantidade de nós/objetos e picos de alocação. Repetir cada cenário pelo menos três vezes no mesmo hardware e build.

## Estratégia de otimização

1. Estabelecer baseline com build Windows exportada.
2. Identificar top 3 hotspots por profiler.
3. Alterar uma causa por commit e repetir o mesmo benchmark.
4. Usar pooling de VFX somente se criação/destruição aparecer como gargalo; caso contrário, manter simplicidade.
5. Reutilizar materiais e meshes; preservar MultiMesh para vegetação; evitar instâncias desnecessárias.
6. Evitar loops de busca na árvore por frame; manter referências válidas e limpar sinais.
7. Medir antes/depois; não aceitar otimização que cause divergência visual ou de estado.

## Implementação por arquivo

- `tests/performance/perf_scenarios.gd`: cenários repetíveis com seed e duração fixa.
- `scripts/c28/performance_recorder.gd`: agregação de frame-time e contagem de objetos, somente em debug/benchmark.
- `scripts/c28/vfx_pool.gd`: criar apenas se profiling justificar.
- Atualizações localizadas nos sistemas que o profiler apontar; evitar reescrita geral de gameplay.
- `docs/performance-baseline.md`: hardware, versão, configurações, resultados e comparação.
- `tests/integration/test_c28_scene_lifecycle.gd`: vazamentos de nós/sinais e troca de cenas.

## Testes e aceitação

- 60 FPS como alvo médio na configuração-alvo; registrar p95/p99 frame-time, não só média.
- Sem crescimento contínuo de memória após 20 ciclos de run.
- GL Compatibility e export Windows continuam funcionais.
- 1280×720, 1920×1080, 16:10 e 21:9 sem regressão visual.
- Otimizações preservam seeds, snapshots, pagamentos e resultados.
- Toda otimização tem medição comparável anexada ao PR.

**Fora do escopo:** otimizar preventivamente, migrar renderer sem motivo ou remover efeitos sem aprovação visual.
