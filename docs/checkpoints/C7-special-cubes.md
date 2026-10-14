# C7 — Dourados, Blindados e novas recompensas

**Branch:** `dev/checkpoint-07-special-cubes`  
**Engine:** Godot 4.7.2 Compatibility.  
**Estado:** aguardando validação gráfica e jogável no Windows antes do merge.

## Objetivo

Diversificar o encontro com cubos na mesma arena gramada aberta. Além do Aprendiz, Reforçado e Elite 3×3, são introduzidos dois 2×2 especiais, com **mecânica legal de giro** e diferenças nítidas, mas sem inventar vida/ataque inimigo incompatíveis com o conceito de resolver cubos.

## Conteúdo

| Variante | Ondas | Giros antes de habilidades | Moedas base | XP |
|---|---|---:|---:|---:|
| Aprendiz 2×2 | 1–5 | 2–4 | 10 | 1 |
| Reforçado 2×2 | 2–5 | 5–8 | 18 | 2 |
| Dourado 2×2 | 2–5 | 3–5 | 32 | 2 |
| Blindado 2×2 | 3–5 | 8–11 | 30 | 3 |
| Elite 3×3 | onda 5 | 6–12 | 80 | 6 |

Os especiais substituem alvos em slots existentes, preservando o total de cubos por onda e as regras de estabilidade. Material/título/halo distinguem o Dourado de alto valor e o Blindado de longa resolução; os adesivos coloridos continuam legíveis. O olharde cubista reduz giros do reforçado/blindado. Moedas adicionais de habilidades e da loja continuam aplicáveis, calculadas uma vez após a solução.

**Arquivos:** `scripts/c7/{special_director.gd,special_wallet.gd,special_visuals.gd,game_stage.gd,hub_stage.gd}`; cenas novas em `scenes/c7/`. As cenas C0–C6 permanecem acessíveis. Não há mudanças de esquema em `user://kubrogue_progress_v1.json` ou `user://kubrogue_daily_v1.json`.

## Checklist

- [ ] `godot .` sem erros de scripts ou PNG não importado, inclusive após clone novo.
- [ ] Dourado aparece na onda 2 com visual distinto, halo e etiqueta, oferece +32 moedas/+2 XP quando resolvido.
- [ ] Blindado aparece na onda 3 com materiais roxos e mais giros, oferece +30 moedas/+3 XP.
- [ ] Adesivos 2×2 continuam visíveis e juntas permanecem compactas após cada giro.
- [ ] Nenhum cubo dá moedas duas vezes; salvar/reabrir mantém saldo e upgrades.
- [ ] Habilidade Olhar de cubista continua diminuindo os giros de cubos difíceis.
- [ ] C5/C6 interface, cursor aberto/fechado, áudio, cartas, reroll e desafio diário continuam funcionando.
- [ ] Elite 3×3 ainda aparece até 20 s da onda 5 e é obrigatória para vitória.
- [ ] Testar 1280×720 e 1920×1080, legibilidade de etiquetas (sem atrapalhar cubos vizinhos).
- [ ] CI C0–C7 verde; ZIP Windows gerado e executado fora do editor.

Ainda não há 4×4, chefes adicionais ou loja de cosméticos neste checkpoint, para evitar diluir o controle e o combate atual.

## Expansão ainda no C7 — Cubos reais 4×4×4 e 5×5×5

O C7 também introduz duas dimensões avançadas, com **giros legais de camadas externas e internas**. Não são objetos 3D decorativos nem 3×3 apenas ampliados.

| Variante | Primeira aparição | Corpo visível | Adesivos | Giros registrados | Moedas base | XP |
|---|---|---:|---:|---:|---:|---:|
| Mestre 4×4×4 | Onda 4 | 56 peças | 96 | 7–10 | 68 | 5 |
| Titã 5×5×5 | Onda 5 | 98 peças | 150 | 9–13 | 110 | 8 |

**Modelagem:** estado inteiro `scripts/puzzle/cube_state_nxn.gd` e geometria `scripts/visual/cube_nxn.gd`. O cubo usa apenas cubies de superfície, como em um puzzle físico, com cores corretas nas seis faces, juntas compactas, animação de pivô em cada camada e snap exato ao final. O modelo 4×4 tem duas camadas internas possíveis; o 5×5 tem três. O procedimento atual resolve com a sequência inversa do embaralhamento legal registrado — não é um solver livre para embaralhamentos arbitrários escolhidos pelo jogador.

**Balanceamento:** 4×4 substitui um dos alvos da onda 4; 5×5 substitui um alvo da onda 5, preservando a elite 3×3 obrigatória e os totais de spawn. A skin Mestre é azul-ciano, a Titã é roxa-rosa; adesivos continuam nas seis cores usuais, e o campo gramado permanece o mesmo. O valor se soma ao bônus de moedas da loja/cartas e só é concedido após resolução confirmada.

**Validação adicional:** testar se 4×4 e 5×5 são realmente compostos por 4 e 5 peças por lado, sem sobreposições; verificar camadas internas, tempo de resolução, FPS, halos e etiquetas. No Windows, verificar onda 4/onda 5, cartas e saldo após reiniciar. A suíte C7 tem testes de estado/giros/visual, pagamento e resolução in-game.
