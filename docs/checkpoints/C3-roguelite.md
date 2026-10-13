# C3 — Cinco ondas, elite 3×3 e habilidades roguelite

**Branch:** `dev/checkpoint-03-roguelite`, baseada na main após o merge do C2.
**Engine:** Godot 4.7.2 · GDScript · jogo offline para PC.
**Estado:** implementação de checkpoint para playtest; **ainda não é o MVP**.

## Objetivo e entregas

1. Manter o campo gramado contínuo de King of Pickaxe como **inspiração espacial abstrata**, com arte original, câmera ortográfica fixa, mão 2D e cubos 3D compactos. Nada de pedras, picaretas ou cenários copiados.
2. Estender o sistema para **cinco ondas**: aprendizes/reforçados com 2–4/5–8 movimentos antes de modificadores, até quatro alvos simultâneos, estabilidade 100 e penalidade -25 por cubo mostrado mas não resolvido.
3. Elite 3×3 de fato, reutilizada de Kubos/C0, com 26 cubinhos, 54 adesivos e rotação real. Na onda cinco, reservar quarta vaga para a elite; spawn prioritário por volta de 18–20 segundos mesmo sob pressão. **Vitória exige elite resolvida e estabilidade positiva.**
4. XP acumulada com limiares **5, 12, 21, 32, 45**, no máximo 5 ofertas por run, cada uma com três cartas distintas. A seleção **pausa o mundo** e nunca aparece após a derrota/vitória.
5. Catálogo de **oito habilidades temporárias** (cada uma até 3 níveis): Pulso ágil, Dedo certeiro, Luva magnética, Bolsa encantada, Ritmo de mestre, Fôlego extra, Olhar de cubista, Mão paciente. Todas alteram cálculo real, conforme `scripts/c3/run_build.gd`.
6. **Recompensas:** aprendiz 10 moedas/1 XP, reforçado 18/2, elite 80/6 antes de bônus. ID único impede crédito repetido. Combo de soluções habilita benefício de Ritmo de mestre. Bônus máximo de moedas +150%, nunca altera XP.
7. Continuar mostrando tempo, estabilidade, número de cubos, moedas, XP, nível, alvo, combo e habilidades no HUD. Telas de onda/resultado e pausa; cenas C0–C2 preservadas.

## Regras canônicas

- **Movimento visual -> estado lógico resolvido -> pagamento único -> XP/oferta pendente -> penalidade de onda -> verificação de fim de run -> cartas se a run continuar.**
- Uma oferta durante onda pausa timer, spawns, cursor de ataque e movimentação decorativa. Se uma onda terminar junto com a solução, mostrar resumo; a carta fica disponível antes de iniciar próxima onda. Resultado final cancela cartas pendentes.
- A elite não pode ficar presa atrás de quatro cubos comuns. A regra de slot permanece mesmo que haja spawns normais pendentes.
- A elite pode ser resolvida antes dos cubos restantes. O fim da quinta onda ocorre ao limpar tudo que apareceu + fila, ou por timer; exige elite realmente solucionada para vencer.
- Moedas ainda são temporárias. Loja e save só no C4. Nenhum arquivo do Kubos original é alterado.

## Testar no Windows

```powershell
git fetch origin
git switch dev/checkpoint-03-roguelite
git pull origin dev/checkpoint-03-roguelite
```

Abrir `project.godot` com Godot 4.7.2, **F5**. Testar 720p e 1080p.

## Checklist manual

- [ ] Cinco ondas sequenciais sem contador travado.
- [ ] Cubos 2×2 compactos, 3×3 visualmente íntegro; sticker girando com camada correta.
- [ ] Mão 2D seleciona alvos sem clicar através de HUD e cards.
- [ ] Até quatro cubos ativos; na quinta onda a elite aparece até 20 segundos e mantém prioridade de spawn.
- [ ] Ao chegar a 5 XP, três cartas distintas aparecem; timer congela, selecionar melhora a run, volta sem salto de tempo.
- [ ] Cada uma das oito habilidades altera números/comportamento de modo verificável.
- [ ] Reforçados exigem mais giros e são reconhecíveis pela coloração/anel.
- [ ] Elite concede 80 moedas e 6 XP sem duplicar pagamento; bônus não altera XP.
- [ ] Combo e contador de movimentos resetam/expiram conforme design.
- [ ] Deixar elite sem solução ao fim da quinta onda causa derrota, mesmo com estabilidade positiva.
- [ ] Resolver elite e sobreviver à quinta onda produz vitória (não basta matar 2×2).
- [ ] Pausar, retomar e recomeçar funcionam no meio da gameplay e em menus.
- [ ] C0/C1/C2 continuam acessíveis e sem regressões; CI verde na HEAD da branch.

## Pós-C3

O C4 implementará hub, loja com três melhorias permanentes, transações duráveis em `user://`, tutorial e primeira experiência; C5 fará efeitos, áudio, performance e exportação Windows. **Não realizar merge do C3 sem teste visual e aprovação explícita.**
