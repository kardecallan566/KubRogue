# 07 — MVP inicial: escopo fechado e critérios de aceite

## 1. Definição de pronto

**MVP KubRogue = jogo single-player completo e testável no Windows, do menu à tela de vitória/derrota, com a mão resolvendo cubos tridimensionais por movimentos válidos, cinco ondas, economia e escolhas roguelite.**

O MVP não significa “jogo comercial pronto”, mas uma fatia vertical que demonstra a fantasia e o loop inteiro. “Funciona” precisa ser verificável pela lista de aceite abaixo.

## 2. Entregas obrigatórias

### Jogo e conteúdo

- [ ] Projeto Godot 4.x abre sem erros críticos; entrada pela cena principal configurada.
- [ ] Menu/hub: Jogar, Loja, Configurações, Sair, resumo da carteira.
- [ ] **Jardim dos Cubos:** campo gramado 3D visualmente contínuo e autoral, **sem plataforma circular ou muros**, Camera3D ortográfica quase superior **fixa** e mão controlada por mouse.
- [ ] Cubos físicos visíveis compostos por camadas rotacionáveis, com estado lógico real.
- [ ] 2x2 aprendiz: cores embaralhadas, rotações válidas e solução visual inequívoca.
- [ ] 2x2 reforçado: maior número de movimentos e comportamento visual distinto.
- [ ] Elite 3x3: malha compatível com rotações de camadas e animação final.
- [ ] Clique único ou segurar aplica movimentos corretos no alvo, respeitando cooldown.
- [ ] Contador de movimentos, moedas previstas, foco/realce e cancelamento seguro de input.
- [ ] Cinco ondas sequenciais; spawn periférico visível, slot reservado para elite 3x3 até o segundo 20 da onda 5, relógio, expiração, estabilidade apenas por cubos efetivamente apresentados e transição.
- [ ] Vitória com elite resolvida; derrota por estabilidade zerada ou elite não resolvida no tempo final.
- [ ] Moedas + XP atribuídos **somente** por cubo finalizado.
- [ ] Cartas: oito habilidades com níveis, oferta de 1 em 3 **durante a run após resolver**, teto de cinco ofertas XP 5/12/21/32/45, nenhuma carta após vitória/derrota.
- [ ] Loja com três melhorias permanentes e persistência local.
- [ ] Tutorial contextual de primeira jogada e reabertura no menu.
- [ ] HUD completo, efeitos/sons mínimos e telas de fim/reinício.

### Polimento mínimo

- [ ] Escalas funcionam em 1280x720 e 1920x1080, sem elementos cortados.
- [ ] Menus usam PT-BR consistente e fontes legíveis.
- [ ] Pausa congela spawn, relógio e comandos de gameplay; menus não contam tempo.
- [ ] Opções: volume música, volume efeitos, reduzir partículas, desligar tremor.
- [ ] Botões distinguem disponível/indisponível; mouse sobre HUD não seleciona cubos.
- [ ] Rodar duas partidas seguidas sem vazamentos óbvios nem moedas duplicadas.
- [ ] Build Windows inicia sem depender da instalação do editor no PC.
- [ ] README atualizado com instruções reais de abrir, jogar e exportar somente quando existir código.

## 3. O que expressamente NÃO faz parte do MVP

- Resolver cubos livremente à maneira de um simulador/speedcubing;
- 4x4, 5x5, Pyraminx, Megaminx ou outras famílias;
- multiplayer, placar online, Steamworks, conquistas Steam;
- login, backend, multiplayer, compras, microtransações, anúncios;
- física destrutiva ou cubes despedaçados; inimigos com tiros;
- múltiplas arenas, editor de níveis, lore extensa, narrativa ou missões diárias;
- suporte obrigatório a celular, gamepad, Linux ou macOS;
- dezenas de cartas, raridades complexas, procedurais infinitos;
- integração “fictícia” de um modelo 3D não recebido ou que não aceite rotação de camadas.

## 4. Sequência concreta de aceitação

**T1 — Mapa e visibilidade:** iniciar build e identificar mão e 2x2 sobre **gramado contínuo** sem borda de arena, câmera top-down fixa e spawns fora da HUD.

