# 08 — Roadmap de pré-produção até o primeiro MVP

## 0. Estado do repositório

C0 e C1 estão integrados à **main** após CI e aprovação visual do usuário. A branch **dev/checkpoint-02-waves-economy** traz uma prévia de duas ondas com economia por partida, estabilidade e dois tipos 2×2; C3–C5 seguem futuros, ainda não há MVP completo.

## 1. Fluxo de desenvolvimento sugerido

Manter **main** sempre legível. Para o código, trabalhar por branches curtas do tipo **dev/checkpoint-01-core**, testar, revisar e somente integrar após validação. Para alterações de documentação de concepção, registrar decisão e motivação. Não declarar conclusão sem rodar no Godot.

## 2. Checkpoints detalhados

### C0 — Pré-produção e prova do asset

**Entregas:** ler documentação, registrar versão real do Godot, identificar o modelo 3D disponível, formato/licença, peças e materiais; criar inspeção/protótipo apenas quando começar implementação. Definir Camera3D ortográfica fixa de visão superior, área útil invisível, terreno gramado contínuo e escala de cubos/mão.

**Aceite:** equipe entende se o modelo permite giros de faces. Se não, há um fallback procedural decidido, sem bloquear produto.

**Resultado de C0:** o cubo procedural 3×3 do projeto Kubos foi reaproveitado com seus 26 cubinhos/54 adesivos e rotação de camadas; integrado em main.

### C1 — Núcleo da solução 3D (primeira fatia jogável)

**Entregas:** projeto abre; câmera top-down fixa, **campo verde aberto sem borda**, mão visível que segue mouse; um cubo 2x2 com peças e cores; embaralhamento determinístico; clique/segurar gira camada corretamente; solução emite sinal, recompensa provisória visível.

**Aceite:** uma pessoa resolve 10 cubos seguidos sem perder sincronização de estado ou entrada. Movimento de uma camada é convincente e rápido. Sem menus complexos nem meta loja.

**Gate de decisão:** o gesto de resolver cubos é divertido? Se não, ajustar antes de prosseguir.

### C2 — Uma onda real com economia

**Entregas:** spawn limitado e temporizado, dois tipos de 2x2 (aprendiz/reforçado), timer, estabilidade, moedas/XP corretos, alvo, HUD, resumo de onda, condição de perda.

**Aceite:** jogador entende o que fazer, ganha moedas apenas ao finalizar, pode perder sem travar, e a cena reinicia sem duplicidade. FPS observado com 4 cubos.

### C3 — Progressão roguelite numa run

**Entregas:** níveis por XP 5/12/21/32/45, ofertas 1/3 **durante a run**, oito cartas com efeitos reais, sinergias, combo, cinco ondas com dados balanceáveis e modelo 3x3 elite.

**Aceite:** duas runs podem produzir builds distintas; cartas alteram números, feedback e escolhas. Vitória e derrota atingíveis; elite gira camadas próprias.

### C4 — Hub, loja e save persistente

**Entregas:** fluxo hub->arena->resultado->hub, três melhorias meta, transações, persistência versionada, configuração, recorde, tutorial.

**Aceite:** moedas persistem após sair/perder; melhorias custam saldo real, não duplicam; primeira run tem ajuda; segunda run já apresenta progresso adquirido.

### C5 — Polimento e empacotamento do MVP

**Entregas:** identidade visual consistente, sfx/música, VFX leves, legibilidade, acessibilidade básica, revisão de performance, documentação de controles e build Windows.

**Aceite:** passar roteiro T1–T10 no documento 07, testes de seeds, salvar e reabrir, executar build fora do editor e registrar limites conhecidos.

## 3. Dependências críticas

C0 precede uma integração definitiva do modelo. C1 deve ser aprovado antes de C2–C5. C3 depende de PuzzleState já testado, para não inventar a solução de 3x3 visualmente. C4 só requer economia funcional, não requer loja monetizada. C5 não “corrige” falha estrutural do controle da mão: se C1 estiver ruim, é melhor retornar.

## 4. Backlog detalhado ordenado

