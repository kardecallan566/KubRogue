# 16 — Roadmap técnico C17–C30

> **Planejamento revisado em 06/11/2026.** Todos os checkpoints deste documento são propostas de trabalho. Não há código C17–C30 implementado, nem promessa de que todos serão lançados exatamente nesta ordem.

## 1. Ponto de partida

A main consultada está em C13. C14 (#16), C15 (#17) e C16 (#18) já possuem implementação e CI/build aprovados, mas continuam pendentes de teste manual e merge em ordem. O primeiro passo continua sendo validar e integrar C14 → C15 → C16. C17 só começa depois que C16 estiver na main.

Este roadmap foi construído em cima dos sistemas reais encontrados na base C16: Godot 4.7.2, GDScript, Compatibility, cenas/scripts por checkpoint, KubeSession, KubeAudio, KubeChallenge, KubeJournal, KubeHistory, SaveStore, estado lógico do puzzle e testes headless.

## 2. Visão geral

| Checkpoint | Nome | Entrega principal | Prioridade |
|---|---|---|---|
| C17 | Acessibilidade e conforto | Símbolos nas faces, contraste, escala de UI e opções de movimento | Alta |
| C18 | Métricas locais de playtest | Instrumentação local opt-in e exportação de dados sem rede | Alta |
| C19 | Cubo Nebuloso | Nova espécie com revelação visual progressiva | Média |
| C20 | Cubo Selado | Nova espécie com face temporariamente bloqueada e regra determinística | Média |
| C21 | Biomas do Jardim | Catálogo de arenas visuais determinísticas | Média |
| C22 | Guardião do Jardim | Chefe final em fases, com uma recompensa idempotente | Alta |
| C23 | Sinergias de habilidades | Combinações explícitas entre cartas existentes | Alta |
| C24 | Cosméticos e personalização | Temas de cubo e mão, sem vantagem de gameplay | Média |
| C25 | Localização PT-BR/EN | Sistema de tradução e preferência persistente | Alta |
| C26 | Controle por gamepad | Input semântico para menus, laboratório e combate | Média |
| C27 | Integração Steam (condicional) | Adaptador de conquistas e sincronização cloud | Condicional |
| C28 | Performance e compatibilidade | Profiling reproduzível e otimizações comprovadas | Alta |
| C29 | Release Candidate e QA | Congelamento funcional, regressão e playtest final | Alta |
| C30 | Preparação de lançamento | Versão 1.0, pacote, créditos, checklist e artefatos | Alta |

## 3. Fases e dependências

### Fundação — C17 e C18
Primeiro remover barreiras de leitura e controle e depois criar uma forma local, privada e opt-in de medir o comportamento real das partidas. C18 fornece evidência para ajustar as variantes, o chefe e as sinergias seguintes.

### Conteúdo — C19 a C23
Adicionar duas espécies sem quebrar o estado do puzzle, um sistema de biomas inicialmente visual, um chefe com fases e sinergias legíveis. Novas regras devem ser determinísticas e ter limites de dificuldade/recompensa.

### Apresentação e alcance — C24 a C27
Adicionar personalização cosmética, inglês, gamepad e, somente se o destino de distribuição for confirmado, Steam. O modo offline continua funcionando sem a plataforma.

### Estabilidade e entrega — C28 a C30
Medir antes de otimizar, congelar novas funcionalidades durante QA e preparar pacote reproduzível. C30 não publica automaticamente o jogo; publicação requer aprovação explícita.

## 4. Checkpoints detalhados

### C17 — Acessibilidade e conforto
Adicionar símbolos/formas às faces para que cor não seja a única informação; perfil de alto contraste, escala de interface e opção de movimento reduzido. Persistir preferências em KubeSession, com defaults para saves antigos. A lógica visual não altera o estado matemático do cubo. [Especificação C17](checkpoints/C17-acessibilidade-e-conforto.md).

### C18 — Métricas locais de playtest
Registrar somente métricas agregadas de run, se o jogador habilitar: duração, onda, cubos apresentados/resolvidos/expirados, espécie, cartas, estabilidade e seed. Dados ficam locais, com retenção limitada e exportação manual. Sem conta, rede, telemetria externa ou dados pessoais. [Especificação C18](checkpoints/C18-metricas-locais-de-playtest.md).

### C19 — Cubo Nebuloso
Adicionar espécie visualmente nebulosa: adesivos perdem saturação à distância e recuperam legibilidade quando a mão foca o cubo. Símbolos do C17 continuam visíveis. A regra é visual, não muda os movimentos legais nem o solver inverso. Registrar no Bestiário e na maestria sem invalidar conquistas antigas. [Especificação C19](checkpoints/C19-cubo-nebuloso.md).

### C20 — Cubo Selado
Adicionar uma face selada no início do encontro. O selo abre após dois movimentos válidos em faces permitidas; o embaralhamento é gerado com seed até que os primeiros passos inversos não dependam da face selada. Se a geração não encontrar estado válido após tentativas limitadas, usar fallback sem selo. Nunca permitir puzzle impossível. [Especificação C20](checkpoints/C20-cubo-selado.md).

### C21 — Biomas do Jardim
Criar três perfis visuais selecionados por seed: Jardim Clássico, Clareira Dourada e Pomar Nebuloso. Primeira versão apenas visual (paleta, vegetação, luz e partículas); sem modificadores de tempo ou moedas até o playtest comprovar que a leitura e a performance continuam boas. [Especificação C21](checkpoints/C21-biomas-do-jardim.md).

### C22 — Guardião do Jardim
Transformar a elite final em um encontro de chefe com três fases encadeadas, sem multiplicar spawns: Armadura 2×2, Núcleo 3×3 e Coração 3×3. Cada fase usa scramble legal e determinístico; só a terceira fase conclui o chefe. Uma única recompensa e um único registro de resolução usam o mesmo boss_id. [Especificação C22](checkpoints/C22-guardiao-do-jardim.md).

### C23 — Sinergias de habilidades
Introduzir quatro combinações iniciais entre cartas C3. Os efeitos devem ser calculados em um SynergyEngine puro, exibidos na HUD e limitados por caps já existentes. Não criar cartas permanentes, moeda nova ou progressão paralela. [Especificação C23](checkpoints/C23-sinergias-de-habilidades.md).

### C24 — Cosméticos e personalização
Criar catálogo de temas de cubo e skins da mão, desbloqueados por conquistas/maestrias ou metas de jogo. Cosméticos não mudam velocidade, alcance, recompensa ou dificuldade. Save próprio e versionado, com seleção validada e fallback para o tema padrão. [Especificação C24](checkpoints/C24-cosmeticos-e-personalizacao.md).

### C25 — Localização PT-BR/EN
Migrar textos da interface para chaves de tradução e disponibilizar Português do Brasil e Inglês. Persistir locale em KubeSession; IDs, saves, nomes internos e logs continuam estáveis e não traduzidos. Fazer revisão humana de textos e expansão de layout. [Especificação C25](checkpoints/C25-localizacao-pt-en.md).

### C26 — Gamepad
Adicionar ações semânticas ao InputMap e uma camada InputRouter. O analógico esquerdo controla uma mão virtual; A interage, B volta/cancela, Start pausa e direcional navega. Mouse continua padrão e disponível. Começar pelo menu e laboratório antes de ativar combate completo. [Especificação C26](checkpoints/C26-controle-gamepad.md).

### C27 — Integração Steam (condicional)
Só iniciar após confirmar Steam como destino, SDK/plugin compatível, licenças e requisitos de conta/publicação. Criar interface de plataforma com implementação nula/offline; achievements espelham desbloqueios locais após gravação. Cloud exige política explícita de conflito e preservação de cópias. Sem decisão Steam, manter o checkpoint em espera. [Especificação C27](checkpoints/C27-integracao-steam-condicional.md).

### C28 — Performance e compatibilidade
Criar cenários de benchmark repetíveis e medir CPU, GPU, memória, frame-time e alocação. Otimizar somente hotspots comprovados; pooling não é requisito automático. Manter GL Compatibility e comparar build Windows real. [Especificação C28](checkpoints/C28-performance-e-compatibilidade.md).

### C29 — Release Candidate e QA
Congelar funcionalidades. Executar matriz completa de saves, modos, acessibilidade, idiomas, gamepad, resoluções, 20 runs de regressão e playtest com pelo menos cinco pessoas. Corrigir bugs; qualquer funcionalidade nova volta ao roadmap, não entra escondida no RC. [Especificação C29](checkpoints/C29-release-candidate-qa.md).

### C30 — Preparação de lançamento
Versionar 1.0.0, criar build release reproduzível, pacote Windows, changelog, créditos/licenças, checksums, instruções de instalação e plano de rollback/save backup. Preparar metadados da loja se aplicável, mas não publicar sem autorização. [Especificação C30](checkpoints/C30-preparacao-de-lancamento.md).

## 5. Portões de decisão

- **Antes de C17:** C14–C16 integrados e testados manualmente.
- **Antes de C19/C20:** C18 deve fornecer dados suficientes para não inventar dificuldade/recompensa.
- **Antes de C22:** C19/C20 não podem causar puzzles impossíveis; boss mantém o limite de atores e uma recompensa.
- **Antes de C23:** cartas C3 precisam de valores medidos; não empilhar bônus sem cap.
- **Antes de C26:** C25 deve definir todas as labels e ações de UI para navegação consistente.
- **Antes de C27:** decisão formal de distribuição Steam e revisão de SDK/licenças.
- **Antes de C29:** C28 precisa demonstrar desempenho aceitável em hardware-alvo.
- **Antes de C30:** RC aprovada e lista de licenças/atribuições completa.

## 6. O que fica fora deste plano

- Multiplayer, login, backend obrigatório, leaderboard online, anúncios e telemetria externa.
- Mobile como plataforma de lançamento.
- Compras com dinheiro real, loot boxes ou vantagem paga.
- Solver geral mínimo para qualquer estado arbitrário de cubo.
- Mudanças de balanceamento baseadas apenas em intuição quando C18 puder medir o resultado.
- Publicação automática na Steam ou em qualquer loja.

## 7. Como usar este roadmap

Implementar **um checkpoint por vez**, em branch própria, sempre sobre a última main aprovada. Antes do código, abrir a especificação individual e confirmar se o estado real do repositório ainda corresponde aos caminhos descritos. Se uma dependência mudar, atualizar o documento e os testes antes de codificar. O guia [15 — Implementação futura](15-guia-de-implementacao-futura.md) define os padrões obrigatórios.
