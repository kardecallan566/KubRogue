# C12 — Medalhas e Maestrias do Jardim

**Branch:** `dev/checkpoint-12-garden-medals` · **Godot:** 4.7.2 Compatibility · **Status:** aguardando validação do usuário.

## Objetivo

A auditoria transversal pós-C10 foi aprovada e entrou na `main` pelo PR #12 (`c2b0b7c`). C12 adiciona uma progressão de coleção **permanente, legível e retroativa**, sem modificar a moeda, as chances de rota, os tempos, os cubos nem os salvamentos existentes.

## Medalhas permanentes

O Bestiário agora contém três abas: **CUBOS**, **MEDALHAS** e **CONTRATOS**. A tela inicial permanece com os mesmos quatro botões. **12 medalhas** têm ícone, título, critério, progresso numérico e indicação de desbloqueio.

| Medalha | Objetivo |
|---|---|
| Primeiro Giro | 1 cubo resolvido |
| Mão Treinada | 20 cubos acumulados |
| Lendário do Jardim | 100 cubos acumulados |
| Brilho do Ouro | 1 Dourado |
| Quebra-Armadura | 1 Blindado |
| Quatro Camadas | 1 Mestre 4×4 |
| Cinco Camadas | 1 Titã 5×5 |
| Derrote a Elite | 1 Elite 3×3 |
| Colecionador | Descobrir 3 espécies |
| Jardim Completo | Descobrir 7 espécies |
| Ritmo de Fever | Melhor combo de 4 |
| Ritmo Imparável | Melhor combo de 8 |

**Retroatividade por design:** a coleção é derivada exclusivamente das contagens persistentes de `KubeJournal` e do recorde `best_combo` de `KubeSession`. Um jogador que já alcançou os objetivos em C8–C10 os verá desbloqueados imediatamente. **Nenhum novo arquivo, migration, reset ou alteração de schema**.

## Maestria por espécie

Cada uma das sete espécies tem três faixas de maestria, calculadas pela quantidade de cubos daquela espécie já resolvidos:
- **Bronze:** 5 resoluções
- **Prata:** 20 resoluções
- **Ouro:** 50 resoluções

Os cards revelados exibem faixa e próximo alvo, com progressão gradual sem itens ou moedas extras. Espécies bloqueadas não mostram informações que identifiquem o cubo.

## Feedback durante a partida

Uma medalha nova é detectada após pagamento durável e registro da solução no Bestiário; uma notificação discreta aparece temporariamente na HUD, sem modal, sem pausar cubos e sem criar um botão adicional. Ao reiniciar a run, medalhas já desbloqueadas são reavaliadas a partir dos saves e **não disparam avisos repetidos**. O combo atual pode anunciar um desbloqueio e é normalmente salvo no histórico ao concluir uma onda ou retornar à hub.

## Garantias e testes

- C0–C10 e a auditoria continuam disponíveis e não foram sobrescritos; cenas anteriores permanecem.
- Dinheiro e XP não são recalculados pelas medalhas.
- Ao jogar em modo diário a seed e os recordes permanecem os mesmos.
- O único conteúdo gráfico novo é desenhado pelo próprio Godot, sem novas texturas a importar.
- Unitários cobrem 0→1→20→100 cubos, contagens herdadas, 7 espécies, níveis 5/20/50, combos 4/8, reinício e ausência de duplicações.
- Integração cobre o menu de 4 botões, as três abas, galeria de 7 espécies, 12 medalhas, 3 contratos, primeira resolução 2×2 real, aviso e persistência após nova cena.
- Cold boot antes da importação de assets do Godot, a suíte C0–C12 e exportação Windows.

**Checklist Windows:** abrir em 1280×720 e 1920×1080; visitar cada aba; resolver um cubo e conferir medalha; voltar à hub e ver 1/12; verificar contas antigas com medalhas retroativas; testar maestrias após 5/20/50 resoluções; confirmar Cubos 4×4/5×5, Rotas, Oficina e Fever sem mudanças.

**Merge na main somente após aprovação do usuário.**