| Prioridade | Item | Critério de teste | Checkpoint |
|---|---|---|---|
| P0 | Validar asset/licença e pivôs | Relatório claro 2x2/3x3 | C0 |
| P0 | Estado lógico + movimentos legais | Embaralhar/reverter 1000 seeds | C1 |
| P0 | Apresentação 3D por camadas | Estado visual sempre igual lógico | C1 |
| P0 | Mão, foco e clique/segurar | Alvo único, cooldown estável | C1 |
| P0 | Resolução e pagamento idempotente | Uma solução = um crédito | C2 |
| P0 | Spawn periférico e timer | Sem deadlock, só spawns apresentados penalizam; reservar elite | C2 |
| P0 | Estabilidade e derrota | Perdas reproduzíveis | C2 |
| P0 | XP, cartas e efeitos | Todos os 8 efeitos testados | C3 |
| P0 | Elite 3x3 + conclusão de run | Vitória reproduzível | C3 |
| P0 | Save, hub e loja permanente | Compra e relançamento sem perda | C4 |
| P0 | Tutorial e interface completa | Jogável sem instrução externa | C4 |
| P0 | Export Windows e regressão | T1–T10 aprovados | C5 |
| P1 | Acessibilidade adicional de símbolos | Daltônicos distinguem faces | C5 |
| P1 | Otimização de efeitos/pooling | Sem picos fortes na onda 5 | C5 |
| P2 | 4x4, modos manuais e desafios diários | Protótipos após avaliação | Pós-MVP |
| P2 | Gamepad/mobile e Steamworks | Plano posterior de plataformas | Pós-MVP |

## 5. Pós-MVP (hipóteses, não promessas)

**Conteúdo:** 4x4/5x5, cubos fantasmas ou com faces travadas, arenas, chefes especiais, centenas de seeds, skins e mãos.

**Profundidade:** modo puzzle de solução manual separado do combate arcade, rerolls de cartas, desafios semanais com seed fixa, sinergias inéditas.

**Distribuição:** localização EN, Steam achievements/cloud e suporte às demais plataformas, apenas após consolidar versão Windows e requisitos reais.

**Sistemas sociais:** leaderboard opt-in e sem coleta invasiva, somente se produto justificar backend e política de privacidade.

## 6. Como registrar conclusão de um checkpoint

Para cada entrega, guardar número de build/commit, resumo das mudanças, como executar, evidência de testes, screenshots ou vídeo curto, problemas remanescentes e checklist. Uma implementação parcial é marcada **parcial**, nunca “100%” por ter arquivos criados.

## 7. Risco de aumento de escopo

O principal risco é substituir o loop de resolver com dezenas de sistemas adicionais. Exigir resposta positiva a três perguntas antes de novas features: **a mão é gostosa de controlar? Os cubos se resolvem de verdade? O jogador quer tentar outra run?**

## 8. Verificações de planejamento adicionais

**C0:** confirmar captura/referência de campo gramado e importar o modelo existente só quando disponibilizado. **C1:** validar mapa top-down + input em 720p/1080p e o giro real 2x2 antes de prosseguir. **C2:** testar spawn visível e regra de só penalizar alvos apresentados. **C3:** validar pausa de cartas em meio à onda, elite com vaga reservada e cinco ofertas úteis. **C4:** garantir moeda persistida antes do efeito de pagamento e menu coeso com visual de gramado/oficina. **C5:** comparar visuais com referências para verificar **originalidade**, não semelhança pixel a pixel.

A especificação de mundo está no [11](11-mapa-campo-aberto-e-camera.md) e o microfeedback no [12](12-gamefeel-eventos-visuais-e-detalhamento.md).

## 9. Execução real do C0

