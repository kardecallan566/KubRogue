# 10 — Parâmetros de balanceamento v0 (HIPÓTESES)

**ATENÇÃO:** valores de partida para desenvolvimento. Ajustar depois de medir o protótipo C1–C3. Não declarar estes números como resultados confirmados.

## 1. Dados base

| Parâmetro | Base proposta |
|---|---|
| Janela do jogo | 1280x720 (escalar para 1080p) |
| FPS alvo | 60 no PC de desenvolvimento |
| Quantidade de ondas | 5 |
| Cubos ativos simultâneos | máximo 4 |
| Estabilidade inicial | 100 |
| Estabilidade perdida por cubo não resolvido | 25 |
| Intervalo de uma ação de mão | 0,34 s |
| Cooldown mínimo com upgrades | 0,16 s |
| Duração visual de giro de 90° | 0,22–0,30 s (não ultrapassar cooldown) |
| Expiração do combo sem solução | 12 s |
| Raio de foco da mão | Escala ajustada visualmente ao cubo, sem atravessar UI |
| Duração pretendida de run vencedora | 6–8 min, incluindo cartas e transições |

## 2. Tabela das ondas

| Onda | Duração limite | Aprendizes 2x2 | Reforçados 2x2 | Elite 3x3 | Total |
|---|---:|---:|---:|---:|---:|
| 1 | 45 s | 5 | 0 | 0 | 5 |
| 2 | 55 s | 6 | 2 | 0 | 8 |
| 3 | 65 s | 6 | 3 | 0 | 9 |
| 4 | 70 s | 6 | 5 | 0 | 11 |
| 5 | 90 s | 5 | 4 | 1 | 10 |
| **Total** | **325 s** | **28** | **14** | **1** | **43** |

Uma onda termina antecipadamente **apenas quando toda a quota prevista foi spawnada e os cubos apresentados foram resolvidos**; arena vazia com quota ainda aguardando spawn não conclui a onda. Caso o relógio acabe, spawns pendentes nunca apresentados ficam registrados como `nao_apresentados` e não penalizam.

Spawns: sequenciais, na **faixa periférica visível do Jardim dos Cubos**, com até 4 cubos ativos. Quotas pendentes aguardam vaga; **nunca penalizar cubos que não apareceram**. Na onda 5, manter **no máximo três cubos comuns** antes da chegada da elite e fazê-la surgir **obrigatoriamente até o segundo 20** de tempo decorrido (janela de 70 s). Após entrada da elite, usar quatro vagas totais. O spawn deve respeitar HUD, distância da mão e visibilidade.

## 3. Tipos de cubo

| Tipo | Embaralhamento | Moeda base | XP base | Padrão |
|---|---|---:|---:|---|
| Aprendiz 2x2 | 2–4 giros legais | 10 | 1 | Movimento/oscilações suaves |
| Reforçado 2x2 | 5–8 giros legais | 18 | 2 | Deslocamento lento, material distinto |
| Elite 3x3 | 6–12 giros legais | 80 | 6 | Introdução especial, 1 por run |

**Dificuldade:** a profundidade escolhida é o comprimento do embaralhamento gerado, não medida exata de menor solução. Descartar sequências triviais; detectar resolução antecipada e encerrar. A elite deve terminar com face uniforme legítima, não após “12 HP”.

Total teórico sem bônus de uma run que resolve todos os cubos:
- **Moedas:** 28×10 + 14×18 + 1×80 = **612**.
- **XP:** 28×1 + 14×2 + 1×6 = **62**.
- A run pode pagar menos por cubos não resolvidos ou mais com bônus.
- Os limiares cumulativos **5/12/21/32/45 XP** permitem até 5 ofertas **durante a run após resoluções seguras**, pausando timer/spawns. Não há cartas pós-vitória/derrota nem XP 60 como novo limiar neste MVP.

## 4. Ações e limites