**T2 — Resolução legítima:** inspecionar a sequência de movimentos; após cada clique o modelo do puzzle fica consistente com o render, última jogada deixa seis faces uniformes.

**T3 — Pagamento correto:** resolver 1 aprendiz -> +10 moedas e +1 XP (sem bônus); tocar novamente no cubo já resolvido -> nenhum novo pagamento.

**T4 — Ofertas:** alcançar 5 XP resolvendo cubos -> oferecer 3 cartas **durante a onda após giro seguro**, pausar mundo; selecionar -> efeito imediato; ao terminar partida não mostrar cartas.

**T5 — Falha:** deixar 4 cubos **apresentados** não resolvidos ao encerrar ondas (sem recuperação) -> estabilidade 100 chega a zero, derrota e moedas prévias preservadas. Cubos nunca spawnados não penalizam.

**T6 — Vitória:** completar as ondas, resolver elite 3x3 na onda 5 -> tela de vitória com estatísticas e opção de rejogar.

**T7 — Loja/save:** sair após ganhar pelo menos 200 moedas, relançar, comprar Treino da mão I -> -200 do saldo e velocidade inicial maior na run seguinte; relançar -> compra preservada.

**T8 — Inputs extremos:** pressionar ESC ou sair enquanto a última camada gira -> nenhuma duplicidade/corrupção e timer congelado/encerrado conforme tela.

**T9 — HUD/resolução:** sem cortes em 720p e 1080p; clicar em interface nunca move a camada de um cubo atrás do painel.

**T10 — Qualidade do build:** exportar Windows, executar num ambiente sem Godot Editor, vencer/perder runs e reabrir save com sucesso.

## 5. Métricas propostas para playtest

| Métrica | Meta inicial para considerar validado |
|---|---|
| Entendimento sem explicação | >= 80% de 5 testadores identificam como resolver em 60 s |
| Tempo de run vencedora | Mediana 6–8 min |
| Conclusão por iniciante | Pelo menos 3/5 completam as 2 primeiras ondas |
| Consistência de puzzle | 1000 seeds testadas por tipo sem estado sem saída |
| Pagamento | 0 duplicações em 100 runs automatizadas/simuladas |
| Crashes críticos | 0 no roteiro T1–T10 |
| Frame rate | Meta 60 FPS no PC-alvo definido; registrar percentis e eventuais quedas |
| Clareza visual | 5/5 identificam elite e recompensa em testes curtos |

Estas metas são critérios de experiência, **não fatos medidos atualmente**.

## 6. Aprovação e mudança de escopo

Completar cada checkpoint com evidências: captura curta, checklist, versão do Godot, logs/testes e mudanças. Se o protótipo da mão não for divertido, **refinar o gesto e o feedback antes de construir a loja**. Funcionalidades acima do MVP entram no backlog e não bloqueiam a primeira versão.

## 7. Critérios adicionais de mapa e experiência

- [ ] Campo aberto gramado cobre 100% da área atrás da câmera sem borda visível, inclusive 16:10.
- [ ] Piso com manchas arredondadas e tufos pequenos esparsos **originais**; nenhuma cerca, obstáculo alto ou plataforma de arena.
- [ ] Com 4 cubos simultâneos, todos são selecionáveis, legíveis e não se sobrepõem à mão/HUD.
- [ ] A elite surge até 20 s da onda 5 mesmo se há três cubos comuns ativos.
- [ ] UI de carta pausa timer/spawner e retorna sem pular o tempo.
- [ ] Audio de giro, solução e moedas identificáveis com opção de volume/redução visual.
- [ ] Não pagar moeda anunciada sem salvar; idempotência conferida por teste.

Direção completa em [11](11-mapa-campo-aberto-e-camera.md), [12](12-gamefeel-eventos-visuais-e-detalhamento.md) e problemas da auditoria em [13](13-auditoria-de-consistencia.md).

## 8. Situação dos itens de C0

A cena de **inspeção 3×3** e o código do cubo foram adicionados no checkpoint 00; **isso não marca nenhum requisito de gameplay do MVP como concluído**. O 2×2, mão, combate e cinco ondas continuam com caixas abertas. Ver [C0](checkpoints/C0-kubos-asset-audit.md).