Foram localizados os scripts procedurais do 3×3 no [Kubos](https://github.com/kardecallan566/Kubos). O KubRogue passa a ter um projeto Godot isolado para inspeção do modelo, sem importar a economia ou interface do outro jogo. O checkpoint exige teste headless, CI e validação gráfica manual antes de avançar. Consulte [auditoria de asset](checkpoints/C0-kubos-asset-audit.md) e [checklist](checkpoints/C0-test-plan.md).

## 10. Implementação C1 em validação

A branch `dev/checkpoint-01-hand-2x2` contém um **2×2 verdadeiro (8 cubinhos/24 adesivos)** com estado discreto, sequências inversas determinísticas, e reutiliza a apresentação por pivôs do 3×3. O cursor de mão estilizada **2D** segue a posição do mouse na interface sobre o gramado e um clique/segurar próximo ao alvo consome exatamente um giro por cooldown. Um contador provisório concede +10 moedas e +1 XP ao resolver; novos cubos são gerados automaticamente. **Não existe economia persistente ainda.** O C0 permanece acessível.

Para aceitar C1: rodar o CI, testar 10 resoluções seguidas dentro de janela gráfica, observar fluidez da mão e alinhamento de adesivos em movimento. Critérios completos em [C1](checkpoints/C1-hand-2x2.md). **Sem merge na main** antes desse gate visual.

## 11. Correção do C1 após primeiro playtest gráfico (2026-10-13)

A captura do Windows mostrou cubos 2×2 com **vãos largos entre peças** devido à conversão de coordenadas inteiras ±1 para posições 3D usando o passo do 3×3. A correção deixa o domínio intacto e usa `STEP/2` apenas para as oito peças do 2×2. Também houve mudança de direção: a mão passa a ser um **cursor 2D**, sem malha 3D. Um teste automatizado agora confirma costuras compactas antes e depois da animação, e testes de cena verificam Control/CanvasLayer e mouse_filter. Avaliar visualmente antes do merge do C1.

## 12. Implementação do C2 (prévia de duas ondas)

A branch `dev/checkpoint-02-waves-economy` introduz `KubRogueWaveDirector` (fila, spawn, cronômetro, limite de quatro atores, penalidade somente por cubos apresentados, transição de ondas e vitória/derrota), `KubRogueRunWallet` (pagamento idempotente, dinheiro e XP somente em memória) e `KubRogueC2Stage` (campo e mão 2D já aprovados, seleção de alvos, giro real, variante reforçada, pausa e resumo).

As duas ondas existem **para validar mecânica e pacing**. C3 continuará responsável por cinco ondas, elite 3×3, XP de level-up e escolhas de habilidades. C4 implementará carteira persistente e loja. No C2, moedas são perdidas ao fechar a run propositalmente.

Gate: CI verde e teste gráfico no Windows de movimentos dos vários cubos, seleção sem atravessar HUD, timeout, moeda única, estabilidade, pausa e duas transições. Ver [C2](checkpoints/C2-waves-economy.md).

## 13. Checkpoint C3 implementado em branch

O C2 foi aprovado pelo usuário, passou no CI e entrou na `main` pelo PR #3. A branch `dev/checkpoint-03-roguelite` acrescenta cinco ondas, a elite 3×3 verdadeira (26 peças/54 adesivos), XP e cartas de upgrade temporário. `KubRogueC3Director` reaproveita a direção de ondas do C2 por composição/herança, preservando cenas antigas. `KubRogueRunBuild` mantém catálogo de oito cartas, ofertas exclusivas, níveis máximos, efeitos e limiares de XP. A economia de C3 permanece em memória, sem loja/salvamento. Gate: CI do Godot e teste manual com a mão 2D; não integrar até aprovação. [Checklist](checkpoints/C3-roguelite.md).

## 14. C4 — Hub, melhorias, save e tutorial (em validação)

Após aprovação do C3 e merge do PR #4, a branch `dev/checkpoint-04-hub-save-shop` entrega um fluxo novo: **Hub → tutorial no primeiro jogo → cinco ondas → resultado → Hub/Loja**. O saldo persistente é administrado por `KubRogueProgress` e nunca diretamente pela HUD. Transações são feitas em arquivo temporário e backup, com identificadores de cubos únicos em cada run, prevenção de pagamentos duplicados e registro de nível e compras. Três melhorias permanentes afetam cooldown, moedas e estabilidade. Configurações e recordes entram no mesmo arquivo versionado.

Há testes separados de persistência, preço, saldo, recuperação de backup, tutorial e pagamento pela arena, além da suíte C0–C3. **Gate antes de merge:** CI, teste visual da hub e loja em 720p/1080p, replay do tutorial, reinício do jogo com saldo e melhorias preservados, derrota seguida de retorno à hub. Confira [C4](checkpoints/C4-hub-save-shop.md).

## 15. C5 — Efeitos, áudio original, acessibilidade e Windows

Após aprovação do usuário, o C4 entrou na `main` pelo PR #5. O C5 mantém esse gameplay estável e adiciona polimento via cenas próprias (hub/arena), `KubeAudio` autoload gerando som PCM em memória, partículas leves em `CanvasLayer` obedecendo a configuração de redução de partículas, shake opcional, `MultiMesh` para grama, modais roláveis e estilo visual consistente. `export_presets.cfg` configura Windows Desktop GL Compatibility, e um workflow `workflow_dispatch` produz pacote Windows para teste manual com templates oficiais da mesma versão. O pacote **não é declarado pronto sem export real e teste no Windows**. [Checklist C5](checkpoints/C5-polish-windows.md).

## 16. C6 — Primeiro pós-MVP: desafio diário offline e reroll

Após testes e aprovação gráfica do C5, PR #6 integrado na `main`. A primeira expansão pós-MVP fica em `dev/checkpoint-06-daily-challenge`. Mantém o Jardim dos Cubos, a mão 2D aberta/fechada, cinco ondas, economia e UI. Adiciona modo diário de seed UTC reproduzível, recordes locais em arquivo separado e exatamente um reroll de 3 cartas por run. Não inclui serviços externos, pagamentos ou tabelas públicas. [Critérios](checkpoints/C6-daily-challenge.md). Requer CI C0–C6 e avaliação de fluidez do jogador.

## 17. C7 — Cubos especiais em ondas do Jardim

O C6 foi testado e aprovado no Windows, com merge do PR #7 na main. A branch `dev/checkpoint-07-special-cubes` incrementa o bestiário usando **dois novos cubos 2×2**: Dourado (paga mais) e Blindado (demanda mais giros e concede mais XP), com decalques e materiais legíveis sem modificar cores dos adesivos. O total de inimigos, duração das cinco ondas e contrato de elite 3×3 não mudam. Novos scripts separam regras do diretor C7, carteira C7 e cosméticos; C0–C6 continuam disponíveis. CI testa a lógica, resolução com cubo 3D e salvamento transacional, em seguida build Windows. [Plano](checkpoints/C7-special-cubes.md).

## 18. Expansão C7 — 4×4 e 5×5 como alvos avançados

No mesmo PR do C7, adicionar estado genérico NxN para dimensões 4 e 5, com giros internos, modelo de cubies compactos e adesivos, histórico reversível e animação física por pivot. Um Mestre 4×4 na quarta onda e um Titã 5×5 na quinta substituem alvos sem multiplicar spawns nem afetar a elite 3×3. Pagamentos individuais só após solução. CI valida reversão de camadas internas, integridade geométrica e saldo persistente, além da exportação Windows.

## 19. C8 — Bestiário e objetivos que reforçam o loop

Após merge do C7 na main, o C8 coleciona os sete tipos de cubos efetivamente resolvidos, salva contagens num arquivo independente e cria três contratos **por run**. A recompensa do contrato faz parte do crédito idempotente da solução que o completou; não existe botão de reclamar moedas nem endpoint adicional. Interface compacta na hub e HUD, sem alterar o campo gramado, o modelo NxNxN e as cinco ondas. [Checklist detalhado](checkpoints/C8-bestiary-contracts.md). CI deve reproduzir partidas reais, idempotência, abertura limpa e exportação Windows, seguido de aprovação visual do usuário.

## 20. C9 — Rotas do Jardim: eventos com risco e recompensa

Após a aprovação do C8.2 (PR #9 integrado à main), experimentar o C9 com um encontro opcional entre ondas: **duas cartas de rotas determinísticas por seed de run e índice da onda**, com uma escolha ou skip. Quatro alternativas possíveis mudam só a onda imediatamente posterior: Relâmpago (-tempo/+moedas), Refúgio (+estabilidade/-tempo), Dourada (substituir um Aprendiz por Dourado), Torre (+tempo/-estabilidade). A Oficina e o Bestiário existentes não são modificados; a elite 3×3 da onda final permanece obrigatória. A moeda é creditada pelo processo atômico original. Testes C0–C9, exportação Windows e validação visual obrigatórios. [Checklist C9](checkpoints/C9-garden-routes.md).

## 21. C10 — Combo Fever e feedback de progressão

Após aprovação do C9 (PR #10 integrado na main), C10 combina um motor de combo/fever testável e HUD dedicada, com a meta de tornar as resoluções mais satisfatórias sem poluir menus. A cada quatro soluções em sequência (máximo 12s entre acertos) ativa FEVER: bônus de +20% em moedas do cubo dentro do multiplicador existente, duração 9s e +1s por cubo durante a janela (máximo 6s por onda). O relógio funciona somente em combate ativo; pausa e modais não o consomem. Devolve efeitos de ouro e som original da camada C5. Economias C4/C8, Rotas C9 e saves ficam intactos. CI C0–C10, exportação Windows e teste visual obrigatórios. [Checklist](checkpoints/C10-combo-fever.md).

## 22. C12 — Resultados, medalhas e Salão de Medalhas

A auditoria C11 aprovada foi integrada ao C10 estável. A próxima etapa não adiciona jogabilidade de combate: transforma o encerramento de uma partida em um painel visual com medalha determinística e estatísticas (ganhos, contratos, Fever, XP e combo), e acrescenta o Histórico local das últimas 12 runs concluídas dentro do Bestiário. Moedas e upgrades antigos não são modificados; o novo save separado usa run ID persistido e rejeita duplicidade/versões incompatíveis. [Critérios completos](checkpoints/C12-results-medals.md). Requer regressão C0–C10, auditoria, build Windows e validação visual.