Com cubos médios a ~3 giros aprendiz, ~6,5 reforçado e ~9 elite, a run limpa precisa de ~184 ações (estimativa 28×3 +14×6,5 +9). A 0,34 s, são ~63 s de cooldown puro **sem contar deslocamento, animação, decisões e spawns**; portanto pacing depende principalmente dos spawns e da tensão criada pelo cronômetro, não de exigir centenas de cliques por segundo.

A mão deve ser confortável para jogar segurando o botão, sem automação ociosa: exige cursor sobre alvo.

## 5. Upgrades permanentes

| Item | Preço níveis 1/2/3 | Ganho por nível |
|---|---|---|
| Treino da mão | 200 / 500 / 1200 | -4% cooldown-base |
| Bolso do cubista | 250 / 650 / 1300 | +5% moedas |
| Arena estável | 300 / 800 / 1600 | +5 estabilidade inicial/máxima |

Preços são por nível a comprar, não acumulados. Compra após run; saldo salvo no momento da solução, independentemente da derrota.

## 6. Cartas e metas de variedade

Oito cartas com até três níveis cada, oferta de 3 distintas, cartas max excluídas. A carta Olhar de cubista reduz apenas movimentos de cubos reforçados futuros; mínimo 2 giros. Os modificadores precisam ser quantificados no HUD e limitados para prevenir builds infinitas.

## 7. Playtests e decisões de ajuste

**Se o jogo parecer lento:** primeiro encurtar intervalos de spawn/animação e melhorar responsividade da mão, **não** inflar dinheiro para mascarar. **Se parecer automático demais:** adicionar decisões de priorização e comportamento de cubos, não exigir resolução manual sem redesign. **Se 3x3 ficar cansativo:** reduzir movimentos e melhorar indicação de giro antes de criar upgrade obrigatório. **Se jogadores perderem cedo:** baixar penalidade ou número de spawns, mantendo valor das escolhas.

Registrar por onda: duração real, cubos aparecidos/resolvidos/expirados, giros por cubo, moedas/minuto, ofertas recebidas, estabilidade restante, frame-time e motivos de frustração. Ajustar uma variável relevante por rodada de teste e anotar decisão.

## 8. Condições de vitória e derrota (fonte canônica)

- Vitória: ao encerrar a onda 5 com **elite resolvida e estabilidade maior que zero**.
- Derrota: estabilidade chega a zero em qualquer onda; ou na onda 5 a elite não está resolvida quando tempo encerra.
- Estabilidade reduzida ao fim da onda **apenas** por cubos efetivamente spawnados e não resolvidos (25 cada). Spawns pendentes nunca exibidos não reduzem estabilidade e são contabilizados separadamente.
- Cubos completados **antes** do encerramento confirmado creditam moedas/XP, mesmo se a run for derrotada.
- Transições devem aguardar ações visuais já confirmadas, evitando perder um cubo que concluiu no limite.

## 9. Mapa e especificação numérica auxiliar v1

- Bioma único MVP: **Jardim dos Cubos**, campo gramado pastel, topo 3D, manchas/folhas pequenas e esparsas, **sem palco circular nem borda visível**.
- Câmera ortográfica **fixa**, aproximadamente 15–25° desviada da vertical; piso grande extrapola viewport; mundo não possui scrolling/infinito no MVP.
- Retângulo útil lógico (proposta inicial) ~18×10 unidades no plano XZ, recalibrado por aspect ratio e safe area de UI. A posição de spawn fica dentro do enquadramento, perto das margens.
- Intervalo de sinalização de spawn **0,25–0,45 s**; não bloquear giro de outro cubo durante esse efeito.
- Slot da elite reservado na onda 5; spawn forçado até t=20 s, independentemente da fila comum (e sempre visível).
- A escolha de habilidade é exibida após movimento completo e verificação de vitória/derrota, com gameplay congelado; limite de cinco ofertas por run.

Mapa autoral detalhado em [11](11-mapa-campo-aberto-e-camera.md); sensação de resolução em [12](12-gamefeel-eventos-visuais-e-detalhamento.md). Todas essas cifras são valores para protótipo, não resultados de testes.
