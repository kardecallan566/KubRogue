# KubRogue — Estado geral do projeto e roadmap

> **Revisão consolidada: 27/10/2026.** Este documento separa o que está integrado à branch principal, o que já foi implementado mas aguarda avaliação e o que continua sendo uma intenção de roadmap. Os estados foram conferidos no GitHub; aprovação automatizada não substitui teste visual/jogável.

## 1. Resumo executivo

KubRogue é um jogo single-player roguelite arcade para PC, desenvolvido em Godot 4.7.2 com GDScript. O jogador controla uma mão estilizada pelo mouse e resolve cubos tridimensionais por giros reais de camadas, enquanto administra cinco ondas, estabilidade, moedas, experiência, habilidades, variantes de cubos e escolhas entre ondas.

**Estado real neste momento:**

- **Main:** checkpoints C0–C13 integrados. Commit de referência: **01dce0dfac0cd8d9f2bf0fa85c13209f394aa733**.
- **C14 — Conquistas e Maestrias:** implementado no PR #16; CI Godot e exportação Windows aprovados; aguarda avaliação visual/jogável.
- **C15 — Desafio Semanal:** implementado no PR #17, dependente do C14; CI e exportação Windows aprovados; aguarda avaliação visual/jogável.
- **C16 — Laboratório do Cubista:** implementado no PR #18, dependente do C15; CI e exportação Windows aprovados; aguarda avaliação visual/jogável.
- **Próxima prioridade:** validar e integrar em ordem C14 → C15 → C16. Ainda não há um checkpoint C17 formalmente definido.

Não declarar C14–C16 como parte da versão principal até que os testes manuais sejam aprovados e os PRs integrados.

## 2. Estado do GitHub e dependências

