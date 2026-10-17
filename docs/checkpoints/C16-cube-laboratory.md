# C16 — Laboratório do Cubista: treino livre com cubos reais

**Branch:** `dev/checkpoint-16-cube-laboratory`. **Base:** C15, que depende do C14, ambos ainda com PRs em revisão. **Godot:** 4.7.2 Compatibility. **Entrega:** sem merge até validação no Windows.

## Motivação e escopo

As novas dimensões 4×4 e 5×5 possuem giros nas camadas internas, mas nas partidas o cronômetro dificulta aprender como elas funcionam. O Laboratório cria uma experiência paralela, **sem cronômetro, sem carteira, sem XP e sem salvar recordes**, que permite explorar os mesmos cubos reais do combate. Não é um replay nem uma simulação visual.

**Acesso:** Hub → **JOGAR** → **LABORATÓRIO — TREINO LIVRE 2×2 A 5×5**, abaixo dos três cards Normal/Diário/Semanal. Mantidos **exatamente quatro botões** na tela principal.

### Mecânicas reais

- Quatro tamanhos de cubos disponíveis, com 8/26/56/98 cubies externos e 24/54/96/150 adesivos.
- Seleção de face `F R U L D B`, camada externa ou interna conforme o tamanho, giros de -90°, +90° ou 180°.
- Giros aplicam transições legais ao estado matemático orientado (o mesmo usado no gameplay), com pivô físico e snap exato após interpolação.
- Embaralhamento real com seed pseudoaleatória exibida. **NOVO EMBARALHAMENTO** altera a seed; **REPETIR A MESMA SEED** retorna à mesma posição inicial.
- `VER UMA DICA` mostra um dos próximos movimentos inversos registrados. `APLICAR DICA` gira fisicamente a camada indicada; não reivindica ter encontrado um caminho mínimo.
- Após um giro manual, o plano inverso considera também a nova ação, permitindo alternar prática livre e ajuda.
- Ao resolver, a cena reconhece o estado lógico resolvido e bloqueia giros até embaralhar outra vez.
- O ambiente é um pequeno gramado 3D com luz original, centro livre e painéis laterais para comandos e ajuda.

### Isolamento

O Laboratório **nunca chama** `KubeSession.begin_run`, `credit_cube`, `finish_run`, `KubeJournal.record_cube`, `KubeChallenge.begin_run` nem `KubeHistory.record_result`. Seu progresso é totalmente descartável. As cenas anteriores ficam no repositório; o combate C15 é reutilizado via herança e retorna à hub C16. O modo Semanal, seed diária, contratos, Oficina, Rotas e Fever não são modificados.

### Validação

- [ ] Uma cópia limpa abre o novo menu e a cena de treino antes de gerar cache de importação.
- [ ] Na hub existem quatro botões e, em Jogar, os três modos + o link do Laboratório.
- [ ] Testar 2×2/3×3/4×4/5×5; observar cubies verdadeiros, adesivos e cortes de câmera.
- [ ] Rodar as 6 faces, 90°/180° e camadas internas das dimensões avançadas.
- [ ] As dicas descrevem um giro e o botão de aplicar executa esse movimento. Resolver após giro manual continua possível.
- [ ] Repetir seed reproduz o mesmo cubo e zera a contagem de movimentos.
- [ ] Sair e entrar novamente não altera dinheiro, conquistas, Bestiário, histórico ou modos Diário/Semanal.
- [ ] A 1280×720 e a 1920×1080, a interface não invade o cubo e os botões continuam visíveis.
- [ ] Toda a suíte C0–C16 e exportação Windows passam no GitHub Actions.
- [ ] Depois, o usuário valida giro, responsividade, tipografia e composição no Windows.

**Sem solver mínimo geral:** as dicas apenas aplicam a sequência inversa do histórico legal de giros. O jogador pode solucioná-lo manualmente sem usar dicas.
