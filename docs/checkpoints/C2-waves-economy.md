# C2 — Primeiro sistema de ondas, cubos múltiplos e economia de run

**Branch:** `dev/checkpoint-02-waves-economy`
**Engine:** Godot 4.7.2, GDScript
**Status:** código enviado para revisão, testes automatizados e aprovação visual antes do merge.

## Escopo realmente incluído

1. Campo aberto do Jardim dos Cubos e câmera ortográfica fixa, mantendo mão 2D do C1.
2. Até **4 cubos 2×2 simultâneos**, cada um composto por 8 cubinhos e 24 stickers e manipulável por giros legais de camadas.
3. **Aprendiz:** 2–4 giros planejados, 10 moedas/1 XP. **Reforçado:** 5–8 giros, corpo roxo-escuro e anel dourado, 18 moedas/2 XP.
4. Um clique/segurar sobre alvo no campo ativa giro com cooldown; novo giro só após animação anterior terminar.
5. **Duas ondas de prova:** onda 1: 6 cubos/42 s; onda 2: 8 cubos/55 s; spawn intervalado a cada 2,1 s (sujeito a vagas) e aparições em pontos visíveis.
6. **Estabilidade 100**; no fim de cada onda, -25 por cubo realmente apresentado e que não foi resolvido. Spawns não exibidos são contados no relatório, nunca penalizados. Se chegar a zero, derrota; se sobreviver às duas ondas, "C2 completo", ainda não é vitória final do jogo.
7. Recompensa idempotente e separada da UI: nenhum clique, efeito ou cubo desaparecido pode creditar sem solução confirmada.
8. HUD de onda, cronômetro, estabilidade, dinheiro, XP, progresso, informações do alvo, resumo/resultado; pausa e reinício.
9. Moedas e XP são **de teste, por partida** e zeram ao reiniciar/fechar o jogo. Persistência e loja entram em C4.
10. Cenas C0 e C1 continuam funcionando; workflow inclui novos testes e preserva regressões anteriores.

## Controles

- Mouse: posiciona cursor de mão 2D; aproxime do cubo para realce.
- Botão esquerdo: um giro; segurar repete de acordo com cooldown.
- Pausar/Continuar: congela tempo/spawn e input de gameplay.
- Recomeçar: zera moedas/XP/estabilidade e reinicia do começo.
- Tela de resultado: Próxima onda ou Jogar novamente.

## Checklist de validação manual

- [ ] F5 abre campo verde com pelo menos um 2×2; mais cubos chegam gradualmente.
- [ ] Cubinhos 2×2 continuam próximos, inclusive depois de girar.
- [ ] Todos os tipos permanecem selecionáveis com mão 2D e não atravessam painéis.
- [ ] Aprendiz/reinforçado são reconhecíveis sem ler texto e apresentam números de giros distintos.
- [ ] Até quatro cubos podem aparecer; o quinto espera uma vaga.
- [ ] Resolver aprendiz credita 10/1; reforçado 18/2, **uma única vez por cubo**.
- [ ] Com tempo esgotado, somente cubos exibidos não resolvidos retiram 25 de estabilidade.
- [ ] A primeira onda pode terminar por limpar todos os cubos ou pelo timer.
- [ ] Ao sobreviver à primeira onda, botão Próxima onda inicia a segunda.
- [ ] Ao sobreviver à segunda, resultado C2 completo; ao zerar estabilidade, derrota.
- [ ] Pausa congela cronômetro e impede girares/spawn.
- [ ] Recomeçar limpa dinheiro, XP, cubos e estabilidade, sem deixar atores órfãos.
- [ ] Testar 1280×720 e 1920×1080: HUD não cobre alvos; campo permanece verde.
- [ ] C0 3×3 e C1 2×2 ainda funcionam via F6.
- [ ] CI verde na branch. Dados, rig, estética e movimento devem ser julgados em janela real do Windows.

## Fora do C2

Cinco ondas, elite 3×3, habilidades/cartas, metaprogressão, salvar moedas, efeitos finais, export Windows e publicação. São C3–C5. **Não fazer merge até aprovação visual do usuário.**

## Testes headless

```powershell
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/unit/test_c2_rules.gd
godot --headless --path . --script res://tests/integration/test_c2_stage.gd
```