| Entrega | Estado | Branch / PR | Evidência automatizada |
|---|---|---|---|
| Main C0–C13 | Integrado | [Main](https://github.com/kardecallan566/KubRogue/tree/main) · [PR #15 — C13](https://github.com/kardecallan566/KubRogue/pull/15) | C12 e C13 foram integrados; main está no commit indicado acima |
| C14 — Conquistas do Jardim | Implementado; avaliação manual pendente | [PR #16](https://github.com/kardecallan566/KubRogue/pull/16) · **dev/checkpoint-14-garden-achievements** · **62edbfce** | [Testes Godot](https://github.com/kardecallan566/KubRogue/actions/runs/38861444954) · [Build Windows](https://github.com/kardecallan566/KubRogue/actions/runs/38861440962) |
| C15 — Desafio Semanal | Implementado; avaliação manual pendente | [PR #17](https://github.com/kardecallan566/KubRogue/pull/17) · **dev/checkpoint-15-weekly-challenge** · **d7010a61** | [Testes Godot C0–C15](https://github.com/kardecallan566/KubRogue/actions/runs/38956603814) · [Build Windows](https://github.com/kardecallan566/KubRogue/actions/runs/38956603868) |
| C16 — Laboratório do Cubista | Implementado; avaliação manual pendente | [PR #18](https://github.com/kardecallan566/KubRogue/pull/18) · **dev/checkpoint-16-cube-laboratory** · **317cd945** | [Testes Godot C0–C16](https://github.com/kardecallan566/KubRogue/actions/runs/39073705162) · [Build Windows](https://github.com/kardecallan566/KubRogue/actions/runs/39073705156) |

Os PRs são intencionalmente empilhados: #16 parte de main; #17 parte de C14; #18 parte de C15. Depois de cada aprovação, retargetar o próximo PR para a nova main e executar novamente a suíte e a exportação antes de continuar.

**PR #14 é uma alternativa antiga de C12 sobre medalhas/maestrias e não é a trilha atual.** Não o integrar: sua proposta foi reaproveitada de forma não destrutiva no C14 (PR #16), preservando os resultados C12 e o painel de carreira C13. Ele pode ser encerrado/arquivado quando a trilha principal estiver consolidada.

## 3. O produto e os princípios que queremos preservar

- **Fantasia:** um Jardim dos Cubos gramado, claro e aberto, onde a mão do jogador organiza cubos coloridos sob pressão.
- **Controle principal:** mouse e cursor de mão 2D; clique/segurar aciona giros de camadas com animação física e estado lógico consistente.
- **Partida principal:** cinco ondas, até quatro cubos ativos, estabilidade, recompensas por solução real e elite 3×3 obrigatória na última onda.
- **Progressão roguelite:** XP e escolha de habilidades durante a run; moedas e dados persistentes ficam separados dos recursos temporários da partida.
- **Puzzle honesto:** os cubos usam estados matemáticos e giros legais. Na arena, o jogo guia a resolução pela inversão de um embaralhamento conhecido; o Laboratório C16 dá controle manual e dicas baseadas no histórico inverso. Não é anunciado um solver geral mínimo para qualquer estado arbitrário.
- **Apresentação:** campo aberto sem paredes ou bordas de palco, câmera fixa quase superior no combate, cubos 3D legíveis, interface arcade original, áudio procedural original e opção de reduzir partículas.
- **Escopo atual:** single-player, offline, Windows como plataforma prioritária, sem login, compras com dinheiro real, anúncios, telemetria externa ou backend obrigatório. A inspiração em outros jogos é apenas de ritmo/estrutura; arte, UI, áudio, nomes e implementação devem permanecer originais.

## 4. O que já está pronto e integrado na main (C0–C13)

### C0–C3 — Núcleo de jogo e combate

- **C0 — Inspeção 3D:** adaptação do cubo procedural 3×3 do projeto Kubos para uma cena técnica separada; 26 cubinhos e 54 adesivos, inspeção e testes de estado/rotação.
- **C1 — Primeira interação real:** cubo 2×2 com 8 cubinhos e 24 adesivos, cursor de mão 2D, seleção por mouse, giros legais por camada, animação e embaralhamento reproduzível.
- **C2 — Ondas e economia da run:** spawn com limite de atores, timer, estabilidade, cubos Aprendiz/Reforçado, pausa e resumo; só cubos efetivamente apresentados podem penalizar a estabilidade.
- **C3 — Roguelite completo:** cinco ondas, elite 3×3, XP e escolhas de uma entre três cartas. Oito habilidades com efeitos reais: Pulso Ágil, Dedo Certeiro, Luva Magnética, Bolsa Encantada, Ritmo de Mestre, Fôlego Extra, Olhar de Cubista e Mão Paciente.

### C4–C8 — Hub, salvamento, conteúdo e objetivos

- **C4 — Hub e persistência:** tutorial inicial, saldo persistente, recordes, preferências e transações protegidas contra duplicação, com backup e recuperação de saves.
- **C5 — Polimento:** identidade visual arcade, HUD e cards revisados, áudio/música sintetizados localmente, feedback visual, partículas configuráveis, tremor opcional, gramado otimizado e workflow de exportação Windows.
- **C6 — Desafio Diário:** seed determinística por data UTC, tentativas e recordes locais separados da carteira, e uma troca de trio de cartas por run.
- **C7 — Cubos especiais e tamanhos avançados:** cubos Dourado e Blindado; cubos reais Mestre 4×4 e Titã 5×5, incluindo giros de camadas internas. O conjunto possui sete espécies: Aprendiz, Reforçado, Elite 3×3, Dourado, Blindado, Mestre 4×4 e Titã 5×5.
- **C8 — Bestiário, contratos e Oficina:** descoberta persistente das espécies, três contratos por run, galeria visual e melhorias temporárias compráveis entre ondas. A hub foi simplificada para quatro ações principais: Jogar, Bestiário, Configurações e Sair.

### C9–C13 — Decisões, ritmo, integridade e carreira

- **C9 — Rotas do Jardim:** escolhas opcionais entre ondas com risco/recompensa, derivadas da seed; é possível seguir sem evento.
- **C10 — Combo Fever:** quatro resoluções em sequência, dentro da janela de combo, ativam Fever com bônus temporário de moedas, recuperação limitada de tempo e feedback dedicado.
- **C11 — Auditoria de regressão:** endurecimento de recuperação de saves, proteção de backups íntegros e de versões de schema desconhecidas, validação de datas UTC e testes de isolamento de arquivos.
- **C12 — Resultados e Salão de Medalhas:** resumo final com métricas reais e medalhas cosméticas; histórico local das 12 partidas concluídas mais recentes. Ouro requer vitória com pelo menos 70 de estabilidade, dois contratos e combo máximo de quatro ou mais; Prata exige vitória com pelo menos 35 de estabilidade; Bronze é a medalha base de vitória. Derrotas não recebem medalha. Medalhas não concedem moedas.
- **C13 — Painel de carreira:** métricas derivadas das últimas 12 partidas, como vitórias, taxa de vitória, maior sequência, medalhas, cubos, moedas e Fever. Filtros Todas/Normal/Diário alteram tanto os indicadores quanto os cards, sem criar um save adicional ou recompensas.

## 5. Implementado em branches, ainda não integrado (C14–C16)

### C14 — Conquistas permanentes e Maestrias do Jardim

- Doze conquistas derivadas retroativamente do progresso existente.
- Maestria por espécie: Bronze com 5 soluções, Prata com 20 e Ouro com 50.
- Bestiário com abas Cubos/Medalhas/Contratos; o Histórico e o painel C13 continuam acessíveis.
- Aviso de nova conquista após a gravação durável do progresso, sem recompensa monetária extra e sem repetir avisos antigos.
- Não cria um novo arquivo de save nem exige migração.

**Falta:** conferir visualmente as abas, notificações e maestrias em saves antigos e novos, em 1280×720 e 1920×1080, e aprovar o PR #16.

### C15 — Desafio Semanal offline

- Terceiro modo na seleção de jogo: Normal, Diário e Semanal, sem adicionar um quinto botão à hub.
- A semana vai de segunda a domingo em UTC; a mesma semana usa a mesma seed em qualquer tentativa.
- Recordes de tentativas, vitórias, melhor onda e maior número de cubos em arquivo separado, com retenção de até 52 semanas e proteção de versões desconhecidas.
- Histórico e carreira identificam partidas semanais e oferecem filtro Semanal.
- Não há serviço online, ranking remoto ou moedas extras.

**Falta:** validar visualmente os três modos, a virada de semana, a persistência e o filtro semanal; depois retargetar/revalidar o PR #17 após o merge de C14.

### C16 — Laboratório do Cubista

- Treino livre sem timer, moedas, XP, conquistas ou estatísticas.
- Cubos reais 2×2, 3×3, 4×4 e 5×5, com respectivamente 8/26/56/98 cubinhos e 24/54/96/150 adesivos.
- Seleção de faces F/R/U/L/D/B, camadas externas e internas quando disponíveis, giros de 90° e 180° e animação física por pivô.
- Novo embaralhamento por seed, repetição da mesma seed, dicas e aplicação de giros do histórico inverso.
- Ao resolver o estado lógico, o treino reconhece a conclusão sem conceder recompensas nem modificar saves da campanha.

**Falta:** avaliação manual da câmera, legibilidade dos painéis, giros internos 4×4/5×5, dicas, repetição de seed e ausência de efeitos colaterais; depois revalidar o PR #18 quando C15 estiver integrado.

## 6. Arquitetura, dados e ferramentas

- **Engine:** Godot 4.7.2, GDScript e renderer GL Compatibility. Janela-base 1280×720, com escala de interface.
- **Organização:** cenas/scripts por checkpoint; estado e movimentos de puzzle em **scripts/puzzle**, apresentação em **scripts/visual**, serviços de progresso/salvamento separados das cenas de gameplay, e testes unitários e de integração em **tests**.
- **Persistência local:** progresso/carteira, desafio diário, Bestiário, histórico e recordes semanais usam arquivos independentes. O arquivo semanal só passa a existir na trilha C15. O C16 não grava progresso de campanha.
- **Proteção de dados:** arquivos versionados, gravação segura com backup, IDs para evitar pagamentos/resultados duplicados e proteção contra sobrescrever dados de versão futura ou ilegíveis.
- **CI:** workflow de validação headless, inicialização sem cache/imports previamente gerados, importação/compilação, testes unitários e de integração e exportação Windows x86_64. Os workflows dos PRs atuais passaram nos commits identificados na seção 2.
- **Build Windows:** os workflows publicam artefatos de teste, não um instalador assinado. O artefato deve ser executado em Windows real antes de declarar a experiência visual/jogável aprovada.

## 7. Trabalho prioritário antes de ampliar o escopo

1. **Testar C14 no Windows:** Bestiário em abas, conquistas retroativas, limites 5/20/50, avisos e saves antigos.
2. **Aprovar/mesclar C14** somente após teste manual; então atualizar a base do C15 para main e repetir CI + build.
3. **Testar C15:** Normal/Diário/Semanal, seed estável durante a semana, recordes após reiniciar e filtro de histórico; integrar só depois da aprovação.
4. **Testar C16:** todas as dimensões, seis faces, camadas internas, giros de 90°/180°, dicas, resolução e repetição de seed; confirmar que moedas, run, Bestiário e histórico não mudam.
5. **Retargetar e integrar C16** só após C15 estar na main e passar novamente pelos gates.
6. **Playtest de balanceamento:** medir duração real de runs, taxa de vitória/derrota, cubos resolvidos, ritmo das cartas, moedas por minuto e desempenho. A meta inicial de 6–8 minutos e o alvo de 60 FPS são hipóteses a medir, não resultados já comprovados.
7. **Compatibilidade visual:** revisar 1280×720, 1920×1080 e proporções 16:10/21:9; testar cursor, HUD, cartas, modais e câmera sem sobreposição.
8. **Teste com jogadores:** o plano original propõe ao menos cinco pessoas sem instrução verbal, registrando tempo até a primeira solução, entendimento das moedas/XP, conforto de controle, dificuldade da elite e vontade de repetir a run.
9. **Fechar a trilha documental:** manter README, roadmap, critérios de aceitação e estado dos PRs alinhados; encerrar a branch alternativa antiga PR #14 quando for seguro.

## 8. Backlog futuro já mencionado nos documentos de planejamento

Os itens abaixo foram citados no planejamento original, mas **não são promessas de lançamento nem um checkpoint C17 aprovado**. A ordem final deve depender dos playtests e das prioridades do projeto.

### P1 — Qualidade, acessibilidade e estabilidade

- Distinguir cores de faces também por símbolos/formas, para melhorar a acessibilidade a pessoas daltônicas.
- Medir performance com várias runs, cubos e efeitos; aplicar pooling/otimização apenas se o profiler mostrar necessidade.
- Continuar a revisão de UX, responsividade, foco do cursor e clareza dos efeitos de habilidades.
- Verificar licenças/atribuições dos recursos usados e registrar os créditos necessários para distribuição.

### P2 — Mais conteúdo e variedade de gameplay

- Novas variantes de cubos, por exemplo fantasmas ou faces temporariamente travadas.
- Novas arenas/biomas e chefes especiais, mantendo a identidade visual própria do Jardim.
- Mais sinergias de habilidades, eventos e desafios com seeds; aumentar a variedade somente se melhorar a decisão durante as runs.
- Skins cosméticas e variações visuais da mão.
- Ajustes de balanceamento das ondas, dos cubos avançados, das rotas e das recompensas com base em dados de playtest.

### P2 — Distribuição e plataformas

- Localização para inglês.
- Avaliar controle por gamepad e suporte a outras plataformas, incluindo mobile, depois de estabilizar a experiência de PC.
- Avaliar Steamworks, conquistas da plataforma e Steam Cloud somente quando os requisitos de publicação e sincronização forem conhecidos.

### P3 — Recursos online opcionais

- Leaderboard opt-in apenas se houver uma justificativa real de produto, com backend, política de privacidade e proteção contra abuso desenhados antes da implementação.
- Nenhum login, telemetria, multiplayer, ranking online ou serviço externo é requisito da versão offline atual.

## 9. Critérios para considerar uma entrega concluída

Uma tarefa só deve ser marcada como pronta quando:

- A regra e o comportamento esperado estão documentados.
- Há testes adequados e eles foram executados no commit em análise.
- A inicialização limpa e a regressão dos checkpoints anteriores passaram.
- A exportação Windows foi gerada e o executável foi testado fora do editor.
- O layout foi conferido em resoluções relevantes e a interação real foi validada.
- Não há duplicação de recompensas, regressão de saves ou alteração colateral de modos antigos.
- O usuário aprovou a avaliação visual/jogável quando a mudança afeta a experiência.

**Regra de merge:** testes automatizados verdes são necessários, mas não suficientes. A main deve continuar sendo a versão integrada e aprovada; branches em avaliação não devem ser descritas como funcionalidades já presentes na main.

## 10. Documentos de referência

- [Visão e pilares](00-visao-e-pilares.md)
- [Jogabilidade e regras](01-jogabilidade-e-regras.md)
- [Cubos e resolução](02-cubos-e-resolucao.md)
- [Economia e progressão](03-economia-e-progressao.md)
- [Habilidades e sinergias](04-habilidades-e-sinergias.md)
- [Arte, UI e áudio](05-arte-ui-e-audio.md)
- [Arquitetura Godot](06-arquitetura-godot.md)
- [MVP e critérios de aceitação](07-mvp-e-criterios.md)
- [Roadmap e backlog](08-roadmap-e-backlog.md)
- [Testes, riscos e originalidade](09-testes-riscos-e-originalidade.md)
- [Balanceamento inicial](10-balanceamento-inicial.md)
- [Mapa, campo aberto e câmera](11-mapa-campo-aberto-e-camera.md)
- [Gamefeel e eventos visuais](12-gamefeel-eventos-visuais-e-detalhamento.md)
- [Auditoria de consistência](13-auditoria-de-consistencia.md)
- [PR #16 — C14](https://github.com/kardecallan566/KubRogue/pull/16) · [PR #17 — C15](https://github.com/kardecallan566/KubRogue/pull/17) · [PR #18 — C16](https://github.com/kardecallan566/KubRogue/pull/18)
