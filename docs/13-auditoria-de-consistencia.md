# 13 — Auditoria dos documentos: inconsistências e decisões corrigidas

**Revisão:** 2026-10-13. **Escopo:** documentação do README e arquivos 00–12. **Estado:** revisão documental; nenhum script Godot ou asset foi testado, pois ainda não existe código de jogo neste repositório.

## 1. Achados principais e resolução

| ID | Problema anterior | Decisão revisada | Onde está especificado |
|---|---|---|---|
| A01 | Arena circular/retangular elevada, com borda visível, destoava do campo aberto da referência | Jardim dos Cubos: gramado contínuo, sem paredes ou bordas visíveis, top-down e pouca decoração | 05, 11 |
| A02 | “Campo infinito” e posição da mão pela câmera podem produzir deriva se câmera seguir cursor | **Câmera fixa** no MVP; chão estende além da câmera; rolagem opcional e posterior, com controle redesenhado | 01, 06, 11 |
| A03 | Carta só entre ondas significa que habilidades podem aparecer quando a run já acabou | Oferecer logo após resolução/efeito seguro, pausar simulação, e **cancelar** ofertas quando há vitória/derrota | 01, 03, 04, 10, 12 |
| A04 | XP até nível 6+ indefinido e progressão potencialmente inútil no último evento | Limiares fixos cumulativos 5,12,21,32,45; teto de 5 ofertas por run, se ocorrerem antes de terminar | 03, 10 |
| A05 | Cubos ainda não apresentados poderiam drenar estabilidade ao expirar tempo | Penalizar **apenas cubos efetivamente spawnados e não resolvidos**; pendentes não contam como falhas nem pagam | 01, 10 |
| A06 | Elite poderia ficar bloqueada atrás de 4 cubos comuns | Reservar slot da elite na onda 5 e spawnar com janela antecipada obrigatória | 01, 10, 11 |
| A07 | Fluxo de término/solução/carta/cobrança tinha prioridades ambíguas | Ordem canônica: concluir giro -> confirmar solução -> pagar uma vez -> contabilizar onda -> detectar fim de run -> só então oferecer carta se run ativa | 01, 02, 03, 06, 10 |
| A08 | Save por debounce poderia perder moeda exibida antes de persistir | Persistir crédito confirmado antes de exibir pagamento; escrita atômica, idempotência e testes | 03, 06, 09 |
| A09 | Cena aberta com inimigos danosos conflitaria com o foco de resolução | Movimento leve e seleção por cursor; **sem colisão ofensiva ou HP** no MVP | 01, 11, 12 |
| A10 | Escopo visual pouco concreto | Paleta, densidade de decoração, spawn ring, sombra, animação da mão/cubo e feedback descritos em detalhes | 05, 11, 12 |

## 2. Autoridades de regra (evita divergências futuras)

- **Gameplay / ordem de eventos / pausa:** [01](01-jogabilidade-e-regras.md).
- **Legalidade de movimentos / puzzles:** [02](02-cubos-e-resolucao.md).
- **Economia / XP / save:** [03](03-economia-e-progressao.md).
- **Catálogo de cartas:** [04](04-habilidades-e-sinergias.md).
- **Câmera, mapa, spawns e paisagismo:** [11](11-mapa-campo-aberto-e-camera.md).
- **Parâmetros numéricos, spawns da elite e limites:** [10](10-balanceamento-inicial.md).
- **Microinterações e animações:** [12](12-gamefeel-eventos-visuais-e-detalhamento.md).
- **Aceitação do MVP:** [07](07-mvp-e-criterios.md).

Qualquer mudança que altere uma autoridade precisa atualizar as referências nos demais documentos e aumentar a versão desta auditoria.

## 3. Regras de eventos canônicas

1. Spawn cria instância única e a registra em contadores de cubos **mostrados ao jogador**.
2. Input solicita movimento; a lógica bloqueia concorrência e anima o giro.
3. No fim do giro, o puzzle valida estado realmente resolvido.
4. Se resolvido, registrar conclusão **exatamente uma vez** e persistir moedas antes de feedback visual.
5. Creditar XP e avaliar limiar de nível, mas **adiar painel** até sair de qualquer animação e enquanto run segue ativa.
6. Atualizar fila e timer de spawn; se onda terminou, aplicar penalidade somente a cubos que spawnaram e não foram resolvidos.
7. Processar derrota/vitória **antes** de abrir nova oferta; sem cartas pós-vitória.
8. Se run continua, abrir oferta pendente com simulação pausada; após escolher, continuar no ponto certo.

## 4. Regras do mapa canônicas

**Visualmente:** campo gramado livre e contínuo com padrões discretos, câmera fixa perto do topo e 3D legível. **Logicamente:** há limites invisíveis e zonas de spawn no campo de visão, sem navegação infinita. Não prometer mundo infinito ou exploração; inspiração estética e espacial não é equivalência técnica com King of Pickaxe.

## 5. Verificações necessárias na implementação (não realizadas)

- Simulações de 1000 seeds 2x2 e 3x3;
- Performance real de campo+folhagem+4 cubos no renderer escolhido;
- Teste de câmera ortográfica em 720p/1080p/16:10;
- Conforto de mouse/segurar e feedback de giro;
- Testes contra softlock da elite com slots reservados;
- Save atômico/recuperação de corrupção;
- Consulta de licença e estrutura do cubo 3D do usuário.

Os itens acima **não foram executados** na fase documental. Aprovação de texto não comprova comportamento.

## 6. Controle de mudanças

Antes de fechar um checkpoint, verificar se as decisões continuam alinhadas: campo aberto, mão central, movimentos válidos, cinco ondas, moedas persistentes, cartas temporárias, elite 3x3 e escopo MVP enxuto. Se dados do protótipo invalidarem hipóteses, atualizar primeiro o doc 10 e a autoridade correspondente, depois o resto.

## 7. Atualização C0 — prova de asset em código

O repositório privado Kubos foi examinado; o suposto “modelo 3D” é procedural GDScript (26 cubinhos e 54 plaquinhas), não .glb. A branch C0 de KubRogue agora tem adaptação 3×3, cena de inspeção e testes. O risco de **modelo não disponível** foi mitigado no 3×3, mas o risco de **2×2** e de controle arcade da mão permanece. A validação gráfica e o CI não podem ser presumidos aprovados apenas pelo commit. [Detalhes e rastreabilidade](checkpoints/C0-kubos-asset-audit.md).
